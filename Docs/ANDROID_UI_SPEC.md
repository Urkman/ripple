# Ripple Android UI Specification

**Status:** Android implementation companion specification
**Document version:** 2.0.0
**Last verified:** 2026-09-08
**Architecture:** [Ripple Android Architecture](ANDROID_ARCHITECTURE.md)
**Shared architecture:** [Ripple Architecture](ARCHITECTURE.md)
**Product contract:** [Ripple PRD](../Ripple_Handoff/Ripple_PRD.md)
**Detailed hero contract:** [Hero Motion](../Ripple_Handoff/Ripple_Hero_Motion.md)
**Detailed History/Stats contract:** [History and Stats](../Ripple_Handoff/Ripple_History_Stats.md)
**Visual reference pack:** [Android UI reference pack](AndroidUI/README.md)

This is the normative Android screen, flow, state, accessibility, and visual
acceptance contract. The current iOS implementation establishes the product
hierarchy and capability baseline. Android preserves those screens and flows,
then expresses them with Material 3, Android window-size behavior, Android
back/navigation conventions, native permission surfaces, and Compose for Wear
OS.

The existing iOS screenshots are evidence, not pixel targets. The annotated SVG
wireframes in `Docs/AndroidUI/` are Android layout contracts. Real Android and
Wear captures are the final acceptance artifacts. Nothing in this document
authorizes copying Liquid Glass, an iOS tab bar, SwiftUI navigation chrome, or
Apple Watch presentation into Android.

## 1. Source of truth and parity rule

The contract is maintained in layers:

| Concern | Authority | Android obligation |
|---|---|---|
| Product scope, platforms, domain language | `Ripple_PRD.md` and `AGENTS.md` | Preserve capability and source-of-truth rules |
| Today glass, level, pour, tilt, coalescing, reduced motion | `Ripple_Hero_Motion.md` | Reproduce behavior with Android drawing/animation primitives |
| History calendar, Day Detail, Stats, Watch behavior | `Ripple_History_Stats.md` | Preserve screens, states, and flow; choose native Android presentation |
| Current iOS hierarchy and settings/onboarding composition | iOS source and captures listed below | Do not invent a dashboard or omit a screen |
| Android layout and system substitution | This document and `AndroidUI/*.svg` | Use Android-native components and responsive layouts |

The current iOS source inspected for this revision includes:

- `Apps/RippleiOS/RootView.swift` — four roots: Today, History, Stats, Settings;
- `Packages/RippleFeatures/Sources/RippleFeatures/Today/TodayView.swift` —
  hero, remaining amount, confirmation, saved-container quick adds, and custom
  amount, with no Recent section;
- `HistoryCalendarView.swift` — horizontal month paging, one ring per day, and
  Day Detail navigation;
- `SettingsView.swift` — profile, daily goal, containers, reminders, Health,
  sync, export, and about sections;
- `OnboardingPages.swift` — six pages: Welcome, Units, Health, Goal,
  Containers, and Reminders.

### 1.1 Capability parity matrix

| Current iOS capability | Android destination | Android reference |
|---|---|---|
| Today glass hero and daily readout | Today root | [phone Today](AndroidUI/phone-today.svg) |
| Saved-container quick add and custom amount | Today root; native amount entry | [phone Today](AndroidUI/phone-today.svg) |
| Calendar-first History | History root | [phone History](AndroidUI/phone-history.svg) |
| Tap a day to inspect entries | Nested Day Detail; split on expanded windows | [phone Day Detail](AndroidUI/phone-day-detail.svg), [tablet History](AndroidUI/tablet-history-split.svg) |
| Separate period-based Stats | Stats root | [phone Stats](AndroidUI/phone-stats.svg), [tablet Stats](AndroidUI/tablet-stats.svg) |
| Full settings surface | Settings root and native sub-destinations | [phone Settings](AndroidUI/phone-settings.svg) |
| Six-page first-run flow | Onboarding route with native permission handoffs | [phone onboarding](AndroidUI/phone-onboarding.svg) |
| Watch Today/History/Stats | Wear Today/History/Stats pages | [Wear pack](AndroidUI/README.md) |

