import SwiftUI

public extension View {
    @ViewBuilder
    func rippleInlineNavigationTitle() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}
