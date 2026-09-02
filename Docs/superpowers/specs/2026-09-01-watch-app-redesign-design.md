# Ripple Watch app redesign

Status: Design decisions and written spec approved in chat; implementation plan follows.
Date: 1 September 2026

## Follow-up amendment — 2 September 2026

The Watch Today logging flow is intentionally sheet-first. Today exposes one
primary `+` action that opens the amount sheet; it does not commit an intake
itself. The sheet contains the first three saved-container quick amounts and
the Crown-controlled amount, so amount selection and confirmation stay in one
focused surface.

The Crown uses exact 10 ml steps for the stored integer-milliliter value,
clamped to 50–2,000 ml. When the profile displays fluid ounces, the selected
10 ml value is converted for display; the Crown still advances by 10 ml.

Watch Today may respond to real wrist movement with one short, damped surface
disturbance. This is a sensor-triggered response, not an idle animation: it
must not loop while the wrist is still, must be disabled by Reduce Motion, and
must remain inert in Simulator and other environments without Watch motion
data. The stored water level remains the midpoint level and is animated with
the existing restrained liquid transition when Today data changes.

The 46 mm Today composition uses compact, tokenized top and bottom insets
while extending its content stack through the system vertical safe-area
padding. This keeps the header close to the clock and the `+` dock close to
the page indicator without changing the full-canvas water field.

The amount sheet keeps the quick amount row and live `Add {amount}` action as
the visible amount controls. It does not repeat the selected amount in a
separate dominant readout. The Crown always adjusts the current amount in
10-ml steps; there is no separate custom-mode `+` control. The system-provided
top `×` is the only dismissal action, so the sheet has no redundant bottom
Cancel button.

Watch History and Watch Stats both use a page-local `NavigationStack`, so
their titles remain in the navigation context and collapse to the compact
navigation-bar position while scrolling. Today remains stackless because its
full-canvas field owns the page and amount entry is presented as a sheet.

The Watch app prefers the dark appearance as its default OLED-first
presentation. Watch surfaces and water accents use explicit dark-safe RippleUI
tokens so the default remains reliable on watchOS; the shared RippleUI color
assets remain adaptive for the other platforms and accessibility previews.

## Context

The current Watch target is a thin vertical stack that reuses the iPhone hero. On a 416 × 496 Apple Watch Series 11 canvas, the hero is clipped at the top, the system glass-prominent button expands into an oversized pill, the important goal context is not visible, and the readout has insufficient contrast in the dark appearance. The Watch also logs through `TodayViewModel`, whose source is hard-coded to `.app`, and its Crown amount is treated as milliliters even when the selected unit is fluid ounces.

The Watch should be a useful companion rather than a logging-only surface. It will provide a glanceable Today view, a lightweight recent History view, and a compact Stats view while preserving the shared Ripple domain and persistence boundaries.

## Binding-spec amendments required before implementation

The current binding documents describe Watch as “ring + plus + crown” and explicitly exclude Watch Stats. The approved design changes that contract. Before any Watch code is edited, update:

1. `AGENTS.md` — replace the Watch platform rule with the three-page design in this document and remove the “no stats charts” restriction for the Watch app. Keep the restriction for Watch complications where applicable.
2. `Ripple_Handoff/Ripple_PRD.md` — update the Apple Watch platform section, the Watch definition of done, and any statement that limits Watch to logging or excludes Watch Stats.
3. `Ripple_Handoff/Ripple_History_Stats.md` — define the Watch-specific recent-day list, deletable-entry day detail, and single weekly chart. The iPhone/iPad calendar and multi-chart requirements remain unchanged.

The hero motion contract remains authoritative for iPhone Today and for Watch complications. The Watch app uses no pour stream or tilt; its full-screen water level is a separate Watch presentation of the stored level. The Watch Today surface may use only the bounded wrist-movement response described in the follow-up amendment above.

## Product decisions