There is no Android-only Recent list, dashboard home, combined Insights
destination, month calendar on Wear, or onboarding shortcut that removes one of
the six product steps.

## 2. Android presentation principles

### 2.1 Native expression

- Compact phones use Material `NavigationBar`; medium windows use
  `NavigationRail`; expanded windows use a persistent rail or adaptive drawer.
- Root destinations use standard Android top app bars and system back behavior.
- Nested routes use typed navigation destinations and predictive back. Root
  destinations do not show a decorative back button.
- Use Material 3 buttons, chips, list items, dialogs, menus, snackbars, and
  bottom sheets where their Android semantics fit the interaction.
- Use Android Health Connect and notification permission surfaces after an
  explanatory onboarding page. Do not draw permission dialogs inside Ripple.
- Use Compose for Wear OS components and rotary input on Wear. Do not shrink a
  phone layout into a round screen.

### 2.2 Product content versus Android chrome

The glass-shaped water hero is product content and remains a deliberate custom
contained drawing. It may use Compose `Canvas`, `Path`, clipping, and Material
tonal surfaces. It must not become a circular progress indicator, a photo, or a
blurred imitation of iOS Liquid Glass.

The Android navigation surface, settings rows, dialogs, permissions, and system
surfaces are standard Android UI. A Material component is preferred even when
its shape differs from the iOS counterpart; the information hierarchy and flow,
not the platform chrome, are the parity target.

### 2.3 Product palette and shape tokens

Use `core:designsystem` for these roles. Values are the Android expression of
Ripple's shared identity, not a second product palette.

| Role | Light | Dark | Use |
|---|---|---|---|
| `rippleDeep` | `#0B3D4A` | light aqua-tinted text | Primary text and icons |
| `rippleLagoon` | `#1A7A8C` | `#4FB3C6` | Primary action, selection, success |
| `rippleAqua` | `#4FB3C6` | brighter aqua | Water fill and progress |
| `rippleFoam` | `#E8F4F6` | cool anthracite | App canvas |
| `rippleOutline` | `#B4C9CC` | cool muted outline | Quiet structure |
| `rippleDanger` | system desaturated red | system desaturated red | Delete and error only |

Use the Android default sans font, tabular/monospaced digits for numeric
readouts where supported, a 4dp grid, 12dp controls, 20dp cards, and a 28dp
hero shape. Minimum touch target is 48dp. Prefer tonal surface changes and
quiet outlines to heavy elevation. No custom font, decorative gradient, or
unrelated accent color is allowed in v1.

## 3. Navigation and responsive behavior

Use Android Window Size Classes and available width, not device-name or
`isTablet` conditionals.

| Window class | Navigation | Layout contract |
|---|---|---|
| Compact `< 600dp` | Material `NavigationBar` | One primary column; nested routes push with a top app bar |
| Medium `600–839dp` | Material `NavigationRail` | Rail plus content; two-column sections where useful |
| Expanded `≥ 840dp` | Persistent rail or adaptive drawer | List/detail panes and responsive chart columns |

The four roots never change:

```text
Today | History | Stats | Settings
```

Keep the selected root and nested selection through rotation, resize, fold
posture changes, and split screen. Apply `WindowInsets`; do not place primary
actions beneath gesture or system-bar areas. A wide window may show more
content at once, but it must not introduce a new dashboard or hide the primary
Today action.

### 3.1 Android component mapping

| Product need | Compact Android | Medium/expanded Android |
|---|---|---|
| Root navigation | `NavigationBar` | `NavigationRail` / adaptive drawer |
| Screen title/back | Material `TopAppBar` | Top app bar in content pane |
| Month paging | Full-width `HorizontalPager` or equivalent | Calendar pane pager |
| Day grid | Lazy grid with semantic day cells | Fixed calendar pane with detail beside it |
| Quick add | Filled/tonal buttons or labeled chips | Same actions in a constrained content row |
| Custom amount | Filled button or extended FAB plus standard sheet/dialog | Button in the action region; same amount route |
| Settings | Sectioned list and navigation rows | Constrained settings column or two-pane editor |
| Short undo | Snackbar with action | Same, anchored to the active content pane |
| Wear actions | Wear `Chip`/`CompactChip`, rotary input | Wear-native page composition |

