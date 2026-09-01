import SwiftUI

public extension View {
    @ViewBuilder
    func ripplePickerStyle() -> some View {
        #if os(watchOS)
        self.pickerStyle(.automatic)
        #else
        self.pickerStyle(.menu)
        #endif
    }
}
