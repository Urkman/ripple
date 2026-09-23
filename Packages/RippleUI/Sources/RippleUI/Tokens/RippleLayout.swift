import SwiftUI

public enum RippleLayout {
    public static let minimumControlDimension: CGFloat = 44
    public static let expandedLayoutMinimumWidth: CGFloat = 500
    public static let iPadLandscapeContentMaxWidth: CGFloat = 960
    public static let iPadLandscapeHeroWidth: CGFloat = 240
    public static let iPadLandscapeHeroHeight: CGFloat = 336
    public static let iPadPortraitHeroWidth: CGFloat = 280
    public static let iPadPortraitHeroHeight: CGFloat = 392
    public static let iPadLandscapeActionColumnMinWidth: CGFloat = 240
    public static let iPadLandscapeActionColumnMaxWidth: CGFloat = 320
    public static let iPadLandscapeColumnSpacing: CGFloat = 32
    public static let adaptivePanelMinimumWidth: CGFloat = 320
    public static let statsSummaryMaxWidth: CGFloat = 720
    public static let todayContentHorizontalPadding: CGFloat = 20
    public static let todayHeroMinimumHeight: CGFloat = 168
    public static let todayHeroAvailableHeightFraction: CGFloat = 0.62
    public static let todaySideBySideMinimumWidth = iPadLandscapeHeroWidth
        + iPadLandscapeColumnSpacing + iPadLandscapeActionColumnMinWidth
    public static let historySplitMinimumWidth = iPadHistoryColumnMinWidth
        + iPadHistoryDividerWidth + iPadHistoryColumnMinWidth
    public static let amountStepperValueMinimumWidth: CGFloat = 120

    public static func todayHeroHeight(for availableHeight: CGFloat) -> CGFloat {
        min(
            iPadPortraitHeroHeight,
            max(todayHeroMinimumHeight, availableHeight * todayHeroAvailableHeightFraction)
        )
    }
    public static let onboardingArtworkWidth: CGFloat = 180
    public static let onboardingArtworkHeight: CGFloat = 252
    public static let customAmountContainerChipMinimumWidth: CGFloat = 156

    public static let visionWindowMinWidth: CGFloat = 720
    public static let visionWindowIdealWidth: CGFloat = 820
    public static let visionWindowMaxWidth: CGFloat = 960
    public static let visionWindowMinHeight: CGFloat = 440
    public static let visionWindowIdealHeight: CGFloat = 520
    public static let visionWindowMaxHeight: CGFloat = 620
    public static let visionHeroWidth: CGFloat = 220
    public static let visionHeroHeight: CGFloat = 308
    public static let visionOrnamentTargetMinSize: CGFloat = 60
    public static let visionOrnamentDividerWidth: CGFloat = RippleStroke.standard
    public static let visionOrnamentDividerHeight: CGFloat = 20

    public static let macWindowMinimumWidth: CGFloat = 720
    public static let macWindowMinimumHeight: CGFloat = 520
    public static let tvRootContentPadding: CGFloat = 60

    public static let iPadHistoryColumnMinWidth: CGFloat = 320
    public static let iPadHistoryColumnIdealWidth: CGFloat = 336
    public static let iPadHistoryColumnMaxWidth: CGFloat = 360
    public static let iPadHistoryDividerWidth: CGFloat = 1
}
