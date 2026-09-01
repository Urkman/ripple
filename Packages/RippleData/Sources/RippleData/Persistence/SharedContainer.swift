import Foundation
import OSLog
import RippleDomain
import SwiftData

public struct SharedContainer: Sendable {
    public let modelContainer: ModelContainer
    public let syncStatus: SyncStatus

    private static let migrationMarker = ".RippleLegacyStoreMigration.v1"
    private static let migrationLogger = Logger(
        subsystem: "de.stefansturm.ripple",
        category: "store-migration"
    )

    public static func make(
        inMemory: Bool = false,
        appGroup: String = RippleIdentifiers.appGroup
    ) -> SharedContainer {
        if inMemory {
            return makeInMemory()
        }

        let groupAvailable = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroup
        ) != nil

        if groupAvailable {
            if let cloud = try? makeConfiguration(
                appGroup: appGroup,
                cloudKit: true,
                inMemory: false
            ) {
                migrateLegacyStoreIfNeeded(into: cloud, appGroup: appGroup)
                return SharedContainer(modelContainer: cloud, syncStatus: .available)
            }

            if let local = try? makeConfiguration(
                appGroup: appGroup,
                cloudKit: false,
                inMemory: false
            ) {
                migrateLegacyStoreIfNeeded(into: local, appGroup: appGroup)
                return SharedContainer(modelContainer: local, syncStatus: .unavailable)
            }
        }

        if let disk = try? makeConfiguration(
            appGroup: nil,
            cloudKit: false,
            inMemory: false
        ) {
            return SharedContainer(modelContainer: disk, syncStatus: .unavailable)
        }

