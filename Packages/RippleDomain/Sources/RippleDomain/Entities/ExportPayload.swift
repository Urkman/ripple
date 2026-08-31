import Foundation

public struct ExportPayload: Sendable, Equatable {
    public var json: Data
    public var csv: Data
    public var suggestedJSONName: String
    public var suggestedCSVName: String

    public init(json: Data, csv: Data, suggestedJSONName: String, suggestedCSVName: String) {
        self.json = json
        self.csv = csv
        self.suggestedJSONName = suggestedJSONName
        self.suggestedCSVName = suggestedCSVName
    }
}
