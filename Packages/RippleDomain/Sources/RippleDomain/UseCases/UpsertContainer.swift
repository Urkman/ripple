import Foundation

public struct UpsertContainer: Sendable {
    private let settingsRepository: any SettingsRepository

    public init(settingsRepository: any SettingsRepository) {
        self.settingsRepository = settingsRepository
    }

    public func run(_ container: Container) async throws {
        var value = container
        value.updatedAt = Date()
        if value.isDefault {
            let existing = try await settingsRepository.containers()
            for var other in existing where other.id != value.id && other.isDefault {
                other.isDefault = false
                other.updatedAt = Date()
                try await settingsRepository.saveContainer(other)
            }
        }
        try await settingsRepository.saveContainer(value)
    }
}
