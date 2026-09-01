# Watch App Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the broken Watch logging-only screen with a Watch-native Today, History, and Stats experience that is readable on the Apple Watch Series 11 46 mm canvas, keeps the full-screen water-level concept, supports predefined and Digital Crown custom logging, and continues to use Ripple's shared domain and persistence boundaries.

**Architecture:** Keep `RippleWatchApp` as the composition root and inject the existing `UseCases` into a dedicated `WatchRootView`. Add Watch-only composition and `@MainActor @Observable` view models in `RippleFeatures`, token-backed controls and visual primitives in `RippleUI`, and one local-calendar-aware `HistoryRange.recentDays` case in `RippleDomain`. Watch logging remains a call to the existing `LogIntake` use case with `source: .watch`; no Watch repository, store, HealthKit client, or alternate amount path is introduced.

**Tech Stack:** Swift 6.2, strict concurrency, SwiftUI, Observation, SwiftData/CloudKit through the existing data layer, Swift Charts, String Catalogs, Testing, watchOS 26.

**Spec:** `/Users/urkman/Development/iOS/private/ripple/Docs/superpowers/specs/2026-09-01-watch-app-redesign-design.md`

## Global Constraints

- Read and obey `/Users/urkman/Development/iOS/private/ripple/AGENTS.md`; the approved Watch design in the Spec supersedes only the currently contradictory Watch-platform statements after the binding documents are amended in Task 1.
- Do not reuse `TodayView`, `RippleHeroView`, `TodayViewModel`, `HistoryCalendarView`, or `StatsView` for Watch layout. Watch gets dedicated composition while consuming the same domain use cases.
- Use SwiftUI only for layout. Do not add UIKit layout, SpriteKit, Metal, Lottie, video, or third-party UI dependencies.
- Use `@Observable` and `@MainActor`; do not add `ObservableObject`, `Combine`, `@Query` writes, or view-owned persistence.
- Every Watch write must call `useCases.logIntake.run(amount:source:date:containerId:)` with `source: .watch`. Predefined options pass their container ID; Custom passes `nil`.
- Keep all stored amounts as integer milliliters. `WatchAmountSelection` may convert for display/Crown stepping only.
- Keep Watch navigation platform-local: three horizontal Today/History/Stats pages, with History pushing a local read-only Day Detail page. No app-wide router, month grid, Month/Year picker, or Watch complication redesign.
- Today uses a full-canvas water field as its sole progress visualization. It has no ring, glass, `ProgressView`, pour stream, surface reaction, idle wave, Core Motion tilt, or last-log row.
- Today water is flat when idle; level zero renders no water or surface path. Normal level refresh uses a restrained liquid transition; Reduce Motion uses a 0.20-second cross-fade.
- Use only RippleUI color, type, space, radius, and motion tokens. Add named Watch layout metrics instead of unnamed feature magic numbers.
- All visible copy, including Crown instructions, Stats labels, empty/error states, and accessibility text, must resolve through German/English localization resources. Never hard-code an English string in a Watch view.
- Preserve the last valid snapshot on refresh or logging failure. A failed log does not reset the selected amount or Crown value and does not roll back a stored intake.
- New or materially changed views/components need Light, Dark, Dynamic Type XXXL, and Reduce Motion previews. Do not clip the Today readout on 40/41 mm or 46 mm canvases.
- Every implementation task ends with focused tests/verification and a small commit; do not combine unrelated work into one commit.

---

## Existing File Map

Use these existing files rather than creating parallel infrastructure:

- `/Users/urkman/Development/iOS/private/ripple/Apps/RipplewatchOS/RippleWatchApp.swift` — Watch composition root; only swap the injected root view.
- `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchTodayView.swift` — replace the current clipped iPhone-hero implementation.
- `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Sources/RippleFeatures/Today/TodayViewModel.swift` — reference only; do not extend it with Watch-specific source/selection rules.
- `/Users/urkman/Development/iOS/private/ripple/Packages/RippleDomain/Sources/RippleDomain/Entities/HistorySnapshot.swift` — add the `recentDays` range case.
- `/Users/urkman/Development/iOS/private/ripple/Packages/RippleDomain/Sources/RippleDomain/Formatting/DayWindow.swift` — calculate the local-calendar boundaries for `recentDays`.
- `/Users/urkman/Development/iOS/private/ripple/Packages/RippleDomain/Sources/RippleDomain/UseCases/ObserveHistory.swift` — keep as the single History read API; its existing loop will consume the new `DayWindow` case.
- `/Users/urkman/Development/iOS/private/ripple/Packages/RippleDomain/Sources/RippleDomain/UseCases/ObserveStats.swift` — keep as the Stats read API; Watch always passes `.week(anchor)`.
- `/Users/urkman/Development/iOS/private/ripple/Packages/RippleDomain/Sources/RippleDomain/Formatting/UnitConverter.swift` — use for Crown/unit conversion; do not duplicate its constants.
- `/Users/urkman/Development/iOS/private/ripple/Packages/RippleUI/Sources/RippleUI/Tokens/RippleColor.swift` — replace the watchOS light-only color fallback with adaptive package color assets.
- `/Users/urkman/Development/iOS/private/ripple/Packages/RippleUI/Sources/RippleUI/Tokens/RippleLayout.swift` and `RippleTypography.swift` — extend with named Watch metrics/tokens.
- `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Sources/RippleFeatures/Shared/L10n.swift` and `Resources/Localizable.xcstrings` — add Watch-specific copy while reusing existing keys where available.

Files expected to be created:

