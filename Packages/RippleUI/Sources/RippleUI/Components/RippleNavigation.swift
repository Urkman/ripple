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

    @ViewBuilder
    func rippleNavigationBarVisibility(hidden: Bool) -> some View {
        #if os(iOS)
        self.toolbarVisibility(hidden ? .hidden : .automatic, for: .navigationBar)
        #else
        self
        #endif
    }

    @ViewBuilder
    func rippleNavigationBarBackground(_ color: Color) -> some View {
        #if os(iOS)
        self.toolbarBackground(color, for: .navigationBar)
        #else
        self
        #endif
    }

    @ViewBuilder
    func rippleNavigationBarBackgroundHidden() -> some View {
        #if os(iOS)
        self.toolbarBackground(.hidden, for: .navigationBar)
        #else
        self
        #endif
    }

    @ViewBuilder
    func rippleSidebarToggleHidden() -> some View {
        #if os(iOS)
        self.toolbar(removing: .sidebarToggle)
        #else
        self
        #endif
    }
}
