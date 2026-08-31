import Foundation
import RippleDomain
import SwiftData

public struct SharedContainer: Sendable {
    public let modelContainer: ModelContainer
    public let syncStatus: SyncStatus

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
                return SharedContainer(modelContainer: cloud, syncStatus: .available)
            }

            if let local = try? makeConfiguration(
                appGroup: appGroup,
                cloudKit: false,
                inMemory: false
            ) {
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
}