- `Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchRootView.swift`
- `Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchTodayViewModel.swift`
- `Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchHistoryView.swift`
- `Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchHistoryViewModel.swift`
- `Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchDayDetailView.swift`
- `Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchDayDetailViewModel.swift`
- `Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchStatsView.swift`
- `Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchStatsViewModel.swift`
- `Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchCustomAmountView.swift`
- `Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchAmountSelection.swift`
- `Packages/RippleUI/Sources/RippleUI/Tokens/RippleWatchLayout.swift`
- `Packages/RippleUI/Sources/RippleUI/Components/WatchWaterBackdrop.swift`
- `Packages/RippleUI/Sources/RippleUI/Components/WatchQuickAmountRow.swift`
- `Packages/RippleUI/Sources/RippleUI/Components/WatchLogButton.swift`
- `Packages/RippleUI/Sources/RippleUI/Components/WatchDayRow.swift`
- `Packages/RippleUI/Sources/RippleUI/Components/WatchStatChart.swift`
- `Packages/RippleUI/Sources/RippleUI/Resources/RippleColors.xcassets` color sets
- `Packages/RippleDomain/Tests/RippleDomainTests/HistoryStatsTests.swift` additions
- `Packages/RippleFeatures/Tests/RippleFeaturesTests/WatchAmountSelectionTests.swift`
- `Packages/RippleFeatures/Tests/RippleFeaturesTests/WatchTodayViewModelTests.swift`
- `Packages/RippleFeatures/Tests/RippleFeaturesTests/WatchHistoryAndStatsViewModelTests.swift`
- `Packages/RippleUI/Tests/RippleUITests/WatchComponentsTests.swift`

## Task 1: Align the binding documents with the approved Watch contract

**Files:**

- Modify `/Users/urkman/Development/iOS/private/ripple/AGENTS.md`.
- Modify `/Users/urkman/Development/iOS/private/ripple/Ripple_Handoff/Ripple_PRD.md`.
- Modify `/Users/urkman/Development/iOS/private/ripple/Ripple_Handoff/Ripple_History_Stats.md`.
- Modify `/Users/urkman/Development/iOS/private/ripple/Docs/superpowers/specs/2026-09-01-watch-app-redesign-design.md` only if its status or cross-reference needs the final approved wording.

**Changes:**

- In `AGENTS.md`, replace the Watch platform sentence that currently says “ring + plus + crown. No calendar, no stats charts.” with the approved three-page contract: Today full-canvas level plus logging, History recent seven-day list/detail, Stats current ISO-week summary with one compact chart. Explicitly retain “no calendar” and “no stats charts” for Watch complications/widgets where those restrictions still apply.
- In `Ripple_PRD.md` §12.3, replace the one-screen ring description with Today/History/Stats pages, Watch-native full-canvas level, predefined/Crown custom logging, read-only Day Detail, and current-week Stats. Update the v1 definition of done to require those pages and their tests.
- In `Ripple_History_Stats.md`, keep the iPhone/iPad calendar and multi-period requirements unchanged, replace the contradictory Watch sentence, and add a Watch subsection specifying seven elapsed local days newest-first, read-only detail, and one current ISO-week Swift Charts view. State that Watch has no month calendar, no period picker, and no editing/deletion.
- Keep the design spec’s status aligned with its already approved chat decision.

**Steps:**

- [ ] Update the three binding documents and confirm the Watch-app rules no longer contradict the approved Spec.
- [ ] Run the targeted `rg` audit and inspect every remaining Watch restriction by platform.
- [ ] Run `git diff --check`, review the diff, and stage the ignored handoff files explicitly with `git add -f`.
- [ ] Commit the documentation-only change as `docs: align Watch requirements with approved redesign`.

**Verification:**

- Run `rg -n "ring \+ plus|No calendar|no stats charts|Watch zeigt höchstens|Apple Watch|three horizontal|recent seven|current ISO" AGENTS.md Ripple_Handoff/Ripple_PRD.md Ripple_Handoff/Ripple_History_Stats.md` and inspect every remaining Watch hit for whether it refers to the app or to complications/widgets.
- Run `git diff --check` and review the complete documentation diff before touching Swift code.
- `Ripple_Handoff/` is ignored in this repository; when committing these approved binding-doc changes, stage those exact files with `git add -f` and do not stage unrelated handoff artifacts.

**Commit:** `docs: align Watch requirements with approved redesign`

## Task 2: Add the local-calendar recent-days History range

**Files:**

- Modify `/Users/urkman/Development/iOS/private/ripple/Packages/RippleDomain/Sources/RippleDomain/Entities/HistorySnapshot.swift`.
- Modify `/Users/urkman/Development/iOS/private/ripple/Packages/RippleDomain/Sources/RippleDomain/Formatting/DayWindow.swift`.
- Modify `/Users/urkman/Development/iOS/private/ripple/Packages/RippleDomain/Tests/RippleDomainTests/HistoryStatsTests.swift`.

**Interfaces:**

- Extend `HistoryRange` with `case recentDays(anchor: Date, count: Int)`.
- Extend `DayWindow.range(for:calendar:)` with the following behavior: normalize `count` to at least `1`; set `anchorStart = calendar.startOfDay(for: anchor)`; set `start` to `count - 1` local calendar days before `anchorStart`; set `end` to `calendar.date(byAdding: .day, value: 1, to: anchorStart)`; return `(start, end)`.
- Do not add a new use case. `ObserveHistory.snapshot(for:calendar:)` must continue to be the only feature-facing read path and must return exactly `count` `DayTotal` values for a valid count.

**Tests first:**

- Add a `HistoryStatsTests` test using a fixed calendar and anchor that calls `observeHistory.snapshot(for: .recentDays(anchor: anchor, count: 7), calendar: calendar)` and asserts seven days, ascending local-midnight day values from six days before the anchor through the anchor day, and no future day.
- Add a daylight-saving test with `Calendar(identifier: .gregorian)` and `TimeZone(identifier: "Europe/Berlin")!`, anchored on 29 March 2026, asserting the returned range spans seven calendar dates even though its elapsed seconds are not `7 * 86_400`. This catches accidental fixed-second arithmetic.
- Add a `count: 0` assertion that the range contains one local day rather than producing an empty/inverted range.

