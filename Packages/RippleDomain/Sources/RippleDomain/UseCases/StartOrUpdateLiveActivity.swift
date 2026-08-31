import Foundation

public struct StartOrUpdateLiveActivity: Sendable {
    private let liveActivity: any LiveActivityControlling
    private let observeToday: ObserveToday
    private let settingsRepository: any SettingsRepository

    public init(
        liveActivity: any LiveActivityControlling,
        observeToday: ObserveToday,
        settingsRepository: any SettingsRepository
    ) {
        self.liveActivity = liveActivity
        self.observeToday = observeToday
        self.settingsRepository = settingsRepository
    }

    public func run(date: Date = Date()) async throws {
        let profile = try await settingsRepository.profile()
        guard profile.liveActivityEnabled else { return }
        let snapshot = try await observeToday.snapshot(for: date)
        await liveActivity.startOrUpdate(snapshot)
    }
}
