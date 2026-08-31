import RippleDomain
import SwiftUI

public extension EnvironmentValues {
    @Entry var rippleUseCases: UseCases = RippleRuntime.preview
    @Entry var rippleHistorySplit: Bool = false
}