**Steps:**

- [ ] Add the three failing domain tests before changing `HistoryRange` or `DayWindow`.
- [ ] Run `swift test --package-path Packages/RippleDomain --filter HistoryStatsTests` and record the expected failure.
- [ ] Add the enum case and the DST-safe `DayWindow` switch branch.
- [ ] Run the focused History tests and the complete `RippleDomain` suite.
- [ ] Commit the domain change as `feat: add local recent-days history range`.

**Implementation and verification:**

- Run `swift test --package-path Packages/RippleDomain --filter HistoryStatsTests` and observe the new tests fail before implementing the switch case.
- Implement only the enum case and `DayWindow` switch branch; preserve the existing day/week/month behavior and DST-safe `Calendar` arithmetic.
- Run `swift test --package-path Packages/RippleDomain --filter HistoryStatsTests` again, then run `swift test --package-path Packages/RippleDomain`.

**Commit:** `feat: add local recent-days history range`

## Task 3: Create the pure Crown amount-selection model

**Files:**

- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchAmountSelection.swift`.
- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Tests/RippleFeaturesTests/WatchAmountSelectionTests.swift`.

**Interface:**

```swift
public struct WatchAmountSelection: Equatable, Sendable {
    public static let minimumMilliliters = 50
    public static let maximumMilliliters = 2_000
    public static let metricStepMilliliters = 50
    public static let fluidOunceStep = 1

    public let unit: VolumeUnit
    public private(set) var milliliters: Int

    public init(milliliters: Int, unit: VolumeUnit)
    public var crownValue: Double { get }
    public var crownLowerBound: Double { get }
    public var crownUpperBound: Double { get }
    public mutating func update(crownValue: Double)
}
```

**Rules:**

- For `.milliliters`, Crown values are display steps `1...40`, where each integer maps to `50 ml`; initialize and update by rounding to the nearest step and clamping to 50–2,000 ml.
- For `.fluidOunces`, Crown values are whole fluid ounces in the valid interval `2...67`; this is the nearest whole-ounce interval whose converted integer milliliters stays within the 50–2,000 ml range. Convert through `UnitConverter.milliliters(amount:unit:)`, never by duplicating the fluid-ounce constant.
- `crownValue` must always be the current display-unit value used by `digitalCrownRotation`; the model’s stored truth remains `milliliters`.

**Tests first:**

- Assert metric initialization snaps `251 ml` to `250 ml`, Crown update from step `5` to `6` produces `300 ml`, and values below/above the range clamp to `50`/`2_000 ml`.
- Assert fluid-ounce initialization of `250 ml` snaps to `8 fl oz`/`237 ml`, one Crown increment to `9 fl oz` produces `266 ml`, and values below/above the valid ounce bounds clamp to `2 fl oz`/`67 fl oz`.
- Assert the model is `Equatable` and `Sendable` by using it as a value in test expectations; no UI or use-case dependency belongs in this file.

**Steps:**

- [ ] Add the metric, fluid-ounce, clamping, and value-semantics tests before writing the selection model.
- [ ] Run `swift test --package-path Packages/RippleFeatures --filter WatchAmountSelectionTests` and record the expected failure.
- [ ] Implement `WatchAmountSelection` exclusively with `UnitConverter` and integer milliliters.
- [ ] Run the focused selection tests and the complete `RippleFeatures` suite.
- [ ] Commit the selection model as `feat: add Watch Crown amount selection`.

**Implementation and verification:**

- Run `swift test --package-path Packages/RippleFeatures --filter WatchAmountSelectionTests` before implementation and confirm the new test target/file fails to compile or the tests fail.
- Implement the struct using `UnitConverter` and integer milliliters.
- Run `swift test --package-path Packages/RippleFeatures --filter WatchAmountSelectionTests` and then `swift test --package-path Packages/RippleFeatures`.

**Commit:** `feat: add Watch Crown amount selection`

## Task 4: Make RippleUI color tokens adaptive on watchOS

**Files:**

- Modify `/Users/urkman/Development/iOS/private/ripple/Packages/RippleUI/Package.swift` to process `Resources` for the `RippleUI` target.
- Modify `/Users/urkman/Development/iOS/private/ripple/Packages/RippleUI/Sources/RippleUI/Tokens/RippleColor.swift` so the public static tokens load named module colors rather than the watchOS light-only `self = light` fallback.
- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleUI/Sources/RippleUI/Resources/RippleColors.xcassets/Contents.json`.
- Create color-set `Contents.json` files for `RippleWaterDeep`, `RippleWaterLagoon`, `RippleWaterAqua`, `RippleWaterFoam`, and `RippleSurface` under that asset catalog.

**Asset values:**

- `RippleWaterDeep`: light `#0B3D4A`, dark `#B7E0E8`.
- `RippleWaterLagoon`: light `#1A7A8C`, dark `#4FB3C6`.
- `RippleWaterAqua`: light `#4FB3C6`, dark `#6FDBE8`.
- `RippleWaterFoam`: light `#E8F4F6`, dark `#152026`.
- `RippleSurface`: light `#E8F4F6`, dark `#12181C`.

**Implementation:**

- Use `Color("RippleWaterDeep", bundle: .module)` and the corresponding asset names for the existing public token properties. Keep `glassHighlight` and `danger` on their existing token paths.
- Preserve `Color(hex:)` only if it remains part of the package API; remove or stop using the platform-specific light-only `Color(light:dark:)` construction for Ripple’s actual tokens. Verify no production caller relies on a deleted initializer before removing it.
- Do not add a new accent color. The asset catalog is an adaptive implementation of the existing tokens, not a new palette.

