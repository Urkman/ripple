import SwiftUI

public struct RippleToastAction {
    public let title: String
    private let handler: () -> Void

    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.handler = action
    }

    fileprivate func invoke() {
        handler()
    }
}

public struct RippleToast: View {
    public let message: String
    private let action: RippleToastAction?

    public init(message: String, action: RippleToastAction? = nil) {
        self.message = message
        self.action = action
    }

    public var body: some View {
        Group {
            if let action {
                HStack(alignment: .center, spacing: RippleSpace.md) {
                    messageText(alignment: .leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action.title) {
                        action.invoke()
                    }
                    .font(RippleFont.callout.weight(.semibold))
                    .foregroundStyle(RippleColor.waterLagoon)
                }
                .accessibilityElement(children: .contain)
            } else {
                messageText(alignment: .center)
            }
        }
        .padding(.horizontal, RippleSpace.lg)
        .padding(.vertical, RippleSpace.sm)
        .rippleGlass(cornerRadius: RippleRadius.control)
    }

    private func messageText(alignment: TextAlignment) -> some View {
        Text(message)
            .font(RippleFont.callout.weight(.semibold))
            .foregroundStyle(RippleColor.waterDeep)
            .multilineTextAlignment(alignment)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(message)
            .accessibilityAddTraits(.isStaticText)
    }
}

public struct RippleToastHost: View {
    public let message: String?
    public let action: RippleToastAction?
    public let reduceMotion: Bool

    public init(
        message: String?,
        action: RippleToastAction? = nil,
        reduceMotion: Bool
    ) {
        self.message = message
        self.action = action
        self.reduceMotion = reduceMotion
    }

    public var body: some View {
        Group {
            if let message {
                RippleToast(message: message, action: action)
                    .transition(
                        reduceMotion
                            ? .opacity
                            : .move(edge: .bottom).combined(with: .opacity)
                    )
            }
        }
        .animation(
            reduceMotion
                ? .easeInOut(duration: RippleMotion.reduceMotionCrossfade)
                : .easeOut(duration: RippleMotion.confirmFade),
            value: message
        )
        .allowsHitTesting(action != nil)
    }
}

#Preview("RippleToast") {
    RippleToast(message: "+500 ml · nice Ripple.")
        .padding()
        .background(RippleColor.waterFoam)
}

#Preview("RippleToast · Deleted / Undo") {
    RippleToast(
        message: "Deleted",
        action: RippleToastAction(title: "Undo") {}
    )
    .padding()
    .background(RippleColor.waterFoam)
}

#Preview("RippleToast · Dark XXXL · Reduce Motion") {
    RippleToast(message: "+500 ml · schöner Ripple.")
        .padding()
        .background(RippleColor.waterFoam)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility3)
}
