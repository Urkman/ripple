import RippleDomain
import RippleUI
import SwiftUI

public struct TodayView: View {
    @Bindable var model: TodayViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.locale) private var locale
    @Environment(\.scenePhase) private var scenePhase
    @State private var gravityTilt = GravityTiltController()
    @State private var showsCustomAmount = false

    public init(model: TodayViewModel) {
        self.model = model
    }

    public var body: some View {
        let formatter = VolumeFormatter(locale: locale)
        let snapshot = model.snapshot
        VStack(alignment: .leading, spacing: RippleSpace.md) {
            RippleHeroView(
                consumedMl: snapshot.consumed.value,
                goalMl: snapshot.goal.value,
                addedMl: model.addedMl,
                phase: model.motion,
                reduceMotion: reduceMotion,
                expandsToFit: true,
                tilt: reduceMotion ? 0 : gravityTilt.tilt,
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
            .padding(.vertical, RippleSpace.xxl)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .layoutPriority(1)

            RemainingLabel(
                remainingText: formatter.remainingPhrase(milliliters: model.presentedSnapshot.remaining.value, unit: model.presentedSnapshot.unit),
                goalText: "\(L10n.text("Goal")) \(formatter.string(milliliters: model.presentedSnapshot.goal.value, unit: model.presentedSnapshot.unit))"
            )

            Text(model.confirmation ?? "")
                .font(.callout)
                .foregroundStyle(RippleColor.waterLagoon)
                .opacity(model.confirmation == nil ? 0 : 1)
                .frame(maxWidth: .infinity)
                .frame(height: model.confirmation == nil ? 0 : 22)
                .accessibilityHidden(model.confirmation == nil)

            QuickAddCluster(items: quickAddItems(snapshot: snapshot, formatter: formatter)) { item in
                if let container = snapshot.containers.first(where: { $0.id == item.id }) {
                    Task { await model.add(container: container) }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 20)
        .padding(.bottom, RippleSpace.md)
        .background(RippleColor.waterFoam.ignoresSafeArea())
        .rippleInlineNavigationTitle()
        .navigationTitle("\(L10n.text("Ripple")) · \(formattedDate(snapshot.date))")
        .safeAreaInset(edge: .bottom, spacing: RippleSpace.sm) {
            LogButton(L10n.text("Custom amount"), action: {
                showsCustomAmount = true
            })
            .padding(.horizontal, 20)
            .padding(.bottom, RippleSpace.sm)
            .background(RippleColor.waterFoam)
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
        .animation(.easeOut(duration: RippleMotion.confirmFade), value: model.confirmation)
        .onChange(of: snapshot.consumed.value) {
            if reduceMotion {
                model.presentedSnapshot = snapshot
            }
        }
        .onAppear { syncGravityTilt() }
        .onDisappear { gravityTilt.stop() }
        .onChange(of: scenePhase) { _, _ in syncGravityTilt() }
        .onChange(of: reduceMotion) { _, _ in syncGravityTilt() }
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