**Verification:**

- Run `swift test --package-path Packages/RippleUI` and `swift test --package-path Packages/RippleFeatures` to ensure the generated module resource bundle and existing package consumers compile.
- Run `rg -n "self = light|Color\(light:|RippleWater" Packages/RippleUI/Sources/RippleUI` and verify the static Ripple tokens no longer use the watchOS light-only fallback.

**Steps:**

- [ ] Add the adaptive asset resource declaration and color sets with the exact existing light/dark hex values.
- [ ] Run the RippleUI package tests before changing token construction and confirm the resource-backed token test/build path fails or is absent.
- [ ] Replace the token construction and remove the actual-token dependency on the watchOS light-only fallback.
- [ ] Run the RippleUI and RippleFeatures package suites, then inspect the `rg` fallback audit.
- [ ] Commit the adaptive token change as `fix: make RippleUI colors adaptive on Watch`.

**Commit:** `fix: make RippleUI colors adaptive on Watch`

## Task 5: Build token-backed Watch visual and action primitives

**Files:**

- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleUI/Sources/RippleUI/Tokens/RippleWatchLayout.swift`.
- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleUI/Sources/RippleUI/Components/WatchWaterBackdrop.swift`.
- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleUI/Sources/RippleUI/Components/WatchQuickAmountRow.swift`.
- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleUI/Sources/RippleUI/Components/WatchLogButton.swift`.
- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleUI/Sources/RippleUI/Components/WatchDayRow.swift`.
- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleUI/Tests/RippleUITests/WatchComponentsTests.swift`.

**Interfaces:**

```swift
public enum RippleWatchLayout {
    public static let pageHorizontalPadding: CGFloat = 12
    public static let todayDockPadding: CGFloat = 8
    public static let todayContentSpacing: CGFloat = 4
    public static let controlHeight: CGFloat = 44
    public static let quickOptionSpacing: CGFloat = 4
    public static let dayRowSpacing: CGFloat = 8
    public static let chartHeight: CGFloat = 128
}

public struct WatchWaterLevelShape: Shape {
    public init(level: CGFloat)
    public func path(in rect: CGRect) -> Path
}

public struct WatchWaterSurfaceShape: Shape {
    public init(level: CGFloat)
    public func path(in rect: CGRect) -> Path
}

public struct WatchWaterBackdrop: View {
    public init(level: CGFloat)
}

public struct WatchAmountOption: Identifiable, Equatable, Sendable {
    public enum Kind: Equatable, Sendable {
        case predefined(UUID)
        case custom
    }

    public let id: String
    public let title: String
    public let subtitle: String
    public let kind: Kind
}

public struct WatchQuickAmountRow: View {
    public init(options: [WatchAmountOption], selectedID: String?, onSelect: @escaping (WatchAmountOption) -> Void)
}

public struct WatchLogButton: View {
    public init(title: String, isEnabled: Bool = true, action: @escaping () -> Void)
}

public struct WatchDayRow: View {
    public init(title: String, subtitle: String, amountText: String, progress: Double, statusText: String)
}
```

**Implementation rules:**

- `WatchWaterLevelShape` fills from the bottom to `min(max(level, 0), 1.05)` with a flat top edge. `WatchWaterSurfaceShape` draws only the corresponding flat edge. Both return an empty `Path` for `level <= 0`; no water glow or bottom shimmer is added.
- `WatchWaterBackdrop` layers `RippleColor.surface`, the aqua field, and the lagoon surface line in a full-size `GeometryReader`. It has no text, ring, animation loop, motion sensor, or progress view and is accessibility-hidden because Today supplies the semantic readout.
- `WatchQuickAmountRow` renders compact selectable options; selection uses a clear selected state and the row has a 44 pt minimum hit target. It does not write data.
- `WatchLogButton` is a custom compact `Button` with a named control radius, lagoon fill, and the Watch hit target. Use `.buttonStyle(.plain)` and a pressed-state animation; do not use `.glassProminent`.
- `WatchDayRow` displays labels and a capped `0...1` horizontal water bar. It is a label component so the parent can wrap it in a `NavigationLink`; do not nest a `Button` or `NavigationLink` inside it.
- Use only `RippleColor`, `RippleFont`, `RippleSpace`, `RippleRadius`, `RippleWatchLayout`, and system materials sparingly.

**Tests first:**

- Assert both water shapes have empty paths at zero.
- Assert negative levels produce the same empty paths, levels above one are capped to the defined 1.05 visual maximum, and the path remains inside the expected canvas bounds.
- Assert a fractional `WatchAmountOption` list preserves option IDs and selected identity; this protects the action row from accidental value-based selection collisions.

**Steps:**

- [ ] Add the zero-level/capped-shape and option-identity tests before implementing the components.
- [ ] Run the focused RippleUI tests and record the expected failure.
- [ ] Implement the named Watch metrics, water shapes, backdrop, quick-option row, log button, and day row without domain/use-case imports.
- [ ] Run the focused tests and the complete RippleUI suite.
- [ ] Commit the primitives as `feat: add Watch water and action components`.

**Implementation and verification:**

- Run `swift test --package-path Packages/RippleUI --filter WatchComponentsTests` before implementation and confirm the new tests fail.
- Implement the shapes and views with no domain imports or use-case calls.
- Run `swift test --package-path Packages/RippleUI --filter WatchComponentsTests` and then `swift test --package-path Packages/RippleUI`.

**Commit:** `feat: add Watch water and action components`

## Task 6: Add the compact weekly Watch chart component

**Files:**

- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleUI/Sources/RippleUI/Components/WatchStatChart.swift`.
- Modify `/Users/urkman/Development/iOS/private/ripple/Packages/RippleUI/Tests/RippleUITests/WatchComponentsTests.swift`.

**Interfaces:**

```swift
public struct WatchStatChartPoint: Identifiable, Equatable, Sendable {
    public let date: Date
    public let consumed: Double
    public let goal: Double
    public var id: Date { date }

    public init(date: Date, consumed: Double, goal: Double)
}

public struct WatchStatChart: View {
    public init(points: [WatchStatChartPoint], emptyMessage: String, accessibilitySummary: String)
}
```

**Implementation rules:**

- Import `Charts` and render one compact `Chart` with seven day categories when points exist: `BarMark` for consumed volume and one subtle goal reference using the maximum nonzero goal from the provided points. Use the system locale/date values for the x-axis and Ripple Aqua/Lagoon tokens for marks.
- If `points` is empty, render only `emptyMessage`; never fabricate zero bars.
- Keep the chart non-interactive. Add one concise accessibility element with `accessibilitySummary` instead of exposing every mark as an unlabeled child.
- Use `RippleWatchLayout.chartHeight`; do not expose period controls from the component.

**Tests and verification:**

- Add a test that creates seven dated points and asserts their IDs remain stable and ordered; add an empty-point assertion for the no-data path.
- Run `swift test --package-path Packages/RippleUI --filter WatchComponentsTests` before and after implementation, then run the complete `RippleUI` test suite.

**Steps:**

- [ ] Add the seven-point identity/order and empty-state tests before implementing the chart.
- [ ] Run the focused RippleUI tests and record the expected failure.
- [ ] Implement the Swift Charts view with a consumed bar series, one goal reference, an empty message, and one concise accessibility summary.
- [ ] Run the focused tests and the complete RippleUI suite.
- [ ] Commit the chart as `feat: add compact Watch stats chart`.

**Commit:** `feat: add compact Watch stats chart`

## Task 7: Implement Watch Today state and logging orchestration

**Files:**

- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchTodayViewModel.swift`.
- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Tests/RippleFeaturesTests/WatchTodayViewModelTests.swift`.

**Interface:**

```swift
@MainActor
@Observable
public final class WatchTodayViewModel {
    public var snapshot: TodaySnapshot { get }
    public private(set) var selectedAmountMl: Int { get }
    public private(set) var selectedContainerID: UUID? { get }
    public private(set) var customSelection: WatchAmountSelection { get }
    public private(set) var isCustomPresented: Bool { get }
    public private(set) var isLogging: Bool { get }
    public private(set) var confirmation: String? { get }
    public private(set) var errorMessage: String? { get }

    public init(useCases: UseCases, now: Date = Date(), calendar: Calendar = .current)
    public var quickContainers: [Container] { get }
    public var waterLevel: Double { get }
    public func refresh(now: Date = Date()) async
    public func select(container: Container)
    public func openCustom()
    public func updateCustomCrown(_ value: Double)
    public func cancelCustom()
    public func addSelected() async
}
```

**State rules:**

- Initialize with an empty snapshot and the default `WatchAmountSelection`; after the first successful refresh, select `snapshot.defaultAddMl` and the `isDefault` container ID.
- `quickContainers` is exactly `Array(snapshot.containers.prefix(3))`, preserving the repository’s sort order. Selecting a predefined container changes only `selectedAmountMl` and `selectedContainerID`.
- `openCustom()` saves the current selection for cancellation, creates a `WatchAmountSelection` from the selected amount/profile unit, clears the container ID, and presents the custom sheet. `updateCustomCrown` updates both the selection and the integer `selectedAmountMl`.
- `cancelCustom()` dismisses the custom state and restores the saved predefined amount/container without writing.
- `addSelected()` guards against concurrent writes, captures the selected amount/container, and calls exactly:

```swift
try await useCases.logIntake.run(
    amount: Milliliters(selectedAmountMl),
    source: .watch,
    date: Date(),
    containerId: selectedContainerID
)
```

- On success, refresh Today, show existing localized `L10n.confirmation(amount:)`, clear it after the existing confirmation duration, and dismiss Custom if it was open. On failure, keep amount/container/Crown selection intact and expose `errorMessage`.
- `waterLevel` delegates to the existing `RippleMotion.fillLevel(consumedMl:goalMl:)`; the view owns the transition and Reduce Motion behavior.
- The view model imports domain/UI APIs only as needed for orchestration and formatting; it does not import SwiftData, CloudKit, HealthKit, WidgetKit, or repositories.

**Tests first:**

- Build the same `UseCases.assemble(...)` in tests with `InMemoryIntakeRepository`, default containers, and the existing no-op adapters. Assert refresh chooses the default 250 ml amount and default container ID.
- Assert selecting a non-default container changes selection without adding a repository row; `addSelected()` creates one row with the selected amount, selected container ID, and `.watch` source.
- Assert `openCustom()` clears the container ID, Crown updates reach the selected integer amount, and `addSelected()` creates a `.watch` row with `containerId == nil`.
- Add a throwing `IntakeRepository` test double inside the test file. Make `save` throw, call `addSelected()`, and assert `selectedAmountMl`/`customSelection` remain unchanged and `errorMessage` is non-nil.

**Steps:**

- [ ] Add the default-selection, no-write-on-select, predefined-write, custom-write, and failure-preservation tests before implementing the view model.
- [ ] Run the focused Watch Today tests and record the expected failure.
- [ ] Implement the observable state, selection transitions, confirmation task, and single `.watch` LogIntake call.
- [ ] Run the focused tests and the complete `RippleFeatures` suite.
- [ ] Commit the Today model as `feat: add Watch Today logging model`.

**Implementation and verification:**

- Run `swift test --package-path Packages/RippleFeatures --filter WatchTodayViewModelTests` before implementation and confirm failure.
- Implement the model with `@ObservationIgnored` dependencies and cancellable confirmation task; do not copy `TodayViewModel.log` or its `.app` source.
- Run the focused tests and the complete `swift test --package-path Packages/RippleFeatures` suite.

**Commit:** `feat: add Watch Today logging model`

## Task 8: Implement Watch History, Day Detail, and Stats view models

**Files:**

- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchHistoryViewModel.swift`.
- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchDayDetailViewModel.swift`.
- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchStatsViewModel.swift`.
- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Tests/RippleFeaturesTests/WatchHistoryAndStatsViewModelTests.swift`.

**Interfaces:**

```swift
@MainActor
@Observable
public final class WatchHistoryViewModel {
    public private(set) var days: [DayTotal] { get }
    public private(set) var errorMessage: String? { get }
    public init(useCases: UseCases, now: Date = Date(), calendar: Calendar = .current)
    public func refresh(now: Date = Date()) async
}

