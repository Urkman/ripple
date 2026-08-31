import SwiftUI

public struct EmptyState: View {
    public var title: String
    public var systemImage: String

    public init(title: String, systemImage: String = "drop") {
        self.title = title
        self.systemImage = systemImage
    }

    public var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        }
        .foregroundStyle(RippleColor.waterDeep)
    }
}
