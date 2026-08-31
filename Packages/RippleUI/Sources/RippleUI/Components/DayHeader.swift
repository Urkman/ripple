import SwiftUI

public struct DayHeader: View {
    public var title: String
    public var subtitle: String

    public init(title: String = "Ripple", subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(RippleColor.waterDeep)
            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