## 4. Today

Today is the primary logging surface. The hierarchy is intentionally short:

```text
Today
  TopAppBar: Ripple + local date/context
  RippleHeroView: contained glass silhouette + water level + readout
  RemainingLabel: remaining amount + goal
  Confirmation: only after a completed log, then fades
  QuickAddCluster: saved containers
  CustomAmountAction: opens amount entry
  NavigationBar / Rail: Today | History | Stats | Settings
```

There is no Recent section, no additional motivation card, and no separate
last-entry block on Today. History and Day Detail are the places for inspecting
entries.

### 4.1 Compact layout

See [phone Today wireframe](AndroidUI/phone-today.svg). The hero is the visual
center and the three saved-container actions remain reachable without scrolling
on a typical compact window. Custom amount is a clearly labeled secondary
primary action, not an unlabeled symbol-only control.

The glass hero must:

- use the contained 2D silhouette and water-level rules from `Ripple_Hero_Motion.md`;
- show consumed amount, unit, percentage, remaining amount, and goal without
  clipping at large text sizes;
- have a flat idle surface and no circular `ProgressIndicator` as the daily
  level;
- keep the water visually contained while applying the specified device tilt
  behavior only where motion sensors are available;
- use one active pour stream for a coalesced add series, with the level and
  stream driven by one clock and no active-pour overshoot;
- show no fill or bottom shimmer at zero;
- use the same `LogIntake` write path as every other surface.

Android may draw the silhouette with Compose paths and animate with Compose
animation primitives, but it must not add a permanent sine loop, particles,
photoreal water, a single-drop metaphor, or simulated Liquid Glass chrome.

### 4.2 Today states

| State | Required presentation |
|---|---|
| First run | Onboarding route gates the app; do not show a fake Today behind it |
| Zero intake | Empty contained field; no water fill or bottom shimmer; quick adds visible |
| Ready | True consumed amount, percent, goal, remaining, saved containers, custom amount |
| Goal reached | Lagoon success semantics; no confetti, streak badge, or medical claim |
| Over goal | Numeric total remains true; visual level follows the capped domain rule |
| Active pour | One continuous stream for coalesced taps; numbers and confirmation settle when the pour ends |
| Save/projection error | Keep the saved log; show a retry/status message for the failed projection |
| Offline | Log locally and show sync status without disabling the action |
| Reduced motion | No stream, surface reaction, or tilt; cross-fade level in 0.20s |
| Large text | Scale the hero readout and wrap controls; never clip the amount or goal |

### 4.3 Today interaction flow

```text
tap saved container or custom amount
        -> amount confirmation if needed
        -> LogIntake(source = app)
        -> local Today snapshot refresh
        -> one coalesced pour, if motion is enabled
        -> final amount/remaining/confirmation update
        -> snackbar offers UndoLastIntake
```

Three fast taps create three store rows but one continuous visual pour. Undo
targets the last own, non-deleted intake; it does not reconstruct a visual list.

## 5. History and Day Detail

History is calendar-first. It is not a list of recent entries and is not a
combined Stats screen. See [phone History](AndroidUI/phone-history.svg),
[phone Day Detail](AndroidUI/phone-day-detail.svg), and [tablet History
split](AndroidUI/tablet-history-split.svg).

### 5.1 History root

```text
HistoryRoute
  TopAppBar: History
  MonthPager: contiguous months from first stored month through current month
    MonthHeader: month name + previous/next controls
    WeekdayRow: locale-aware first weekday
    Seven-column day grid
      DayCell: one capped progress ring + day number
  Today-only add action at the calendar/root action region
```

Required behavior:

- Swipe the complete month page horizontally; header, weekday row, and grid
  move as one page. Chevron controls operate the same pager and disable at the
  available month boundaries.
- Show one progress ring per day, with `min(1, consumed / max(goal, 1))`.
  A goal snapshot valid for that day is preferred over the current goal.
- Future days are visible but disabled and never open Day Detail.
- Past days with no entries are tappable and open an empty Day Detail.
- Today is identifiable as today and is selectable.
- Selecting a day opens Day Detail on compact windows. On expanded windows,
  keep the calendar pane visible and update the adjacent detail pane.
