import Testing
@testable import RippleUI

@Suite("Responsive layout")
struct ResponsiveLayoutTests {
    @Test("Today hero scales within its readable bounds")
    func todayHeroHeight() {
        #expect(
            RippleLayout.todayHeroHeight(for: 100)
                == RippleLayout.todayHeroMinimumHeight
        )
        #expect(RippleLayout.todayHeroHeight(for: 500) == 310)
        #expect(
            RippleLayout.todayHeroHeight(for: 1_000)
                == RippleLayout.iPadPortraitHeroHeight
        )
    }
}
