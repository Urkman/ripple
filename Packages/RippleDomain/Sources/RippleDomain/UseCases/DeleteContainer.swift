import Foundation

public struct DeleteContainer: Sendable {
    private let settingsRepository: any SettingsRepository

    public init(settingsRepository: any SettingsRepository) {
        self.settingsRepository = settingsRepository
    }

    public func run(id: UUID) async throws {
        try await settingsRepository.deleteContainer(id: id)
        let remaining = try await settingsRepository.containers()
        if !remaining.contains(where: \.isDefault), var first = remaining.sorted(by: { $0.sort < $1.sort }).first {
            first.isDefault = true
            try await settingsRepository.saveContainer(first)
        }
    }
}
