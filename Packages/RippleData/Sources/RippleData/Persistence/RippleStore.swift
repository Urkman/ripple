import Foundation
import RippleDomain
import SwiftData

@ModelActor
public actor RippleStore {
    public func saveIntake(_ intake: Intake) throws {
        if let existing = try fetchIntake(id: intake.id) {
            existing.apply(intake)
        } else {
            let record = IntakeRecord()
            record.apply(intake)
            modelContext.insert(record)
        }
        try modelContext.save()
    }

    public func updateIntake(_ intake: Intake) throws {
        try saveIntake(intake)
    }

    public func intake(id: UUID) throws -> Intake? {
        try fetchIntake(id: id)?.toDomain()
    }

    public func intakes(from start: Date, to end: Date) throws -> [Intake] {
        let descriptor = FetchDescriptor<IntakeRecord>(
            predicate: #Predicate { record in
                record.date >= start && record.date < end
            },
            sortBy: [SortDescriptor(\.date)]
        )
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    public func firstUndeletedIntake() throws -> Intake? {
        var descriptor = FetchDescriptor<IntakeRecord>(
            predicate: #Predicate { record in
                record.isDeleted == false
            },
            sortBy: [SortDescriptor(\.date)]
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first?.toDomain()
    }

    public func monthSummaries(
        from start: Date,
        to end: Date,
        goalMl: Int,
        calendar: Calendar
    ) throws -> [DaySummary] {
        let intakes = try intakes(from: start, to: end)
        return HistoryAggregator.daySummaries(
            intakes: intakes,
            rangeStart: start,
            rangeEnd: end,
            goalMl: goalMl,
            calendar: calendar
        )
    }

    public func statsSnapshot(
        from start: Date,
        to end: Date,
        goalMl: Int,
        calendar: Calendar,
        now: Date
    ) throws -> StatsSnapshot {
        let intakes = try intakes(from: start, to: end)
        return HistoryAggregator.stats(
            intakes: intakes,
            rangeStart: start,
            rangeEnd: end,
            goalMl: goalMl,
            calendar: calendar,
            now: now
        )
    }

    public func lastUndeletedIntake() throws -> Intake? {
        var descriptor = FetchDescriptor<IntakeRecord>(
            predicate: #Predicate { record in
                record.isDeleted == false
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first?.toDomain()
    }

    public func profile() throws -> Profile {
        try fetchOrInsertProfile().toDomain()
    }

    public func saveProfile(_ profile: Profile) throws {
        let record = try fetchOrInsertProfile()
        record.apply(profile)
        try modelContext.save()
    }

    public func goalSettings() throws -> GoalSettings {
        try fetchOrInsertGoal().toDomain()
    }

    public func saveGoalSettings(_ settings: GoalSettings) throws {
        let record = try fetchOrInsertGoal()
        if settings.updatedAt < record.updatedAt {
            return
        }
        record.apply(settings)
        try modelContext.save()
    }

    public func containers() throws -> [Container] {
        let descriptor = FetchDescriptor<ContainerRecord>(
            sortBy: [SortDescriptor(\.sort)]
        )
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    public func saveContainer(_ container: Container) throws {
        if let existing = try fetchContainer(id: container.id) {
            existing.apply(container)
        } else {
            let record = ContainerRecord()
            record.apply(container)
            modelContext.insert(record)
        }
        try modelContext.save()
    }

    public func deleteContainer(id: UUID) throws {
        if let existing = try fetchContainer(id: id) {
            modelContext.delete(existing)
            try modelContext.save()
        }
    }

    public func reminderRule() throws -> ReminderRule {
        try fetchOrInsertReminder().toDomain()
    }

    public func saveReminderRule(_ rule: ReminderRule) throws {
        let record = try fetchOrInsertReminder()
        record.apply(rule)
        try modelContext.save()
    }

    public func seedDefaultsIfNeeded(locale: Locale) throws {
        let existing = try containers()
        if existing.isEmpty {
            for container in Container.seededDefaults(locale: locale) {
                try saveContainer(container)
            }
        }
        _ = try fetchOrInsertProfile()
        _ = try fetchOrInsertGoal()
        _ = try fetchOrInsertReminder()
        try modelContext.save()
    }

    private func fetchIntake(id: UUID) throws -> IntakeRecord? {
        var descriptor = FetchDescriptor<IntakeRecord>(
            predicate: #Predicate { record in
                record.id == id
            }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    private func fetchContainer(id: UUID) throws -> ContainerRecord? {
        var descriptor = FetchDescriptor<ContainerRecord>(
            predicate: #Predicate { record in
                record.id == id
            }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    private func fetchOrInsertProfile() throws -> ProfileRecord {
        let descriptor = FetchDescriptor<ProfileRecord>()
        if let existing = try modelContext.fetch(descriptor).first {
            return existing
        }
        let record = ProfileRecord()
        modelContext.insert(record)
        return record
    }

    private func fetchOrInsertGoal() throws -> GoalSettingsRecord {
        let descriptor = FetchDescriptor<GoalSettingsRecord>()
        if let existing = try modelContext.fetch(descriptor).first {
            return existing
        }
        let record = GoalSettingsRecord()
        modelContext.insert(record)
        return record
    }

    private func fetchOrInsertReminder() throws -> ReminderRuleRecord {
        let descriptor = FetchDescriptor<ReminderRuleRecord>()
        if let existing = try modelContext.fetch(descriptor).first {
            return existing
        }
        let record = ReminderRuleRecord()
        modelContext.insert(record)
        return record
    }
}