@MainActor
@Observable
public final class WatchDayDetailViewModel {
    public let day: Date
    public private(set) var snapshot: TodaySnapshot { get }
    public private(set) var errorMessage: String? { get }
    public init(useCases: UseCases, day: Date, calendar: Calendar = .current)
    public var entries: [Intake] { get }
    public func refresh() async
    public func containerName(for intake: Intake) -> String?
}

@MainActor
@Observable
public final class WatchStatsViewModel {
    public struct ChartPoint: Identifiable, Equatable, Sendable {
        public let date: Date
        public let consumedMl: Int
        public let goalMl: Int
        public var id: Date { date }
    }

    public private(set) var snapshot: StatsSnapshot { get }
    public private(set) var unit: VolumeUnit { get }
    public private(set) var referenceNow: Date { get }
    public private(set) var errorMessage: String? { get }
    public init(useCases: UseCases, now: Date = Date(), calendar: Calendar = .current)
    public var averageMl: Int { get }
    public var elapsedDayCount: Int { get }
    public var hitDayCount: Int { get }
    public var chartPoints: [ChartPoint] { get }
    public func refresh(now: Date = Date()) async
}
```

**Rules:**

- `WatchHistoryViewModel.refresh(now:)` calls `useCases.observeHistory.snapshot(for: .recentDays(anchor: now, count: 7), calendar: calendar)`, filters to elapsed local days, and stores newest-first `DayTotal` values. Empty days remain in the seven-row window.
- `WatchDayDetailViewModel.refresh()` calls `useCases.observeToday.snapshot(for: day, calendar: calendar)`. `entries` is the snapshot’s undeleted entries sorted newest-first. This model has no add/edit/delete methods.
- `WatchStatsViewModel.refresh(now:)` calls `useCases.observeStats.run(range: .week(now), calendar: calendar, now: now)`, reads the preferred unit from `settingsRepository.profile()`, and exposes `StatsSnapshot`-derived summary values through `daysElapsed`, `hitDays`, `averageMlPerDay`, and `totalMl`. It must not reimplement these calculations.
- `WatchStatsViewModel.ChartPoint` contains raw integer milliliters; the view performs only unit conversion for display/chart axes through `UnitConverter`. `chartPoints` returns an empty array when `snapshot.hasData == false`; when data exists it maps the seven source days, including legitimate zero-amount days, without inventing values.
- On refresh failure, keep the prior snapshot and set `errorMessage`. No fake days or chart bars are inserted.

**Tests first:**

- Seed seven days and assert History returns all seven, newest first, with an empty day preserved and no future day.
- Seed a day with three entries in non-chronological insertion order and assert Day Detail exposes them newest-first, resolves a known container name, and exposes the correct day snapshot totals.
- Refresh Stats with an anchor in a known ISO week and assert the snapshot range equals `StatsPeriod.week(anchor).bounds(calendar:)`, `averageMl`/`hitDayCount` come from the seeded data, and `chartPoints.count == 7`.
- Assert an empty Stats period has no data and `chartPoints.isEmpty`; a populated week maps all seven source days, including legitimate zero-amount days.

**Steps:**

- [ ] Add the recent-day ordering, detail filtering/order, ISO-week summary, and empty-Stats tests before implementing the three models.
- [ ] Run the focused Watch History/Stats tests and record the expected failure.
- [ ] Implement the models with only existing `UseCases`, `Calendar`, and value snapshots.
- [ ] Run the focused tests and the complete `RippleFeatures` suite.
- [ ] Commit the models as `feat: add Watch history and stats models`.

**Implementation and verification:**

- Run `swift test --package-path Packages/RippleFeatures --filter WatchHistoryAndStatsViewModelTests` before implementation and confirm failure.
- Implement each model with only `UseCases`, `Calendar`, and value snapshots as dependencies. Use `@ObservationIgnored` for dependencies and preserve last valid state on errors.
- Run the focused tests and then `swift test --package-path Packages/RippleFeatures`.

**Commit:** `feat: add Watch history and stats models`

## Task 9: Build the Watch Today and Custom Crown screens

**Files:**

- Replace `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchTodayView.swift`.
- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchCustomAmountView.swift`.

**Interfaces:**

```swift
#if os(watchOS)
public struct WatchTodayView: View {
    public init(model: WatchTodayViewModel)
}

public struct WatchCustomAmountView: View {
    public init(model: WatchTodayViewModel)
}
#endif
```

**Today composition:**

