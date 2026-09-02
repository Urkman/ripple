import SwiftUI

public struct WatchLogButton: View {
    public var title: String
    public var isEnabled: Bool
    public var font: Font
    public var accessibilityLabel: String?
    public var action: () -> Void

    public init(
        title: String,
        isEnabled: Bool = true,
        action: @escaping () -> Void,
        font: Font = RippleFont.callout.weight(.semibold).monospacedDigit(),
        accessibilityLabel: String? = nil
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.font = font
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)
                .frame(maxWidth: .infinity, minHeight: RippleWatchLayout.controlHeight)
                .padding(.horizontal, RippleSpace.md)
        }
        .buttonStyle(WatchLogButtonStyle(isEnabled: isEnabled))
        .disabled(!isEnabled)
        .accessibilityLabel(accessibilityLabel ?? title)
    }
}

private struct WatchLogButtonStyle: ButtonStyle {
    var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.white)
            .background(
                RoundedRectangle(cornerRadius: RippleRadius.control, style: .continuous)
                    .fill(RippleColor.watchLagoon.opacity(isEnabled ? 1 : 0.45))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(RippleMotion.springSnappy, value: configuration.isPressed)
    }
}

#Preview("Watch Log Button") {
    WatchLogButton(title: "Add 250 ml") {}
        .padding()
}

#Preview("Watch Log Button · Dark · XXXL") {
    WatchLogButton(title: "Add 250 ml") {}
        .padding()
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility3)
}
