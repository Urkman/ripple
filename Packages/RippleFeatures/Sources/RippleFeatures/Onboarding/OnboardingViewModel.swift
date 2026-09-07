import Foundation
import Observation
import RippleDomain

public enum HealthWeightState: Sendable, Equatable {
    case idle
    case loading
    case found
    case unavailable
}

@MainActor
@Observable
public final class OnboardingViewModel {
    public var page = 0
    public let pageCount = 6
    public var profile: Profile
    public var weightText = ""
    public var healthWeightKg: Double?
    public var healthWeightState: HealthWeightState = .idle
    public var healthWrite = false
    public var notificationStatus: NotificationAuthorizationStatus = .notDetermined
    public private(set) var isRequestingHealthAccess = false
    public private(set) var isRequestingNotifications = false
    public private(set) var isFinishing = false

    @ObservationIgnored private let useCases: UseCases

    public init(useCases: UseCases) {
        self.useCases = useCases
        self.profile = .fresh()
    }

    public var canSkip: Bool {
        page != 1 && page != 2 && page != pageCount - 1
    }

    public var goalUsesWeight: Bool {
        parsedWeightKg != nil || healthWeightKg != nil
    }

    public var calculatedGoalMl: Int {
        var candidate = profile
        candidate.bodyMassKg = parsedWeightKg ?? healthWeightKg
        return useCases.calculateGoal.run(profile: candidate, workoutMinutes: 0).value
    }

    public func requestHealthAccess() async {
        guard !isRequestingHealthAccess else { return }
        isRequestingHealthAccess = true
        healthWeightState = .loading
        defer { isRequestingHealthAccess = false }

        let access = await useCases.requestHealthOnboardingAccess.run()
        healthWrite = access.waterWriteAuthorized

        guard let kilograms = access.bodyMassKg else {
            healthWeightKg = nil
            healthWeightState = .unavailable
            if parsedWeightKg == nil {
                profile.bodyMassKg = nil
            }
            return
        }

        healthWeightKg = kilograms
        profile.bodyMassKg = kilograms
        weightText = Self.weightString(kilograms)
        healthWeightState = .found
    }

    public func refreshNotificationStatus() async {
        notificationStatus = await useCases.requestNotificationAuthorization.status()
    }

    public func requestNotifications() async {
        guard !isRequestingNotifications else { return }
        isRequestingNotifications = true
        defer { isRequestingNotifications = false }
        notificationStatus = await useCases.requestNotificationAuthorization.run()
    }

    public func finish() async {
        guard !isFinishing else { return }
        isFinishing = true
        defer { isFinishing = false }

        if let kilograms = parsedWeightKg ?? healthWeightKg {
            profile.bodyMassKg = kilograms
        } else {
            profile.bodyMassKg = nil
        }
        profile.healthWriteEnabled = healthWrite
        profile.remindersEnabled = notificationStatus.isAllowed
        profile.onboardingCompleted = true

        try? await useCases.settingsRepository.seedDefaultsIfNeeded(locale: .current)
        try? await useCases.updateProfile.run(profile)

        if profile.bodyMassKg != nil {
            try? await useCases.updateGoal.run(mode: .calculated)
        } else {
            try? await useCases.updateGoal.run(mode: .manual, manualGoalMl: 2000)
        }

        var rule = (try? await useCases.settingsRepository.reminderRule()) ?? .default
        rule.enabled = notificationStatus.isAllowed
        try? await useCases.settingsRepository.saveReminderRule(rule)
        try? await useCases.rescheduleReminders.run()
    }

    private var parsedWeightKg: Double? {
        let normalized = weightText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard !normalized.isEmpty,
              let value = Double(normalized),
              value.isFinite,
              value > 0 else {
            return nil
        }
        return value
    }

    private static func weightString(_ kilograms: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: kilograms)) ?? "\(kilograms)"
    }
}