- Use a full-screen `ZStack` with `WatchWaterBackdrop(level: model.waterLevel)` behind the content. The water field is the sole progress visualization; do not add a ring, glass outline, bar, `ProgressView`, last-log row, or iPhone hero.
- Place localized `Today`, the consumed amount, a localized remaining phrase, and percent over the canvas using `RippleFont` styles and monospaced digits. Use a contrast-safe token foreground for both adaptive appearances; do not render `waterDeep` as unreadable text on a dark surface.
- Put `WatchQuickAmountRow` and `WatchLogButton(title: L10n.addAmount(...))` in a compact bottom dock. The first three options map to the first three sorted `model.quickContainers`; tapping one selects only. The Custom option opens the sheet; only the primary Add button writes.
- Show `model.confirmation` and `model.errorMessage` as accessible, transient/inline status text without changing the water metaphor. Keep the composition within a 416 × 496 canvas and allow content to compress rather than clip at XXXL.
- Apply a 0.20-second cross-fade for level changes when `accessibilityReduceMotion` is enabled. Otherwise use the named liquid transition; never use Core Motion or an idle animation.
- Refresh through `.task(id: scenePhase)` or the root lifecycle task when the Watch scene is active. Do not refresh every frame.

**Custom screen composition:**

- Present a focused sheet with the current amount as the dominant readout, the explicit unit, localized `Turn the Digital Crown` hint, one `WatchLogButton` Add action, and a Cancel action.
- Bind `digitalCrownRotation` to a local `Double` initialized from `model.customSelection.crownValue`; use `crownLowerBound`, `crownUpperBound`, and `by: 1`. On change call `model.updateCustomCrown`.
- The Add action calls `await model.addSelected()` and dismisses only after a successful write; the Cancel action calls `model.cancelCustom()` and dismisses without writing.
- Keep `#if os(watchOS)` around Watch-only view/API code. This is a UI adapter condition, not business logic.

**Verification:**

- Run `swift test --package-path Packages/RippleFeatures` after the views compile through the package’s non-Watch platforms.
- Run `xcodegen generate` and compile the Watch target in Task 12; resolve any Swift 6 actor-isolation or watchOS API diagnostics before proceeding.

**Steps:**

- [ ] Replace the old iPhone-hero Watch view with the full-canvas Today composition and add the Crown-first custom sheet.
- [ ] Run the RippleFeatures suite and fix package-level compile/actor-isolation issues without adding business logic to the app target.
- [ ] Build the Watch scheme and inspect the first simulator screenshot before adding the remaining pages.
- [ ] Commit the Today/custom UI as `feat: build Watch Today and custom Crown UI`.

**Commit:** `feat: build Watch Today and custom Crown UI`

## Task 10: Build Watch History, read-only Day Detail, Stats, and page navigation

**Files:**

- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchHistoryView.swift`.
- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchDayDetailView.swift`.
- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchStatsView.swift`.
- Create `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchRootView.swift`.
- Modify `/Users/urkman/Development/iOS/private/ripple/Apps/RipplewatchOS/RippleWatchApp.swift`.

**Interfaces and navigation:**

```swift
#if os(watchOS)
public struct WatchRootView: View {
    public init(useCases: UseCases)
}

public struct WatchHistoryView: View {
    public init(model: WatchHistoryViewModel, useCases: UseCases)
}

public struct WatchDayDetailView: View {
    public init(model: WatchDayDetailViewModel)
}

