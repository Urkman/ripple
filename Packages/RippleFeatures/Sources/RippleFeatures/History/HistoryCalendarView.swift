#if os(iOS) || os(macOS) || os(visionOS)
import RippleDomain
import RippleUI
import SwiftUI

public struct HistoryCalendarView: View {
    @Bindable private var model: HistoryViewModel
    @Environment(\.rippleUseCases) private var useCases
    @Environment(\.rippleHistorySplit) private var usesSplit
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pagerPosition: Date?
    @State private var scrollPhase: ScrollPhase = .idle

    public init(model: HistoryViewModel) {
        self.model = model
        let initialMonth = model.month(atOffset: 0)
        _pagerPosition = State(initialValue: initialMonth)
    }

    public var body: some View {
        if usesSplit {
            NavigationSplitView {
                calendar
                    .navigationTitle(L10n.text("History"))
            } detail: {
                if let day = model.selectedDay {
                    DayDetailView(day: day, useCases: useCases)
                        .id(day)
                } else {
                    ContentUnavailableView(L10n.text("Choose a day"), systemImage: "calendar")
                        .background(RippleColor.waterFoam.ignoresSafeArea())
                }
            }
        } else {
            compactStack
        }
    }

    private var compactStack: some View {
        NavigationStack {
            calendar
                .navigationTitle(L10n.text("History"))
                .navigationDestination(item: $model.selectedDay) { day in
                    DayDetailView(day: day, useCases: useCases)
                }
        }
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
            await model.refreshAvailableMonths()
            alignPagerWithVisibleMonth()
        }
    }

    private var dayColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: RippleSpace.sm), count: 7)
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
                    model.select(date)
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
