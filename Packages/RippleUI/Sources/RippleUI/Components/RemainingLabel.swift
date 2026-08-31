import SwiftUI

public struct RemainingLabel: View {
    public var remainingText: String
    public var goalText: String

    public init(remainingText: String, goalText: String) {
        self.remainingText = remainingText
        self.goalText = goalText
    }

    public var body: some View {
        Text("\(remainingText) · \(goalText)")
            .font(.callout.monospacedDigit())
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .accessibilityLabel("\(remainingText). \(goalText)")
    }
}