public struct WatchStatsView: View {
    public init(model: WatchStatsViewModel)
}
#endif
```

- `WatchRootView` owns `@State` instances of the Today, History, and Stats models and presents exactly three `TabView` pages with `.tabViewStyle(.page(indexDisplayMode: .automatic))`, selected Today on launch. Day Detail creates its own model for the pushed destination. The root is not a shared router and has no tab bar or Settings page.
- `WatchHistoryView` uses a local `NavigationStack` and `NavigationLink(value: day.date)` rows. Each row uses `WatchDayRow` with weekday/short-date, consumed/goal, capped bar, and a disclosure affordance. The destination is `WatchDayDetailView`; no month calendar, ring, chart wall, or add button appears.
- `WatchDayDetailView` shows date, total, goal percentage, and an `Entries` list. Each row includes time, amount, container when available, and localized source. Empty days show `No entries`. Do not expose editing, deletion, or logging actions.
- `WatchStatsView` shows localized `Avg / day`, goal days as `{hitDays} / {elapsedDays}`, and total volume, followed by `WatchStatChart` with seven current-week points. If `snapshot.hasData == false`, show the localized no-data empty state and no bars.
- `RippleWatchApp` must instantiate `WatchRootView(useCases: container.useCases)` and keep its existing `RippleBootstrap.start()` composition. No app-target service or state store is added.

**Lifecycle and accessibility:**

- Refresh Today, History, and Stats when the Watch scene becomes active. A page may also refresh on first appearance, but do not create duplicate concurrent refresh loops.
- Give every page and control a complete VoiceOver label/value/hint: Today amount/goal/remaining/percent/selected amount, each predefined option, Custom/Crown value, History row date/amount/goal/status, Day Detail entry time/amount/container/source, and Stats summary/chart period.
- Keep History and Day Detail scrollable on small canvases. Today’s water backdrop must stay fixed behind its foreground content.

**Verification:**

- Run `swift test --package-path Packages/RippleFeatures` and build the Watch scheme before moving to localization/polish.
- Manually inspect that swiping pages does not create a fourth page, tapping a History row pushes detail, and back navigation is present only inside the pushed detail.

**Steps:**

- [ ] Implement the three page views, local History navigation destination, read-only Day Detail, and current-week Stats composition.
- [ ] Replace the app composition root’s `WatchTodayView` call with `WatchRootView` while preserving `RippleBootstrap.start()` and the existing environment injection.
- [ ] Run the RippleFeatures suite and build the Watch scheme.
- [ ] Perform the page-swipe, History-push, and back-navigation smoke check.
- [ ] Commit navigation/pages as `feat: add Watch History Stats and page navigation`.

**Commit:** `feat: add Watch History Stats and page navigation`

## Task 11: Localize Watch copy and add complete previews

**Files:**

- Modify `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Sources/RippleFeatures/Shared/L10n.swift`.
- Modify `/Users/urkman/Development/iOS/private/ripple/Packages/RippleFeatures/Sources/RippleFeatures/Resources/Localizable.xcstrings`.
- Add/update previews in the Watch views and RippleUI Watch components from Tasks 5, 6, 9, and 10.

**Localization API and copy:**

- Reuse existing localized keys for `Today`, `History`, `Stats`, `Goal`, `Entries`, `No entries`, `No data for this period.`, `Avg / day`, `Total`, `Cancel`, `Amount`, `Week`, and `Add %@`.
- Add `L10n.custom`, `L10n.turnDigitalCrown`, and `L10n.goalDays(hitDays:elapsedDays:)` helpers. Add String Catalog entries with German and English values:
  - `Custom` → `Benutzerdefiniert` / `Custom`.
  - `Turn the Digital Crown` → `Drehe die Digital Crown` / `Turn the Digital Crown`.
  - `%lld / %lld days` → `%lld / %lld Tage` / `%lld / %lld days`.
- Add comments for interpolated entries so generated localization symbols remain understandable. Do not add ad hoc English fallback strings inside Watch views.
- Keep unit/date formatting through `VolumeFormatter(locale:)`, `Date.FormatStyle`, and the profile’s preferred unit.

**Previews:**

- Add a normal Watch preview plus a Dark + Dynamic Type XXXL + Reduce Motion preview for Today, Custom, History, Day Detail, Stats, water backdrop, quick options, log button, day row, and chart.
- Use `RippleRuntime.preview` or fixed value fixtures; previews must not write to the real store.
- Confirm previews show no clipped dominant amount, no oversized generic glass pill, no last-log line, no extra ring, and readable adaptive text.

**Verification:**

- Run `rg -n 'Text\("|accessibility(Label|Value|Hint): "' Packages/RippleFeatures/Sources/RippleFeatures/Watch` and inspect every hit; only format strings that are deliberately system-generated should remain.
- Run `swift test --package-path Packages/RippleFeatures` and `swift test --package-path Packages/RippleUI`.
- Review the String Catalog diff to ensure every new key has `de` and `en` translations.

**Steps:**

- [ ] Add the missing localization helpers/entries and remove all new inline English Watch copy.
- [ ] Add Light, Dark, XXXL, and Reduce Motion previews for each new Watch view/component.
- [ ] Run the localization audit and both affected package suites.
- [ ] Review the String Catalog diff for complete German and English coverage.
- [ ] Commit copy/previews as `chore: localize and preview Watch redesign`.

**Commit:** `chore: localize and preview Watch redesign`

## Task 12: Run package tests and verify the Watch target on simulators

**Files:**

- No new source files. Fix only defects found by the required verification commands, keeping each fix in the smallest relevant commit.

**Automated verification:**

- Run all package suites:

```bash
swift test --package-path Packages/RippleDomain
swift test --package-path Packages/RippleData
swift test --package-path Packages/RippleIntentsCore
swift test --package-path Packages/RippleUI
swift test --package-path Packages/RippleFeatures
```

- Regenerate the Xcode project with `xcodegen generate`.
- Build the Watch app with the beta toolchain already used by this workspace:

```bash
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
xcodebuild -project Ripple.xcodeproj -scheme RipplewatchOS \
  -destination 'platform=watchOS Simulator,id=E7C9A957-0AE4-4E36-9852-1AF0F8AF2C04' \
  CODE_SIGNING_ALLOWED=NO build
```

**Device verification:**

- Use the booted Apple Watch Series 11 (46 mm) simulator with UUID `E7C9A957-0AE4-4E36-9852-1AF0F8AF2C04`; install and launch the built app, capture a screenshot, and inspect it at the supplied 416 × 496 dimensions.
- Verify the Today zero state, partial fill, goal-reaching fill, predefined selection then Add, Custom Crown steps in ml and fl oz, confirmation/error state, and no accidental write on selection or Cancel.
- Swipe Today → History → Stats; verify seven elapsed newest-first rows, empty-day row, read-only Day Detail, current ISO-week summary, populated chart, and no-data chart state.
- Repeat a smoke pass on a smaller available Watch simulator, then switch Light/Dark appearance, Dynamic Type XXXL, Reduce Motion, and VoiceOver. Confirm text contrast, fixed level-zero behavior, labels, and no clipping/oversized pill.
- Use `xcrun simctl io E7C9A957-0AE4-4E36-9852-1AF0F8AF2C04 screenshot /tmp/ripple-watch-redesign.png` and inspect the resulting image with the image viewer.

**Final review:**

- Run `git diff --check` and `git status --short`.
- Run `rg -n "TodayViewModel|RippleHeroView|glassProminent|digitalCrownRotation|source: \.app|@Query|HKHealthStore|CKRecord|ProgressView|TimelineView" Packages/RippleFeatures/Sources/RippleFeatures/Watch Apps/RipplewatchOS` and confirm the Watch implementation contains none of the banned reuse/source paths; `digitalCrownRotation` is expected only in the custom Watch view.
- Confirm all required commits are present, no `.superpowers` artifacts are tracked, and the final diff contains only the approved Watch redesign plus its binding documentation.

**Steps:**

- [ ] Run all five package test commands and regenerate the Xcode project.
- [ ] Build, install, launch, and screenshot the Apple Watch Series 11 46 mm simulator.
- [ ] Exercise logging, pages, detail, Stats data/empty states, Light/Dark, XXXL, Reduce Motion, and VoiceOver on the target and a smaller simulator.
- [ ] Run the final banned-symbol/source audit, `git diff --check`, and `git status --short`.
- [ ] Commit only verification fixes as `chore: verify Watch redesign`.

**Commit:** `chore: verify Watch redesign`