- The add action is available only for today. It writes the selected local day
  through the shared intake boundary; it never makes future dates tappable.
- Empty leading/trailing grid cells are not focusable or tappable.
- No mini-glass, second ring, streak flame, heatmap, or list-first replacement.

### 5.2 Day Detail route

```text
DayDetailRoute(localDate)
  TopAppBar: back + localized weekday/date
  DaySummary: consumed, goal, percent, remaining/goal reached
  Entries: time, amount, container, source, deleted state
  Row actions: edit, soft delete, restore/undo
  Today-only add action
```

On a compact phone, Day Detail is a real nested destination with Android back
behavior. On an expanded window it is the detail pane beside the calendar. A
past day never shows an enabled add action. Delete is soft delete and can be
undone or restored; edit changes the existing intake identity and must not make
a hidden duplicate. Empty past days show a clear empty state; an empty today
may include the add CTA.

### 5.3 History and detail accessibility

Each day cell announces its full date, amount, percentage, goal status, and
future/disabled status. Each intake row announces local time, amount, container,
source, and available edit/delete action. The detail summary is a single
aggregate announcement before the row collection.

## 6. Stats

Stats is its own root and remains separate from History. See [phone Stats
wireframe](AndroidUI/phone-stats.svg) and [tablet Stats wireframe](AndroidUI/tablet-stats.svg).

```text
StatsRoute(period)
  TopAppBar: Stats
  Period selector: Week | Month | Year
  Summary row: average/day, goal days, total
  Chart: actual vs goal
  Chart: goal hit rate
  Chart: daypart distribution
  Chart: container distribution
  Highlights: best day, weakest completed day, empty days, qualifying run
```

Period rules:

- Week is the current ISO week with neighboring periods available through
  native controls where supported.
- Month is the current or selected calendar month.
- Year contains twelve month categories.
- Averages include elapsed days without an entry, as specified by
  `Ripple_History_Stats.md`.
- Empty periods show a localized zero state; never fabricate chart marks.

The four chart families are:

1. actual versus goal: consumed bars plus a goal reference;
2. goal hit rate: 0–100% values for the selected period;
3. daypart distribution: morning, midday, afternoon, evening;
4. container distribution: container share with a bounded “other” group.

Use Android chart primitives or the approved chart library through the feature
boundary. Every chart has a textual summary and a value-access path for
TalkBack. Do not turn Stats into a three-ring dashboard, a GitHub heatmap, or a
History/Insights combination.

## 7. Settings

Settings is a full root destination, not a placeholder page. See [phone Settings
wireframe](AndroidUI/phone-settings.svg).

Use a scrollable Material settings list with these sections and capabilities:

1. **Profile** — name/profile values and preferred unit;
2. **Daily goal** — automatic goal from available Health Connect data or manual
   profile input, with current target visible;
3. **Containers** — create, edit, reorder/default, and delete saved containers
   used by Today quick add;
4. **Reminders** — enable/disable, schedule, wake/sleep boundaries, and
   permission status;
5. **Health Connect** — read/write status, explain access, request/revoke or
   reopen native settings where supported;
6. **Sync** — current local/cloud/device status and a recoverable retry state;
7. **Export** — start the documented export flow;
8. **About** — version, license, privacy/source links.

Use Android switches, list items, menus, dialogs, date/time pickers, and system
settings intents. Keep destructive actions explicit and reversible where the
domain supports restoration. Settings changes update the shared domain through
their use cases; a composable does not write persistence directly.

## 8. Onboarding

Onboarding is six pages. See [phone onboarding wireframe](AndroidUI/phone-onboarding.svg).

| Page | Content | System handoff |
|---|---|---|
| 1. Welcome | Ripple, the contained water-level metaphor, and the one shared logging action | None |
| 2. Units | ml or fl oz with locale-aware default | None |
| 3. Health | Explain Health Connect reads/writes and optionality | Native Health Connect permission UI |
| 4. Goal | Use available health data or enter the profile input manually; show the resulting target | Return to page and refresh state |
| 5. Containers | Seed or choose saved containers for Today quick add | None |
| 6. Reminders | Explain reminder behavior and scheduling | Native notification permission UI |