### Navigation

The Watch app has three horizontal pages in a platform-local `TabView` page container:

- **Today** — selected on launch and the primary logging surface.
- **History** — the latest seven elapsed calendar days.
- **Stats** — the current ISO week.

The page container is not an app-wide router and does not introduce a tab bar. The native page indicator is visible and identifies the three pages. History pushes a local `DayDetail` page when a day is selected. There is no month calendar on Watch.

### Today

Today is a full-canvas `ZStack` rather than a glass illustration:

- A water field rises from the bottom of the Watch canvas to `min(max(consumed / goal, 0), 1.05)`.
- The surface is a single quiet horizontal line. It is not a progress bar and is not accompanied by a ring.
- At zero consumption the water field, surface line, and any water glow are absent.
- The foreground contains `Today`, the consumed amount, the remaining amount, and the percentage as text.
- The lower action dock contains one `+` CTA that opens the amount sheet.
- The amount sheet contains the first three predefined values and the current Crown selection.
- Selecting a predefined value updates the amount in the sheet; the `Add {amount}` action commits it. Opening or selecting an amount does not write an intake by itself.
- Turning the Crown adjusts the current amount in 10-ml steps and changes the pending log to a custom amount without a container ID.
- The system-provided top `×` dismisses the sheet and restores the pending selection; there is no second Cancel button.
- After a successful write, Today updates in place and may provide success haptic feedback; no confirmation copy is inserted into the layout.

The composition uses RippleUI colors and typography. The Watch app prefers the
dark presentation shown in the approved mockups as its OLED-first default, and
the Watch surface must still resolve correctly in both system appearances.
`waterDeep` must never be used as unreadable text on a dark surface.

There is no Core Motion tilt, idle sine wave, pour stream, or spring overshoot on Watch Today. A normal level update may use a restrained liquid transition. On a real Watch, wrist movement may trigger one damped surface disturbance that returns to a flat line; it is never a free-running animation. Reduce Motion disables the disturbance and uses a 0.20-second cross-fade for level changes.

### Predefined and custom logging

The first three sorted saved containers are presented as predefined values in the amount sheet. Their labels and amounts come from the snapshot, so the Watch does not invent a second container configuration. If fewer than three containers exist, the row collapses to the available values and the Crown selection remains available.

The amount screen is a focused sheet with:

- the first three predefined quick amounts;
- the selected amount shown in the live Add action;
- the unit shown explicitly;
- a `Turn the Digital Crown` hint;
- a single `Add {amount}` confirmation action;
- the system-provided top `×` dismissal that returns to Today without writing.

The Crown selection uses exact 10 ml steps for both profile units. The selected value is stored internally as integer milliliters and converted only for display. The selectable range is 50–2,000 ml, clamped to the nearest 10 ml step. Quick-container writes retain their selected `containerId`; Crown-adjusted writes pass `containerId: nil`.

All Watch writes call:

```swift
useCases.logIntake.run(
    amount: Milliliters(selectedAmountMl),
    source: .watch,
    date: Date(),
    containerId: selectedContainerID
)
```

The view model owns selection and presentation state; it does not implement persistence, HealthKit, or reminder behavior.

### History

History shows a rolling window of seven elapsed local calendar days, ending today. Future days are not shown. Each row contains:

- localized weekday and short date;
- consumed amount and goal;
- a horizontal water bar capped at 100%;
- a disclosure affordance indicating that the row is tappable.

The list is ordered newest first. Empty days remain visible and show zero consumption. Tapping a row pushes `WatchDayDetailView`, which shows the selected date, total, goal percentage, and that day’s intake rows sorted newest first. Intake rows show time and amount, with container/source when available. Each intake row exposes a trailing destructive swipe action that calls the existing soft-delete use case. The day detail refreshes after deletion and offers the existing temporary Undo action through `RestoreIntake`; editing and logging remain on iPhone/iPad.

