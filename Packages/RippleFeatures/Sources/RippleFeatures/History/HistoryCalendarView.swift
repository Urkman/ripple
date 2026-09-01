#if os(iOS) || os(macOS) || os(visionOS)
import RippleDomain
import RippleUI
import SwiftUI

public struct HistoryCalendarView: View {
    @Bindable private var model: HistoryViewModel
    private let todayModel: TodayViewModel
    @Environment(\.rippleUseCases) private var useCases
    @Environment(\.locale) private var locale
    @Environment(\.rippleHistorySplit) private var usesSplit
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pagerPosition: Date?
    @State private var scrollPhase: ScrollPhase = .idle
    @State private var compactSelectedDay: Date?
    @State private var showsCustomAmount = false
    @State private var detailRefreshID = 0

    public init(model: HistoryViewModel, todayModel: TodayViewModel) {
        self.model = model
        self.todayModel = todayModel
        let initialMonth = model.month(atOffset: 0)
        _pagerPosition = State(initialValue: initialMonth)
    }

    public var body: some View {
        if usesSplit {
            iPadHistoryScreen
        } else {
            iPhoneHistoryScreen
        }
    }

    private var iPhoneHistoryScreen: some View {
        NavigationStack {
            calendar
                .navigationTitle(L10n.text("History"))
                .rippleNavigationBarBackground(RippleColor.waterFoam)
                .navigationDestination(item: $compactSelectedDay) { day in
                    DayDetailView(day: day, useCases: useCases, refreshID: detailRefreshID)
                }
                .toolbar { calendarToolbar }
                .sheet(isPresented: $showsCustomAmount, onDismiss: refreshAfterCustomAmount) {
                    customAmountSheet
                }
        }
    }

