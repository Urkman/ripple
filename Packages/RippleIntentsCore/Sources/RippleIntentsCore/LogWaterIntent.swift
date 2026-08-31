import AppIntents
import Foundation
import RippleDomain
#if os(iOS)
import ActivityKit
#endif

public struct LogWaterIntent: AppIntent {
    public static let title: LocalizedStringResource = "Log Water"
    public static let description = IntentDescription("Log a drink in Ripple")
    public static let openAppWhenRun = false

    @Parameter(title: "Amount in milliliters")
    public var milliliters: Int?

    @Parameter(title: "Amount in fluid ounces")
    public var fluidOunces: Double?

    @Parameter(title: "Container")
    public var container: ContainerEntity?

    public var intakeSource: IntakeSource = .intent

    public init() {}

    public init(milliliters: Int, source: IntakeSource = .intent) {
        self.milliliters = milliliters
        self.intakeSource = source
    }

    public static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$milliliters) in Ripple")
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let useCases = RippleRuntime.current
        let amount = try await resolvedAmount(useCases: useCases)
        let source: IntakeSource
        if milliliters == nil && fluidOunces == nil && container == nil {
            source = .control
        } else {
            source = intakeSource
        }
        _ = try await useCases.logIntake.run(
            amount: Milliliters(amount),
            source: source,
            containerId: container?.id
        )
        let snapshot = try await useCases.observeToday.snapshot(for: Date())
        let dialog = Self.successDialog(logged: amount, snapshot: snapshot)
        return .result(dialog: dialog)
    }

    private func resolvedAmount(useCases: UseCases) async throws -> Int {
        if let milliliters {
            return milliliters
        }
        if let fluidOunces {
            return UnitConverter.milliliters(fromFluidOunces: fluidOunces)
        }
        if let container {
            return container.amountMl
        }
        let snapshot = try await useCases.observeToday.snapshot(for: Date())
        return snapshot.defaultAddMl
    }

    public static func successDialog(logged: Int, snapshot: TodaySnapshot) -> IntentDialog {
        let formatter = VolumeFormatter()
        let loggedText = formatter.string(milliliters: logged, unit: snapshot.unit)
        if snapshot.remaining.value == 0 {
            return IntentDialog("All set, \(loggedText) are in. You are in the flow today.")
        }
        let remainingSpeech = formatter.litersSpeech(milliliters: snapshot.remaining.value)
        return IntentDialog("All set, \(loggedText) are in. \(remainingSpeech) left to the goal.")
    }
}

public struct LogDefaultWaterIntent: AppIntent {
    public static let title: LocalizedStringResource = "Log Default Water"
    public static let openAppWhenRun = false

    public init() {}

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let intent = LogWaterIntent()
        return try await intent.perform()
    }
}

#if os(iOS)
extension LogWaterIntent: LiveActivityIntent {}
extension LogDefaultWaterIntent: LiveActivityIntent {}
#endif