History does not use a ring, a month grid, a chart wall, or a second progress metaphor.

### Stats

Stats is fixed to the current ISO week. It contains:

- average per elapsed day;
- days whose goal was reached, formatted as `{hitDays} / {elapsedDays}`;
- total volume for the week;
- one compact Swift Charts bar chart with seven day categories and a subtle goal reference.

The chart is supportive, not interactive. There is no period picker and no Month/Year mode on Watch. The empty state is localized and contains no fabricated bars.

The values and the chart’s source data come from `ObserveStats`. The Watch view does not recalculate averages, hit rates, goals, or totals.

## Architecture and boundaries

### Composition root

`Apps/RipplewatchOS/RippleWatchApp.swift` remains the composition root. It creates the existing `RippleContainer` and injects `UseCases` into `WatchRootView`. No business rule or alternate store is added to the app target.

### RippleFeatures

Add a focused Watch feature area:

```text
Packages/RippleFeatures/Sources/RippleFeatures/Watch/
  WatchRootView.swift
  WatchTodayView.swift
  WatchTodayViewModel.swift
  WatchHistoryView.swift
  WatchHistoryViewModel.swift
  WatchDayDetailView.swift
  WatchDayDetailViewModel.swift
  WatchStatsView.swift
  WatchStatsViewModel.swift
  WatchCustomAmountView.swift
```

Each view model is `@MainActor @Observable` and receives `UseCases` through its initializer. View models are orchestration only:

- `WatchTodayViewModel` observes Today, manages selected amount/Crown state, calls `LogIntake`, and exposes a success-feedback event plus error state.
- `WatchHistoryViewModel` requests the recent seven-day `HistorySnapshot`, maps rows, and owns the selected day.
- `WatchDayDetailViewModel` requests the selected day through the existing Today read API and exposes its entries and summary.
- `WatchStatsViewModel` requests the current ISO-week `StatsSnapshot` and exposes the already-calculated summary values and chart points.

No Watch view imports SwiftData, CloudKit, HealthKit, WidgetKit, or a repository. No Watch view writes through `@Query`.

### RippleDomain

Extend the existing `HistoryRange`/`DayWindow` read model with `recentDays(anchor: Date, count: Int)` so History can obtain one bounded range without seven independent Today reads. For Watch, `count` is always 7; the range starts at the local start of day six calendar days before `anchor` and ends immediately after the local start of `anchor`’s following day. This is not a new write path or a new source of truth. `ObserveHistory` remains the single feature-facing API for the list.

The range is local-calendar aware and must handle daylight-saving transitions through `Calendar` date arithmetic. `ObserveStats` continues to use `StatsPeriod.week` and ISO-week bounds.

### RippleUI

Add reusable, token-backed Watch components:

- `WatchWaterBackdrop` — full-canvas water field, flat idle surface line, and an optional bounded wrist-movement response; no progress ring.
- `WatchQuickAmountRow` — compact selectable predefined values.
- `WatchLogButton` — fixed, compact primary action with Watch hit target and Ripple motion.
- `WatchDayRow` — daily total and capped water bar.
- `WatchStatChart` — one compact weekly Swift Charts presentation.

These components use `RippleColor`, `RippleFont`, `RippleSpace`, `RippleRadius`, and named Watch layout metrics. They do not contain use-case calls. The existing generic `.glassProminent` style is not used for the Watch primary action.

The color token implementation must provide explicit dark-safe Watch surface,
text, and water variants for the approved OLED-first presentation. Shared
RippleUI colors remain adaptive where the platform resolves asset luminosity
variants, and Watch text must preserve readable contrast on the dark surface.

### Data flow

```text
WatchRootView
  ├─ WatchTodayViewModel ── ObserveToday
  │                       └─ LogIntake(source: .watch)
  ├─ WatchHistoryViewModel ── ObserveHistory(.recentDays)
  │                          └─ WatchDayDetailViewModel ── ObserveToday(day)
  └─ WatchStatsViewModel ── ObserveStats(.week)
```