Rules:

- Show an explanatory page before a system permission surface.
- Permission denial, unavailable Health Connect, and notification denial are
  recoverable; they never block logging.
- Back works between pages. Skip is available only where the product allows
  it; units and required profile choices remain explicit.
- Returning from system UI re-reads authorization state instead of assuming
  success.
- Completing onboarding opens Today with the seeded/default state and four
  root destinations available.
- Re-entering onboarding/settings must not silently duplicate containers or
  reminders.

## 9. Wear OS

Wear is a separate Android-native surface with three horizontal pages:
Today, History, Stats. See [Wear wireframes](AndroidUI/README.md).

### 9.1 Wear Today

See [wear Today](AndroidUI/wear-today.svg). Use the full canvas as a flat
water-level field with the consumed/remaining readout. Provide predefined
amount actions and a Crown-equivalent rotary-first custom amount flow. Use Wear
chips or compact buttons; keep labels short and touch targets safe.

No idle wave loop, pour stream, surface reaction, motion tilt, or phone-sized
top-level navigation is used on Wear. The shared write boundary still applies.

### 9.2 Wear History and Day Detail

See [wear History](AndroidUI/wear-history.svg) and [wear Day Detail](AndroidUI/wear-day-detail.svg).

- Show today and the six previous elapsed local days, newest first.
- Empty days remain visible so the seven-day context is stable.
- Do not show a month calendar or month pager.
- Tapping a day opens Wear Day Detail with the daily total and individual
  entries.
- Individual entries can be deleted with a standard Wear action and restored
  with the short undo affordance. Edit and add are phone/tablet flows unless
  the Wear interaction explicitly remains within the supported Today action.

### 9.3 Wear Stats

See [wear Stats](AndroidUI/wear-stats.svg). Show only the current ISO-week
summary: average per elapsed day, goal hits, total, and one compact chart. Do
not add a period picker, multi-chart dashboard, or month navigation.

### 9.4 Wear offline behavior

Wear can commit a local log while disconnected, retain the mutation in the
outbox, and show a stale/sync status. Reconnection is idempotent by intake
identity. The UI never rolls back the local log because a Health Connect or
network projection failed.

## 10. Widgets and Android system surfaces

System surfaces stay focused and do not become alternate app dashboards.

### 10.1 Glance widgets

Provide responsive small, medium, and large layouts with a static contained
level, amount/remaining readout, and one or more quick actions. Widgets have:

- no motion tilt, pour stream, idle surface animation, calendar, or Stats chart;
- no direct persistence or Health Connect writes;
- actions routed through an application pending intent/callback to the shared
  `LogIntake` boundary;
- an explicit unavailable/stale state when the snapshot cannot be read.

### 10.2 Quick Settings, notifications, and shortcuts

- Quick Settings provides one focused logging action; custom amount may open a
  small standard Android surface.
- Reminder notifications use the standard Android template, remaining amount,
  and one default log action.
- Shortcuts/App Actions deep-link to Today or the supported amount entry and
  still use the shared write boundary.
- None of these surfaces renders a month calendar, Stats charts, pour stream,
  or sensor tilt.

## 11. State matrix

Every screen implements these states and their TalkBack semantics.

