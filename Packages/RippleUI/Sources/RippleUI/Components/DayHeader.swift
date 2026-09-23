import SwiftUI

public struct DayHeader: View {
    public var title: String
    public var subtitle: String

    public init(title: String = "Ripple", subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: RippleSpace.grid) {
            Text(title)
                .font(RippleFont.sectionTitle)
                .foregroundStyle(RippleColor.waterDeep)
            Text(subtitle)
                .font(RippleFont.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