All writes continue through `LogIntake`. Its existing projection behavior remains authoritative: a HealthKit failure does not roll back the intake, widget reload and reminder scheduling remain inside the use case, and the Watch does not call those services directly.

## Lifecycle, errors, and accessibility

Each page refreshes on first appearance and when the Watch scene becomes active. An in-flight refresh is cancellable. The last valid snapshot remains visible when a refresh fails; if no snapshot exists, the page shows a localized `EmptyState`/error state with a retry action. Logging failures preserve the selected amount and show an accessible inline error; they do not silently reset the Crown.

VoiceOver must expose:

- Today’s consumed amount, goal, remaining amount, percentage, and selected amount;
- each predefined amount with selected/unselected state;
- the `+` amount-sheet action and current Crown amount;
- each History row’s date, consumption, goal, and status;
- Day Detail entries with time, amount, container, and source;
- Stats summary values and the weekly chart as a concise period summary.

All user-facing text is provided through the existing localization resources in German and English. Dates and units follow the system locale and profile preference. Numbers use tabular/monospaced digits where the existing Ripple typography specifies them.

Every new or materially changed component receives Light, Dark, Dynamic Type through XXXL, and Reduce Motion previews. Watch layout must remain usable on 40/41 mm, 44 mm, 45 mm, 46 mm, and 49 mm canvases; smaller canvases may scroll the History and Day Detail pages, but Today keeps the water backdrop fixed behind its content.

## Testing and verification

Add or update tests for:

1. Recent seven-day History range boundaries, including local midnight and daylight-saving transitions.
2. Watch Today default selection and predefined container identity.
3. Crown stepping in exact 10 ml increments for both profile units.
4. Fluid-ounce display conversion while preserving 10 ml Crown increments.
5. Custom range clamping and initial selection.
6. Watch logging passing source `.watch`, selected container ID for predefined values, and `nil` for Custom.
7. Failed logging preserving selection and exposing an error.
8. History day-detail filtering and newest-first ordering.
9. Stats using the current ISO week and showing an empty state without synthetic data.
10. `WatchWaterBackdrop` producing no water/surface path at level zero, capping the visual level, and settling its wrist response.

After implementation, build and run the Watch target on the Apple Watch Series 11 46 mm simulator shown in the supplied screenshot, then verify a smaller Watch size, Light/Dark appearance, Dynamic Type XXXL, Reduce Motion, VoiceOver labels, predefined logging, Custom logging, History navigation, and Stats empty/data states.

## Explicit non-goals

- No Watch month calendar.
- No Watch Month/Year Stats picker.
- No Watch editing of intakes; deletion is limited to the individual-entry action in Day Detail.
- No third-party UI library.
- No separate Watch persistence, UserDefaults source of truth, HealthKit query, or CloudKit record access.
- No pour stream, Core Motion tilt, idle loop, circular progress ring, or glass-shaped hero on Watch Today. Wrist response is allowed only as the bounded sensor-triggered disturbance defined above.
- No changes to iPhone/iPad History or Stats behavior beyond the required shared range model and documentation updates.

## Acceptance criteria

- The Watch Today screen is readable and fully contained on the Series 11 46 mm canvas.
- The full-screen water field is the sole Today progress visualization.
- The primary logging action is compact, intentional, and never expands to the current oversized generic pill.
- Predefined values and Crown-first Custom logging both write through `LogIntake` with source `.watch`.
- Today, History, and Stats are separate swipe pages.
- History presents seven recent elapsed days and a day detail with individual-entry deletion and Undo.
- Stats presents current-week average, goal days, total, and one compact Swift Charts view.
- Light/Dark, Dynamic Type, Reduce Motion, VoiceOver, German, and English are supported.
- Domain, feature, and UI tests cover the listed behaviors and remain green.
