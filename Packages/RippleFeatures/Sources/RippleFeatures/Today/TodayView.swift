import RippleDomain
import RippleUI
import SwiftUI

public struct TodayView: View {
    @Bindable var model: TodayViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.locale) private var locale
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.rippleExpandedLayout) private var usesExpandedLayout
    @State private var gravityTilt = GravityTiltController()
    @State private var showsCustomAmount = false

    public init(model: TodayViewModel) {
        self.model = model
    }

    public var body: some View {
        let formatter = VolumeFormatter(locale: locale)
        let snapshot = model.snapshot
        GeometryReader { proxy in
            Group {
                #if os(iOS)
                if #available(iOS 27.1, *),
                   !proxy.reservedRegions(kind: .division).isEmpty {
                    ArrangementView {
                        arrangedHero(snapshot: snapshot, formatter: formatter)
                    } secondary: {
                        ScrollView {
                            VStack(spacing: RippleSpace.md) {
                                remainingLabel(formatter: formatter)
                                quickAddCluster(snapshot: snapshot, formatter: formatter, layout: .vertical, style: .flat)
                                LogButton(L10n.text("Custom amount"), action: showCustomAmount)
                            }
                            .padding(RippleSpace.lg)
                        }
                    }
                    .arrangementViewStyle(.split)
                } else {
                    standardContent(snapshot: snapshot, formatter: formatter)
                }
                #else
                standardContent(snapshot: snapshot, formatter: formatter)
                #endif
            }
        }
        .padding(.horizontal, RippleLayout.todayContentHorizontalPadding)
        .padding(.bottom, RippleSpace.md)
        .background(RippleColor.waterFoam.ignoresSafeArea())
        .rippleInlineNavigationTitle()
        .navigationTitle(usesExpandedLayout ? "" : "\(L10n.text("Ripple")) · \(formattedDate(snapshot.date))")
        .rippleNavigationBarVisibility(hidden: usesExpandedLayout)
        .overlay(alignment: .bottom) {
            RippleToastHost(
                message: model.confirmation,
                reduceMotion: reduceMotion
            )
            .padding(.horizontal, RippleSpace.lg)
            .padding(.bottom, RippleSpace.xxl)
        }
        .sheet(isPresented: $showsCustomAmount) {
            CustomAmountSheet(
                model: model,
                initialAmountMl: snapshot.defaultAddMl,
                initialAmountText: formatter.valueString(
                    milliliters: snapshot.defaultAddMl,
                    unit: snapshot.unit
                ),
                unit: snapshot.unit
            )
        }
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }
            await model.refresh()
        }
        .sensoryFeedback(.success, trigger: snapshot.consumed.value)
        .onChange(of: snapshot.consumed.value) {
            if reduceMotion {
                model.presentedSnapshot = snapshot
            }
        }
        .rippleMotionScene(gravityTilt)
        .onAppear { syncGravityTilt() }
        .onDisappear { gravityTilt.stop() }
        .onChange(of: scenePhase) { _, _ in syncGravityTilt() }
        .onChange(of: reduceMotion) { _, _ in syncGravityTilt() }
    }

    private func standardContent(snapshot: TodaySnapshot, formatter: VolumeFormatter) -> some View {
        GeometryReader { viewport in
            let heroHeight = RippleLayout.todayHeroHeight(for: viewport.size.height)
            ScrollView {
                Group {
                    if usesSideBySideLayout(for: viewport.size) {
                        landscapeContent(snapshot: snapshot, formatter: formatter)
                    } else {
                        compactContent(
                            snapshot: snapshot,
                            formatter: formatter,
                            heroHeight: heroHeight
                        )
                    }
                }
                .frame(maxWidth: .infinity, minHeight: viewport.size.height, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .safeAreaInset(edge: .bottom, spacing: RippleSpace.sm) {
            LogButton(L10n.text("Custom amount"), action: showCustomAmount)
                .padding(.bottom, RippleSpace.sm)
                .background(RippleColor.waterFoam)
        }
    }

    private func usesSideBySideLayout(for size: CGSize) -> Bool {
        usesExpandedLayout && size.width > size.height
            && size.width >= RippleLayout.todaySideBySideMinimumWidth
    }

    private func syncGravityTilt() {
        #if os(iOS)
        if scenePhase == .active, !reduceMotion {
            gravityTilt.start()
        } else {
            gravityTilt.stop()
        }
        #else
        gravityTilt.stop()
        #endif
    }

    @ViewBuilder
    private func compactContent(
        snapshot: TodaySnapshot,
        formatter: VolumeFormatter,
        heroHeight: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: RippleSpace.md) {
            compactHero(snapshot: snapshot, formatter: formatter, height: heroHeight)
                .padding(.vertical, RippleSpace.xxl)
                .frame(maxWidth: .infinity)

            remainingLabel(formatter: formatter)
            quickAddCluster(
                snapshot: snapshot,
                formatter: formatter,
                style: usesExpandedLayout ? .flat : .glass
            )
        }
    }

    @ViewBuilder
    private func compactHero(
        snapshot: TodaySnapshot,
        formatter: VolumeFormatter,
        height: CGFloat
    ) -> some View {
        if usesExpandedLayout {
            hero(snapshot: snapshot, formatter: formatter, expandsToFit: true)
                .frame(
                    width: RippleLayout.iPadPortraitHeroWidth,
                    height: min(height, RippleLayout.iPadPortraitHeroHeight),
                    alignment: .center
                )
        } else {
            hero(snapshot: snapshot, formatter: formatter, expandsToFit: true)
                .frame(
                    height: height
                )
        }
    }

    private func arrangedHero(snapshot: TodaySnapshot, formatter: VolumeFormatter) -> some View {
        GeometryReader { region in
            let isWideRegion = region.size.width > region.size.height
            let maxWidth = isWideRegion
                ? RippleLayout.iPadLandscapeHeroWidth
                : RippleLayout.iPadPortraitHeroWidth
            let maxHeight = isWideRegion
                ? RippleLayout.iPadLandscapeHeroHeight
                : RippleLayout.iPadPortraitHeroHeight

            hero(snapshot: snapshot, formatter: formatter, expandsToFit: true)
                .frame(maxWidth: maxWidth, maxHeight: maxHeight, alignment: .center)
                .padding(RippleSpace.lg)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    private func landscapeContent(snapshot: TodaySnapshot, formatter: VolumeFormatter) -> some View {
        VStack(spacing: RippleSpace.md) {
            remainingLabel(formatter: formatter)
                .padding(.top, RippleSpace.sm)

            HStack(alignment: .center, spacing: RippleLayout.iPadLandscapeColumnSpacing) {
                hero(snapshot: snapshot, formatter: formatter, expandsToFit: true)
                    .frame(
                        maxWidth: RippleLayout.iPadLandscapeHeroWidth,
                        minHeight: RippleLayout.todayHeroMinimumHeight,
                        maxHeight: RippleLayout.iPadLandscapeHeroHeight,
                        alignment: .center
                    )

                VStack(alignment: .leading, spacing: RippleSpace.md) {
                    quickAddCluster(
                        snapshot: snapshot,
                        formatter: formatter,
                        layout: .vertical,
                        style: .flat
                    )
                }
                .frame(
                    minWidth: RippleLayout.iPadLandscapeActionColumnMinWidth,
                    maxWidth: RippleLayout.iPadLandscapeActionColumnMaxWidth
                )
            }
            .frame(maxWidth: RippleLayout.iPadLandscapeContentMaxWidth, maxHeight: .infinity)
        }
        .frame(maxWidth: RippleLayout.iPadLandscapeContentMaxWidth, maxHeight: .infinity)
    }

    private func hero(
        snapshot: TodaySnapshot,
        formatter: VolumeFormatter,
        expandsToFit: Bool
    ) -> some View {
        RippleHeroView(
            consumedMl: snapshot.consumed.value,
            goalMl: snapshot.goal.value,
            addedMl: model.addedMl,
            phase: model.motion,
            reduceMotion: reduceMotion,
            expandsToFit: expandsToFit,
            tilt: reduceMotion ? 0 : gravityTilt.tilt,
            slosh: reduceMotion ? 0 : gravityTilt.slosh,
            amountText: formatter.valueString(milliliters: snapshot.consumed.value, unit: snapshot.unit),
            unitText: snapshot.unit.symbol,
            percentText: formatter.percentString(snapshot.percent),
            accessibilitySummary: formatter.heroAccessibility(
                consumedMl: snapshot.consumed.value,
                goalMl: snapshot.goal.value,
                remainingMl: snapshot.remaining.value,
                percent: snapshot.percent
            )
        )
    }

    private func remainingLabel(formatter: VolumeFormatter) -> some View {
        let goalText = L10n.text("Goal") + " " + formatter.string(
            milliliters: model.presentedSnapshot.goal.value,
            unit: model.presentedSnapshot.unit
        )
        return RemainingLabel(
            remainingText: formatter.remainingPhrase(
                milliliters: model.presentedSnapshot.remaining.value,
                unit: model.presentedSnapshot.unit
            ),
            goalText: goalText
        )
    }

    private func quickAddCluster(
        snapshot: TodaySnapshot,
        formatter: VolumeFormatter,
        layout: QuickAddCluster.Layout = .horizontal,
        style: ContainerChip.Style = .glass
    ) -> some View {
        QuickAddCluster(
            items: quickAddItems(snapshot: snapshot, formatter: formatter),
            layout: layout,
            style: style
        ) { item in
            addQuickItem(item, from: snapshot)
        }
    }

    private func addQuickItem(_ item: QuickAddItem, from snapshot: TodaySnapshot) {
        guard let container = snapshot.containers.first(where: { $0.id == item.id }) else { return }
        Task { await model.add(container: container) }
    }

    private func showCustomAmount() {
        showsCustomAmount = true
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide).day().month(.abbreviated))
    }

    private func quickAddItems(snapshot: TodaySnapshot, formatter: VolumeFormatter) -> [QuickAddItem] {
        snapshot.containers.prefix(3).map {
            QuickAddItem(
                id: $0.id,
                name: $0.name,
                amount: formatter.string(milliliters: $0.amountMl, unit: snapshot.unit),
                symbolName: $0.symbolName
            )
        }
    }
}

#Preview("Today") {
    NavigationStack {
        TodayView(model: TodayViewModel(useCases: RippleRuntime.preview, snapshot: .empty()))
    }
}

#Preview("Today iPad") {
    NavigationStack {
        TodayView(model: TodayViewModel(useCases: RippleRuntime.preview, snapshot: .empty()))
    }
    .environment(\.rippleExpandedLayout, true)
}

#Preview("Today iPad · Dark XXXL · Reduce Motion") {
    NavigationStack {
        TodayView(model: TodayViewModel(useCases: RippleRuntime.preview, snapshot: .empty()))
    }
    .environment(\.rippleExpandedLayout, true)
    .dynamicTypeSize(.accessibility3)
    .preferredColorScheme(.dark)
}
