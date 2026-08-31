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
                .font(.title3.weight(.semibold).monospacedDigit())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(RippleLogButtonStyle(isPrimary: isPrimary))
        .accessibilityLabel(title)
    }
}

struct RippleLogButtonStyle: ButtonStyle {
    var isPrimary: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isPrimary ? Color.white : RippleColor.waterDeep)
            .background(
                Capsule(style: .continuous)
                    .fill(isPrimary ? RippleColor.waterAqua : RippleColor.waterFoam)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .shadow(color: isPrimary ? RippleColor.waterAqua.opacity(configuration.isPressed ? 0.45 : 0) : .clear, radius: 18)
            .animation(RippleMotion.springSnappy, value: configuration.isPressed)
    }
}

#Preview("LogButton") {
    LogButton("+ 250 ml") {}
        .padding()
}
