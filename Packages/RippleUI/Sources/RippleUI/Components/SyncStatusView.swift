import SwiftUI

public struct SyncStatusView: View {
    public var title: String
    public var detail: String
    public var systemImage: String

    public init(title: String, detail: String, systemImage: String) {
        self.title = title
        self.detail = detail
        self.systemImage = systemImage
    }

    public var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(RippleColor.waterLagoon)
        }
        .accessibilityElement(children: .combine)
    }
}