| State | Today | History/Day Detail | Stats | Settings/Onboarding | Wear/system surfaces |
|---|---|---|---|---|---|
| First run | Six-page onboarding gate | Not required before onboarding completion | Not required before onboarding completion | Setup/permission state | Focused default state |
| Loading | Quiet hero/snapshot loading; no fake water animation | Calendar/detail skeleton | Summary/chart skeleton | Row/page loading | Last-known snapshot or loading |
| Empty | Zero fill; quick add visible | Empty month/day message; today can add | Localized empty period; no fake marks | Defaults and setup prompts | Remaining/goal unavailable message |
| Ready | Hero, readout, quick adds, custom amount | Rings, selected day, entries | Summary and four accessible charts | Current values and native controls | Focused current surface |
| Goal reached | Success semantics without celebration noise | Day ring caps at 1.0 | Hit data remains visible | No hidden goal mutation | Ring/readout reflects state |
| Over goal | True numeric total; capped visual rule | Ring remains capped | Over-goal values remain true | No normalization | Numeric state remains true |
| Save/projection error | Keep local log; show status/retry | Keep local summary; retry projection | Keep local data; explain unavailable projection | Recoverable retry | Stale/error indicator, not a crash |
| Offline | Local logging remains available | Local history remains available | Local stats remain available | Local changes remain visible | Outbox/stale state |
| Permission denied | Logging remains enabled | No permission block | Goal fallback is explicit | Reopen/retry native settings | No Health Connect dependency on Wear |
| Reduced motion | No stream/reaction/tilt; cross-fade only | No ring-spin/page flourish | Disable decorative chart transitions | No decorative motion | No idle motion |
| Large text | Hero scales and actions wrap | Day cells/rows remain readable | Chart data has text alternative | Rows wrap; no clipping | Scroll and concise labels |

## 12. Interaction flows

### 12.1 Log, coalesce, undo

```text
Today / Wear / widget / notification / Tile / shortcut
        -> shared amount input
        -> LogIntake(amount, source, date)
        -> local store row with stable identity
        -> snapshot refresh + outbox/projection work
        -> Android hero/confirmation settles
        -> UndoLastIntake when explicitly requested
```

Every source calls the same domain boundary. UI state must not invent a second
amount formula, direct Room write, or local-only undo stack.

### 12.2 History to Day Detail

```text
History month pager -> tap past/today -> DayDetail(localDate)
                                      -> inspect entries
                                      -> edit existing entry
                                      -> soft delete / undo / restore
                                      -> add only when localDate is today
```

On compact windows Day Detail is a real nested destination. On expanded windows
the calendar and detail remain visible together.

### 12.3 Onboarding permissions

```text
explanation page -> Android system permission surface -> return
                  -> re-read state -> granted or denied/recoverable
```

The app remains usable when Health Connect or notifications are denied.

### 12.4 Wear offline/reconnect

```text
Wear tap/rotary amount -> local LogIntake -> outbox while offline
      -> show local result and stale status
      -> reconnect -> idempotent phone/apply -> refreshed snapshot
```

## 13. Accessibility and input

- TalkBack reads the Today hero as consumed amount, goal, remaining amount,
  percentage, and current state in one coherent aggregate.
- Quick-add controls announce the exact amount and source action.
- Calendar cells announce date, amount, percentage, goal status, and disabled
  future state.
- Intake rows announce time, amount, container, source, and available row
  actions.
- Charts expose a textual summary and navigable values; marks are never the
  only data channel.
- Native permission and settings rows expose current authorization and the
  action that opens the system surface.
- Touch targets are at least 48dp; keyboard/focus navigation reaches primary
  actions on tablets and ChromeOS-compatible windows.
- Wear rotary input changes custom amount in stable increments and announces the
  current amount.
- Support light/dark themes, font scale through 2.0, and reduced motion without
  clipping, disappearing actions, or loss of meaning.
- Use localized DE and EN copy; do not hardcode English in the German locale.

## 14. Visual reference and acceptance captures

The reference pack links the current iOS evidence:

- [iPhone Today](../release/screenshots/raw/en-US/iphone-69/01-today.png)
- [iPhone History](../release/screenshots/raw/en-US/iphone-69/02-history.png)
- [iPhone Stats](../release/screenshots/raw/en-US/iphone-69/03-stats.png)
- [iPad Settings](../release/screenshots/raw/en-US/ipad-129/04-settings.png)
- [Watch Today](../release/screenshots/raw/en-US/watch-46/01-today.png)
- [Watch History](../release/screenshots/raw/en-US/watch-46/02-history.png)
- [Watch Stats](../release/screenshots/raw/en-US/watch-46/03-stats.png)

Store runtime Android captures under `release/screenshots/android/` with stable
names:

| Capture | Target/state |
|---|---|
| `phone-compact-today-light` | ready Today, light |
| `phone-compact-today-dark` | ready Today, dark |
| `phone-compact-today-empty` | zero intake |
| `phone-compact-today-pour` | active coalesced pour |
| `phone-compact-history` | populated month |
| `phone-compact-day-detail` | entries and row actions |
| `phone-compact-stats-week` | Week summaries and charts |
| `phone-compact-settings` | full Settings sections |
| `phone-compact-onboarding` | Health or notification handoff |
| `tablet-history-split` | expanded month plus Day Detail |
| `tablet-stats` | expanded responsive charts |
| `wear-today` | Wear quick logging |
| `wear-history` | seven-day list |
| `wear-day-detail` | individual delete |
| `wear-stats` | current ISO week |
| `widget-small`, `widget-medium`, `widget-large` | static widgets |
| `notification-reminder` | notification shade |
| `quick-settings-tile` | focused Tile action |

Review each capture for hierarchy, content, state, token/contrast, touch target,
accessibility, and platform behavior. Do not judge Android by pixel equality to
the iOS evidence. A failure is classified as content, layout, token, state,
accessibility, or platform-behavior mismatch.

## 15. Implementation handoff

| UI responsibility | Android module |
|---|---|
| Theme, dimensions, typography, shapes, semantics | `core:designsystem` |
| Today hero and logging controls | `feature:today` |
| Month grid and Day Detail | `feature:history` |
| Period selection, summaries, and charts | `feature:stats` |
| Profile, goal, containers, reminders, Health, sync, export | `feature:settings` |
| Six-page setup and permission handoffs | `feature:onboarding` |
| Glance widgets | `system:widgets` |
| Quick Settings and notification | `system:quicksettings` / `system:notifications` |
| Shortcuts/App Actions | `system:appactions` |
| Wear pages, outbox status, complications/Tiles | `wear` |

Every feature screen supplies loading/content/error/permission-sensitive state,
previews or fixtures for empty/ready/error/dark/large-text/reduced-motion
states, and Compose semantics tests for primary actions. Composables do not
write Room, Health Connect, AlarmManager, WorkManager, or the Data Layer
directly.

## 16. Definition of UI complete

- [ ] Four Android roots are present: Today, History, Stats, Settings.
- [ ] Today has the contained hero, saved-container quick adds, and custom
      amount, with no Recent list or replacement dashboard.
- [ ] History has horizontal month paging, one ring per day, disabled future
      days, and a real Day Detail route.
- [ ] Day Detail exposes entry inspection and edit/delete/restore semantics;
      add is possible only for today.
- [ ] Stats is separate and has Week/Month/Year, summaries, four chart
      families, highlights, empty states, and TalkBack data.
- [ ] Settings has all eight product sections and native Android controls.
- [ ] Onboarding has all six pages and recoverable native permission handoffs.
- [ ] Wear has Today, seven-day History plus Day Detail, and current ISO-week
      Stats without a month calendar or period picker.
- [ ] Widgets, notifications, and Quick Settings remain focused and static.
- [ ] Light/dark mode, large text, TalkBack, reduced motion, offline, empty,
      and error states are reviewed on representative targets.
- [ ] Runtime Android captures are stored and reviewed against this contract.

## 17. Maintenance and timeline

This document is maintained with [Ripple Android Architecture](ANDROID_ARCHITECTURE.md)
and [Ripple Architecture](ARCHITECTURE.md). When a screen, interaction,
breakpoint, token, state, system surface, or accessibility contract changes,
update the relevant document in the same change and append an immutable Timeline
entry. Use semantic versions: MAJOR for incompatible UI/workflow contracts,
MINOR for new screens/states/surfaces, and PATCH for corrections or
clarifications. Historical entries are immutable; newest entries are appended
at the bottom.

| Version | Date | Change | Impact |
|---|---|---|---|
| 1.0.0 | 2026-09-07 | Initial Android UI companion with Material/Wear guidance, responsive layouts, state matrix, flows, and capture naming. | Established native Android presentation rules. |
| 2.0.0 | 2026-09-08 | Rebased the Android contract on the current iOS hierarchy: four roots, no Today Recent list, calendar-first History with Day Detail, separate Stats, full Settings, six-page onboarding, and the current Wear flow; added linked SVG reference pack and evidence mapping. | Android implementation now has the same product screens and flows as iOS while retaining native Android components and system surfaces. |
