import SwiftUI

public struct LogButton: View {
    public var title: String
    public var isPrimary: Bool
    public var action: () -> Void

    public init(_ title: String, isPrimary: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isPrimary = isPrimary
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(RippleFont.action)
                .frame(maxWidth: .infinity)
                .padding(.vertical, RippleSpace.lg)
        }
        .buttonStyle(RippleLogButtonStyle(isPrimary: isPrimary))
        .accessibilityLabel(title)
    }
}

struct RippleLogButtonStyle: ButtonStyle {
    var isPrimary: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isPrimary ? RippleColor.onAction : RippleColor.waterDeep)
            .background(
                Capsule(style: .continuous)
                    .fill(isPrimary ? RippleColor.waterAqua : RippleColor.waterFoam)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(RippleMotion.springSnappy, value: configuration.isPressed)
    }
}

#Preview("LogButton") {
    LogButton("+ 250 ml") {}
        .padding()
}
