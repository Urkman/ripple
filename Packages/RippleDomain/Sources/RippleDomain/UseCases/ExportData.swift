import Foundation

public struct ExportData: Sendable {
    private let intakeRepository: any IntakeRepository
    private let settingsRepository: any SettingsRepository

    public init(
        intakeRepository: any IntakeRepository,
        settingsRepository: any SettingsRepository
    ) {
        self.intakeRepository = intakeRepository
        self.settingsRepository = settingsRepository
    }

    public func run(now: Date = Date()) async throws -> ExportPayload {
        let start = Date(timeIntervalSince1970: 0)
        let end = now.addingTimeInterval(86_400)
        let intakes = try await intakeRepository.intakes(from: start, to: end)
        let profile = try await settingsRepository.profile()
        let goal = try await settingsRepository.goalSettings()
        let containers = try await settingsRepository.containers()

        let document = ExportDocument(
            exportedAt: now,
            profile: profile,
            goal: goal,
            containers: containers,
            intakes: intakes
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let json = try encoder.encode(document)

        var csv = "date,ml,source\n"
        let iso = ISO8601DateFormatter()
        for intake in intakes where !intake.isDeleted {
            csv += "\(iso.string(from: intake.date)),\(intake.amountMl),\(intake.source.rawValue)\n"
        }

        let stamp = iso.string(from: now).replacingOccurrences(of: ":", with: "-")
        return ExportPayload(
            json: json,
            csv: Data(csv.utf8),
            suggestedJSONName: "ripple-\(stamp).json",
            suggestedCSVName: "ripple-\(stamp).csv"
        )
    }
}

private struct ExportDocument: Encodable, Sendable {
    var exportedAt: Date
    var profile: Profile
    var goal: GoalSettings
    var containers: [Container]
    var intakes: [Intake]
}
