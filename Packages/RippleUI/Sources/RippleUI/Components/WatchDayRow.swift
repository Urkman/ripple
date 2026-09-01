import SwiftUI

public struct WatchDayRow: View {
    public var title: String
    public var subtitle: String
    public var amountText: String
    public var progress: Double
    public var statusText: String

    public init(
        title: String,
        subtitle: String,
        amountText: String,
        progress: Double,
        statusText: String
    ) {
        self.title = title
        self.subtitle = subtitle
        self.amountText = amountText
        self.progress = progress
        self.statusText = statusText
    }

    public var body: some View {
        HStack(spacing: RippleSpace.sm) {
            VStack(alignment: .leading, spacing: RippleWatchLayout.todayContentSpacing) {
                HStack(alignment: .firstTextBaseline, spacing: RippleSpace.sm) {
                    Text(title)
                        .font(RippleFont.body.weight(.semibold))
                        .lineLimit(1)
                    Spacer(minLength: RippleSpace.xs)
                    Text(amountText)
                        .font(RippleFont.callout.monospacedDigit())
                        .lineLimit(1)
                }

                Text(subtitle)
                    .font(RippleFont.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                GeometryReader { proxy in
                    let clampedProgress = min(max(progress, 0), 1)
                    ZStack(alignment: .leading) {
                        Capsule(style: .continuous)
                            .fill(RippleColor.waterDeep.opacity(0.14))
                        Capsule(style: .continuous)
                            .fill(RippleColor.waterAqua)
                            .frame(width: proxy.size.width * clampedProgress)
                    }
                }
                .frame(height: RippleSpace.xs)
            }

            Image(systemName: "chevron.right")
                .font(RippleFont.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, RippleSpace.sm)
        .accessibilityElement(children: .combine)
        .accessibilityValue(statusText)
    }
}

#Preview("Watch Day Row") {
    WatchDayRow(
        title: "Today",
        subtitle: "1 Sep",
        amountText: "1,250 ml",
        progress: 0.625,
        statusText: "1,250 ml of 2,000 ml"
    )
    .padding()
}

#Preview("Watch Day Row · Dark · XXXL") {
    WatchDayRow(
        title: "Monday",
        subtitle: "1 Sep",
        amountText: "1,250 ml",
        progress: 0.625,
        statusText: "1,250 ml of 2,000 ml"
    )
    .padding()
    .preferredColorScheme(.dark)
    .dynamicTypeSize(.accessibility3)
}