        return makeInMemory(status: .unavailable)
    }

    public static func makeInMemory(status: SyncStatus = .unavailable) -> SharedContainer {
        do {
            let container = try makeConfiguration(appGroup: nil, cloudKit: false, inMemory: true)
            return SharedContainer(modelContainer: container, syncStatus: status)
        } catch {
            fatalError("Ripple in-memory container failed: \(error)")
        }
    }

    private static func makeConfiguration(
        appGroup: String?,
        cloudKit: Bool,
        inMemory: Bool
    ) throws -> ModelContainer {
        let configuration: ModelConfiguration
        if inMemory {
            configuration = ModelConfiguration(
                "Ripple-\(UUID().uuidString)",
                schema: RippleSchema.schema,
                isStoredInMemoryOnly: true,
                cloudKitDatabase: .none
            )
        } else if let appGroup {
            configuration = ModelConfiguration(
                "Ripple",
                schema: RippleSchema.schema,
                isStoredInMemoryOnly: false,
                groupContainer: .identifier(appGroup),
                cloudKitDatabase: cloudKit ? .automatic : .none
            )
        } else {
            configuration = ModelConfiguration(
                "Ripple",
                schema: RippleSchema.schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )
        }
        return try ModelContainer(for: RippleSchema.schema, configurations: configuration)
    }

    private static func migrateLegacyStoreIfNeeded(
        into destination: ModelContainer,
        appGroup: String
    ) {
        // An extension may have its own old store from before the App Group
        // entitlement existed. Only an app process can own the legacy store
        // that needs migration; never let an extension claim the shared marker.
        guard Bundle.main.bundleURL.pathExtension != "appex" else { return }

        let fileManager = FileManager.default
        guard
            let legacySupportURL = fileManager.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first
        else {
            return
        }

        let legacyURL = legacySupportURL.appendingPathComponent("Ripple.store")
        guard fileManager.fileExists(atPath: legacyURL.path) else { return }
        guard
            let groupURL = fileManager.containerURL(
                forSecurityApplicationGroupIdentifier: appGroup
            )
        else {
            return
        }

        let groupSupportURL = groupURL
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Application Support", isDirectory: true)
        let markerURL = groupSupportURL.appendingPathComponent(migrationMarker)
        guard !fileManager.fileExists(atPath: markerURL.path) else { return }

        do {
            let legacyConfiguration = ModelConfiguration(
                "RippleLegacy",
                schema: RippleSchema.schema,
                url: legacyURL,
                cloudKitDatabase: .none
            )
            let legacy = try ModelContainer(
                for: RippleSchema.schema,
                configurations: legacyConfiguration
            )
            let sourceContext = ModelContext(legacy)
            let destinationContext = ModelContext(destination)

            try copyLegacyRecords(
                from: sourceContext,
                to: destinationContext
            )
            try destinationContext.save()

            try fileManager.createDirectory(
                at: groupSupportURL,
                withIntermediateDirectories: true
            )
            try Data("migrated".utf8).write(to: markerURL, options: .atomic)
        } catch {
            migrationLogger.error(
                "Legacy store migration failed: \(error.localizedDescription, privacy: .public)"
            )
        }
    }

    private static func copyLegacyRecords(
        from source: ModelContext,
        to destination: ModelContext
    ) throws {
        let sourceIntakes = try source.fetch(FetchDescriptor<IntakeRecord>())
        let sourceContainers = try source.fetch(FetchDescriptor<ContainerRecord>())
        let sourceGoals = try source.fetch(FetchDescriptor<GoalSettingsRecord>())
        let sourceProfiles = try source.fetch(FetchDescriptor<ProfileRecord>())
        let sourceReminders = try source.fetch(FetchDescriptor<ReminderRuleRecord>())

        let destinationIntakes = try destination.fetch(FetchDescriptor<IntakeRecord>())
        let destinationContainers = try destination.fetch(FetchDescriptor<ContainerRecord>())
        let destinationGoal = try destination.fetch(FetchDescriptor<GoalSettingsRecord>()).first
        let destinationProfile = try destination.fetch(FetchDescriptor<ProfileRecord>()).first
        let destinationReminder = try destination.fetch(FetchDescriptor<ReminderRuleRecord>()).first
        let destinationIsFresh = destinationIntakes.isEmpty && destinationLooksFresh(
            containers: destinationContainers,
            goal: destinationGoal,
            profile: destinationProfile,
            reminder: destinationReminder
        )

        try mergeIntakes(sourceIntakes, into: destination)
        try mergeContainers(
            sourceContainers,
            into: destination,
            adoptFreshSeededRows: destinationIsFresh
        )
        try mergeGoal(sourceGoals.first, into: destination, preferSource: destinationIsFresh)
        try mergeProfile(sourceProfiles.first, into: destination, preferSource: destinationIsFresh)
        try mergeReminder(sourceReminders.first, into: destination, preferSource: destinationIsFresh)
    }

    private static func destinationLooksFresh(
        containers: [ContainerRecord],
        goal: GoalSettingsRecord?,
        profile: ProfileRecord?,
        reminder: ReminderRuleRecord?
    ) -> Bool {
        let seeded = Container.seededDefaults(locale: .current).sorted { $0.sort < $1.sort }
        let existing = containers.sorted { $0.sort < $1.sort }
        guard existing.count == seeded.count else { return false }
        guard zip(existing, seeded).allSatisfy({
            $0.0.amountMl == $0.1.amountMl
                && $0.0.isDefault == $0.1.isDefault
                && $0.0.sort == $0.1.sort
                && $0.0.symbolName == $0.1.symbolName
        }) else {
            return false
        }

        guard
            let goal,
            goal.modeRaw == GoalMode.manual.rawValue,
            goal.manualGoalMl == 2000,
            let profile,
            profile.preferredUnitRaw == VolumeUnit.milliliters.rawValue,
            profile.bodyMassKg == nil,
            profile.activityLevelRaw == ActivityLevel.sedentary.rawValue,
            profile.wakeHour == 7,
            profile.wakeMinute == 0,
            profile.sleepHour == 22,
            profile.sleepMinute == 0,
            profile.remindersEnabled,
            !profile.healthReadWorkoutsEnabled,
            !profile.healthWriteEnabled,
            profile.hapticsEnabled,
            !profile.onboardingCompleted,
            let reminder,
            reminder.enabled,
            reminder.startHour == 7,
            reminder.startMinute == 0,
            reminder.endHour == 22,
            reminder.endMinute == 0,
            reminder.intervalMinutes == 120,
            reminder.afterLastSipMinutes == 120
        else {
            return false
        }
        return true
    }

    private static func mergeIntakes(
        _ sourceRecords: [IntakeRecord],
        into destination: ModelContext
    ) throws {
        let existing = try destination.fetch(FetchDescriptor<IntakeRecord>())
        var byID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

        for sourceRecord in sourceRecords {
            if let existingRecord = byID[sourceRecord.id] {
                guard sourceRecord.updatedAt > existingRecord.updatedAt else { continue }
                existingRecord.apply(sourceRecord.toDomain())
            } else {
                let record = IntakeRecord()
                record.apply(sourceRecord.toDomain())
                destination.insert(record)
                byID[sourceRecord.id] = record
            }
        }
    }

    private static func mergeContainers(
        _ sourceRecords: [ContainerRecord],
        into destination: ModelContext,
        adoptFreshSeededRows: Bool
    ) throws {
        let existing = try destination.fetch(FetchDescriptor<ContainerRecord>())
        let byID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })
        var seededBySort: [Int: ContainerRecord] = [:]
        if adoptFreshSeededRows {
            seededBySort = Dictionary(uniqueKeysWithValues: existing.map { ($0.sort, $0) })
        }

        for sourceRecord in sourceRecords {
            if let existingRecord = byID[sourceRecord.id] {
                guard adoptFreshSeededRows || sourceRecord.updatedAt > existingRecord.updatedAt else {
                    continue
                }
                existingRecord.apply(sourceRecord.toDomain())
            } else if let existingRecord = seededBySort[sourceRecord.sort] {
                existingRecord.apply(sourceRecord.toDomain())
            } else {
                let record = ContainerRecord()
                record.apply(sourceRecord.toDomain())
                destination.insert(record)
            }
        }
    }

    private static func mergeGoal(
        _ sourceRecord: GoalSettingsRecord?,
        into destination: ModelContext,
        preferSource: Bool
    ) throws {
        guard let sourceRecord else { return }
        let destinationRecord = try destination.fetch(FetchDescriptor<GoalSettingsRecord>()).first
        if let destinationRecord {
            guard preferSource || sourceRecord.updatedAt > destinationRecord.updatedAt else { return }
            destinationRecord.apply(sourceRecord.toDomain())
        } else {
            let record = GoalSettingsRecord()
            record.apply(sourceRecord.toDomain())
            destination.insert(record)
        }
    }

    private static func mergeProfile(
        _ sourceRecord: ProfileRecord?,
        into destination: ModelContext,
        preferSource: Bool
    ) throws {
        guard let sourceRecord else { return }
        let destinationRecord = try destination.fetch(FetchDescriptor<ProfileRecord>()).first
        if let destinationRecord {
            guard preferSource || sourceRecord.updatedAt > destinationRecord.updatedAt else { return }
            destinationRecord.apply(sourceRecord.toDomain())
        } else {
            let record = ProfileRecord()
            record.apply(sourceRecord.toDomain())
            destination.insert(record)
        }
    }

    private static func mergeReminder(
        _ sourceRecord: ReminderRuleRecord?,
        into destination: ModelContext,
        preferSource: Bool
    ) throws {
        guard let sourceRecord else { return }
        let destinationRecord = try destination.fetch(FetchDescriptor<ReminderRuleRecord>()).first
        if let destinationRecord {
            guard preferSource || sourceRecord.updatedAt > destinationRecord.updatedAt else { return }
            destinationRecord.apply(sourceRecord.toDomain())
        } else {
            let record = ReminderRuleRecord()
            record.apply(sourceRecord.toDomain())
            destination.insert(record)
        }
    }

}