    private var iPadHistoryScreen: some View {
        HStack(spacing: 0) {
            calendar
                .frame(
                    minWidth: RippleLayout.iPadHistoryColumnMinWidth,
                    idealWidth: RippleLayout.iPadHistoryColumnIdealWidth,
                    maxWidth: RippleLayout.iPadHistoryColumnMaxWidth,
                    maxHeight: .infinity,
                    alignment: .top
                )

            Rectangle()
                .fill(RippleColor.waterDeep.opacity(0.12))
                .frame(width: RippleLayout.iPadHistoryDividerWidth)
                .allowsHitTesting(false)

            iPadDetailPane
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(RippleColor.waterFoam.ignoresSafeArea())
        .sheet(isPresented: $showsCustomAmount, onDismiss: refreshAfterCustomAmount) {
            customAmountSheet
        }
    }

    private var iPadDetailPane: some View {
        detailContent
    }

    @ViewBuilder
    private var detailContent: some View {
        if let day = model.selectedDay {
            DayDetailView(
                day: day,
                useCases: useCases,
                refreshID: detailRefreshID,
                onAdd: showCustomAmount
            )
                .id(day)
                .rippleNavigationBarBackground(RippleColor.waterFoam)
        } else {
            ContentUnavailableView(L10n.text("Choose a day"), systemImage: "calendar")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(RippleColor.waterFoam.ignoresSafeArea())
                .rippleNavigationBarBackground(RippleColor.waterFoam)
        }
    }

    @ToolbarContentBuilder
    private var calendarToolbar: some ToolbarContent {
        if canAddToHistory {
            ToolbarItem(placement: .primaryAction) {
                customAmountButton
            }
        }
    }

    private var customAmountButton: some View {
        Button(L10n.text("Custom amount"), systemImage: "plus", action: showCustomAmount)
            .labelStyle(.iconOnly)
            .accessibilityLabel(L10n.text("Custom amount"))
    }

    private var canAddToHistory: Bool {
        guard let selectedDay = model.selectedDay else { return false }
        return model.isToday(selectedDay)
    }

    private var customAmountSheet: some View {
        let snapshot = todayModel.snapshot
        let formatter = VolumeFormatter(locale: locale)
        return CustomAmountSheet(
            model: todayModel,
            initialAmountMl: snapshot.defaultAddMl,
            initialAmountText: formatter.valueString(
                milliliters: snapshot.defaultAddMl,
                unit: snapshot.unit
            ),
            unit: snapshot.unit
        )
    }

    private var calendar: some View {
        let diameter: CGFloat = usesSplit ? DayRingMetrics.regularDiameter : DayRingMetrics.compactDiameter
        return ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, spacing: 0) {
                ForEach(model.availableMonths, id: \.self) { month in
                    monthPage(month: month, diameter: diameter)
                        .id(month)
                        .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
        .scrollPosition(id: $pagerPosition, anchor: .center)
        .defaultScrollAnchor(.trailing, for: .initialOffset)
        .background(RippleColor.waterFoam.ignoresSafeArea())
        .transaction { transaction in
            if reduceMotion {
                transaction.animation = nil
            }
        }
        .onChange(of: pagerPosition) { _, _ in
            guard scrollPhase == .idle else { return }
            settlePager()
        }
        .onScrollPhaseChange { _, newPhase in
            scrollPhase = newPhase
            guard newPhase == .idle else { return }
            settlePager()
        }
        .task {
            model.selectTodayIfNeeded()
            await model.refreshAvailableMonths()
            alignPagerWithVisibleMonth()
        }
    }

    private var dayColumns: [GridItem] {
        let spacing = usesSplit ? RippleSpace.xs : RippleSpace.sm
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: 7)
    }

    private func monthPage(month: Date, diameter: CGFloat) -> some View {
        let title = model.monthTitle(for: month)
        return VStack(spacing: RippleSpace.lg) {
            HStack {
                Button(L10n.text("Previous month"), systemImage: "chevron.left", action: previousMonth)
                    .labelStyle(.iconOnly)
                    .disabled(!model.canNavigate(from: month, by: -1))
                Spacer()
                Text(title)
                    .font(RippleFont.title)
                    .foregroundStyle(RippleColor.waterDeep)
                Spacer()
                Button(L10n.text("Next month"), systemImage: "chevron.right", action: nextMonth)
                    .labelStyle(.iconOnly)
                    .disabled(!model.canNavigate(from: month, by: 1))
            }
            .padding(.horizontal, RippleSpace.sm)

            HStack {
                ForEach(model.weekdayColumns) { column in
                    Text(verbatim: column.symbol)
                        .font(RippleFont.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: dayColumns, spacing: RippleSpace.md) {
                ForEach(model.slots(for: month)) { slot in
                    if let date = slot.date {
                        dayButton(date: date, month: month, diameter: diameter)
                    } else {
                        Color.clear
                            .frame(height: diameter + RippleSpace.md)
                            .accessibilityHidden(true)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, RippleSpace.lg)
        .padding(.top, RippleSpace.sm)
        .frame(maxWidth: .infinity, alignment: .top)
        .task(id: month) {
            await model.refresh(month: month)
        }
    }

    private func dayButton(date: Date, month: Date, diameter: CGFloat) -> some View {
        let future = model.isFuture(date)
        return Group {
            if future {
                HistoryDayCell(
                    date: date,
                    summary: model.summary(on: date, in: month),
                    isToday: false,
                    isFuture: true,
                    isSelected: false,
                    reduceMotion: reduceMotion,
                    diameter: diameter
                )
                .allowsHitTesting(false)
            } else {
                Button {
                    select(date)
                } label: {
                    HistoryDayCell(
                        date: date,
                        summary: model.summary(on: date, in: month),
                        isToday: model.isToday(date),
                        isFuture: false,
                        isSelected: usesSplit && model.isSelected(date),
                        reduceMotion: reduceMotion,
                        diameter: diameter
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func select(_ date: Date) {
        model.select(date)
        if !usesSplit {
            compactSelectedDay = date
        }
    }

    private func showCustomAmount() {
        showsCustomAmount = true
    }

    private func refreshAfterCustomAmount() {
        detailRefreshID += 1
        Task { await model.refresh(month: model.visibleMonth) }
    }

    private func previousMonth() {
        shift(-1)
    }

    private func nextMonth() {
        shift(1)
    }

    private func shift(_ delta: Int) {
        guard scrollPhase == .idle, let currentMonth = pagerPosition else { return }
        let targetMonth = model.month(atOffset: delta, from: currentMonth)
        guard model.availableMonths.contains(targetMonth) else { return }

        if reduceMotion {
            var transaction = Transaction()
            transaction.animation = nil
            withTransaction(transaction) {
                pagerPosition = targetMonth
            }
        } else {
            withAnimation(.easeInOut(duration: RippleMotion.durationQuick)) {
                pagerPosition = targetMonth
            }
        }
    }

    private func settlePager() {
        guard let month = pagerPosition else { return }
        model.showMonth(month)
    }

    private func alignPagerWithVisibleMonth() {
        var transaction = Transaction()
        transaction.animation = nil
        withTransaction(transaction) {
            pagerPosition = model.visibleMonth
        }
    }
}
#endif
