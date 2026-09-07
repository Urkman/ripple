# Ripple Android UI Specification

**Status:** Android implementation companion specification

**Document version:** 1.0.0

**Last verified:** 2026-09-07

**Architecture:** [Ripple Android Architecture](ANDROID_ARCHITECTURE.md)

**Product contracts:** [Ripple PRD](../Ripple_Handoff/Ripple_PRD.md), [Hero Motion](../Ripple_Handoff/Ripple_Hero_Motion.md), [History and Stats](../Ripple_Handoff/Ripple_History_Stats.md)

This document removes screen-level ambiguity from the Android port. It defines the Android-native information architecture, layouts, interaction states, responsive behavior, Wear OS surfaces, system surfaces, and visual acceptance captures.

The Android UI must preserve Ripple's capability and domain behavior while looking and behaving like an Android app. These wireframes are layout contracts, not pixel art. The implementation uses Material 3, Android window-size behavior, Android system navigation, and Compose for Wear OS rather than copying SwiftUI, iOS tabs, Liquid Glass, Apple Watch workflows, or iOS screenshots.

## 1. Design intent

### 1.1 The person and the job

The person opens Ripple while moving through an ordinary day: at a desk, between meetings, after exercise, or while reaching for a phone/watch. The primary job is to record an amount in seconds and understand whether the day is on track without reading a dashboard.

The product should feel calm, physical, and measured:

- calm enough to use repeatedly;
- physical enough that water level and pouring explain progress without a chart lesson;
- measured enough that numbers, goals, and history remain precise;
- native enough that Android users recognize system navigation, controls, permissions, and back behavior.

### 1.2 Domain vocabulary

The UI should draw its expression from the product's world:

1. water level and a contained glass;
2. a quiet daily rhythm rather than a streak;
3. measured pours rather than collectible drops;
4. a personal container on a desk or in a bag;
5. wake/sleep pacing and gentle reminders;
6. an activity calendar that records days without turning them into a game board.

### 1.3 Color world

The palette comes from a cool glass of water in a quiet room:

- deep teal for ink and structure;
- lagoon teal for action and goal success;
- clear aqua for water and progress;
- pale foam for the light canvas;
- cool anthracite for dark surfaces;
- desaturated red only for destructive actions and errors.

No orange, purple, neon gradient, or unrelated semantic accent is introduced in v1.

### 1.4 Product signature

The signature element is the **contained water-level hero with a quick-add action**: the user adds an amount, sees one coherent pour, and then gets a settled readout that explains remaining volume. The signature is an interaction and a hierarchy, not a decorative glass card.

### 1.5 Defaults deliberately rejected

| Common default | Ripple Android replacement |
| --- | --- |
| Copy the iOS tab bar and sheets | Material `NavigationBar`, `NavigationRail`, adaptive drawer, Android back stack, and native bottom sheets only when appropriate |
| Use a circular progress indicator for hydration | A custom contained water-level field with a numeric readout |
| Build a dashboard of equal metric cards | Lead with the action and water state; expose secondary data through History, Stats, and settings sections |
| Use screenshots as the specification | Use annotated wireframes, state tables, and real-device acceptance captures |
| Use glass/blur everywhere | Use Material tonal surfaces, quiet borders, and a single deliberate water surface |

## 2. Responsive form factors

Use Android Window Size Classes and actual available width, not device-name conditionals.

| Window class | Width guidance | Navigation | Content behavior |
| --- | --- | --- | --- |
| Compact | `< 600dp` | Material `NavigationBar` | One primary column; nested screens use top app bar and system back |
| Medium | `600–839dp` | Material `NavigationRail` | Content beside rail; two-column sections where useful |
| Expanded | `≥ 840dp` | Persistent navigation or `ModalNavigationDrawer` | List/detail panes, responsive chart columns, wider settings layout |

Rules:

- Do not use `isTablet` or device model names to choose a layout.
- Preserve state during resize, fold posture changes, rotation, and split screen.
- Keep the primary action reachable in compact layouts and visible in expanded layouts.
- Use a content max width for reading/settings regions so wide tablets do not become stretched forms.
- Use `WindowInsets` and edge-to-edge correctly; never place controls under system gesture areas.

## 3. Android design tokens

All feature UI uses `core:designsystem`. These values are the Android expression of Ripple's identity; they are not copied SwiftUI constants.

### 3.1 Color roles

| Role | Light value | Dark value | Use |
| --- | --- | --- | --- |
| `rippleDeep` | `#0B3D4A` | `#D7F1F4` | Primary text/icons; dark-mode text is light aqua-tinted |
| `rippleLagoon` | `#1A7A8C` | `#4FB3C6` | Primary action, selected state, success |
| `rippleAqua` | `#4FB3C6` | `#70C9D8` | Water fill, progress, secondary emphasis |
| `rippleFoam` | `#E8F4F6` | `#18272B` | Light canvas / dark base surface |
| `rippleSurface1` | `#F2F8F9` | `#203237` | Raised Material surface |
| `rippleSurface2` | `#FFFFFF` | `#273D43` | Dialog/menu or stronger raised surface |
| `rippleOutline` | `#B4C9CC` | `#526B70` | Quiet structural border |
| `rippleDanger` | system desaturated red | system desaturated red | Delete/error only |

Map these to Material color roles once in `RippleTheme`. Do not enable uncontrolled Android dynamic colors in v1; the Ripple palette must remain recognizable across devices.

### 3.2 Typography

Use the Android default sans font. Do not bundle a custom font or use San Francisco. Numeric values use tabular/monospaced digit features where the platform supports them.

| Role | Size / line height | Weight | Use |
| --- | --- | --- | --- |
| Display | 36sp / 40sp | Regular | Today hero amount |
| Headline | 28sp / 34sp | Medium | Screen title or major summary |
| Title | 22sp / 28sp | Medium | Section/card title |
| Body | 16sp / 24sp | Regular | Primary content |
| Body secondary | 14sp / 20sp | Regular | Supporting content |
| Label | 14sp / 20sp | Medium | Buttons, navigation, selected controls |
| Caption | 12sp / 16sp | Medium | Metadata and timestamps |

Hero numbers may scale down to prevent clipping, but never below the readable body scale. Text must survive font scale 2.0.

### 3.3 Space, shape, and depth

- Base grid: 4dp.
- Common spacing: 4, 8, 12, 16, 20, 24, 32, 40dp.
- Minimum touch target: 48dp.
- Small control shape: 12dp.
- Card/section shape: 20dp.
- Hero shape: 28dp.
- Dialog shape: Material default large shape, visually aligned with the 28dp hero family.
- Depth strategy: tonal surface shifts first, quiet borders second, minimal elevation third.
- Suggested tonal elevations: base 0dp, raised 1dp, interactive 3dp, dialog 6dp.
- No dramatic shadows, thick borders, gradients, decorative blur, or pure-white cards floating over pale foam.

### 3.4 Iconography

Use one Android-native icon family consistently: Material Symbols/Compose Material icons with rounded geometry where available. Icons clarify actions and are paired with labels when meaning is not universally obvious. Do not use SF Symbols or a custom drop icon as the add metaphor.

## 4. Navigation and information architecture

### 4.1 Top-level destinations

The Android app has four top-level destinations:

```text
Today     History     Stats     Settings
```

Compact wireframe:

```text
┌────────────────────────────────┐
│ content for the selected root  │
│                                │
│                                │
├────────────────────────────────┤
│  Today   History   Stats   ⚙   │  Material NavigationBar
└────────────────────────────────┘
```

Medium/expanded layouts replace the bottom bar with a rail or drawer. The destinations do not change.

### 4.2 Nested navigation

Use typed Android navigation destinations owned by the app UI layer:

```text
TodayRoute
HistoryRoute
HistoryDayRoute(localDate)
StatsRoute(period)
SettingsRoute
SettingsGoalRoute
SettingsContainersRoute
SettingsRemindersRoute
SettingsHealthRoute
OnboardingRoute(step)
```

The domain never receives route strings. A nested destination has a standard Android top app bar and system back/predictive-back behavior. Root destinations do not show an artificial back button.

### 4.3 Android interaction conventions

- Use standard top app bars, Material buttons, chips, FABs, dialogs, menus, snackbars, and bottom sheets.
- Use snackbar actions for short-lived undo; do not create an iOS-style transient overlay stack.
- Use dialogs for confirmation/destructive actions and short choices; use a full destination for substantial editing.
- Use the system back gesture/button for nested screens and preserve predictive-back animation.
- Keep a single obvious primary action per screen.
- Do not hide essential logging behind a navigation drawer or overflow menu.

## 5. Phone and tablet wireframes

The diagrams show hierarchy and behavior. Exact pixel dimensions are resolved by Window Size Class and tokens.

### 5.1 Today — compact

```text
┌────────────────────────────────┐
│ Ripple                    ⋮    │  Top app bar / overflow
│ Tuesday, 7 September            │  Local day context
│                                │
│        ┌──────────────┐        │
│        │              │        │
│        │  1 250 ml    │        │  WaterLevelHero
│        │  750 ml left │        │  No circular progress
│        │ ~~~~~~~~~~~~ │        │  Flat surface when idle
│        └──────────────┘        │
│                                │
│ Quick add                       │
│ [ +250 ] [ +500 ] [ +750 ]     │  Material buttons/chips
│                                │
│ Recent                          │
│  09:10     500 ml       App    │
│  07:40     250 ml       Watch  │
│                                │
│                         ( + )  │  FAB for custom amount
├────────────────────────────────┤
│ Today   History   Stats   ⚙    │
└────────────────────────────────┘
```

Required states:

- first run: onboarding gate, no empty Today surface behind it;
- zero intake: empty water field, no fill or bottom shimmer;
- normal day: water level, remaining, quick actions, recent rows;
- goal reached: success role and positive copy without confetti or streak language;
- over goal: cap the visual level according to the domain contract and show the true total numerically;
- active pour: one continuous stream for coalesced taps, numbers remain stable until pour ends;
- error: saved log remains visible; projection/system failure appears as status/snackbar;
- reduced motion: no stream/surface reaction/tilt, cross-fade only.

### 5.2 Today — medium/expanded

```text
┌──────────────┬──────────────────────────────────────────────┐
│ ≡            │ Today                              ⋮           │
│              ├──────────────────────────────────────────────┤
│  Today       │             ┌─────────────────┐              │
│  History     │             │                 │              │
│  Stats       │             │   water hero    │              │
│  Settings    │             │                 │              │
│              │             └─────────────────┘              │
│              │      [ +250 ] [ +500 ] [ +750 ]   ( + )      │
│              │──────────────────────────────────────────────│
│              │ Recent intake rows / sync status             │
└──────────────┴──────────────────────────────────────────────┘
```

The hero remains the focal point, but secondary rows use the available width. Do not stretch every control to tablet width.

### 5.3 History — compact

```text
┌────────────────────────────────┐
│ History                    ⋮   │
│ <        September 2026     >  │  Month selector
│ Mon Tue Wed Thu Fri Sat Sun    │
│       1   2   3   4   5   6     │
│  7   8   9  10  11  12  13     │  One ring per day
│ 14  15  16  17  18  19  20     │  Future days disabled
│ 21  22  23  24  25  26  27     │
│ 28  29  30                      │
│                                │
│ Selected day                    │
│ Tue, 8 Sep          1 250 ml    │
│ Goal reached                    │
├────────────────────────────────┤
│ Today   History   Stats   ⚙    │
└────────────────────────────────┘
```

The calendar uses a Material-friendly grid with accessible day semantics. A future day has no click action and is announced as unavailable.

### 5.4 Day Detail

```text
┌────────────────────────────────┐
│ ‹  Tuesday, 8 September         │  Standard Android back
│    1 250 ml of 2 000 ml         │
│    63%                           │
│                                │
│ 09:10     500 ml       App      │
│ 07:40     250 ml       Watch    │
│ 06:55     500 ml       Widget   │
│                                │
│ [edit]  [delete]                │
│                                │
│                         ( + )  │  Only when this is today
└────────────────────────────────┘
```

Delete opens an Android confirmation dialog or uses an explicitly reversible snackbar action. Restore returns the same intake identity. Editing never creates a second hidden row.

### 5.5 Stats — compact

```text
┌────────────────────────────────┐
│ Stats                          │
│ [ Week ] [ Month ] [ Year ]     │  Segmented buttons/dropdown
│                                │
│ 1 820 ml average     5/7 days │  Summary first
│                                │
│        daily progress chart    │  Canvas chart + TalkBack table
│     ▂ ▆ ▅ ▇ ▃ ▆ ▇              │
│                                │
│ Day parts                         │
│ Morning       38%              │
│ Afternoon     42%              │
│ Evening       20%              │
│                                │
│ Containers / best day / run    │
├────────────────────────────────┤
│ Today   History   Stats   ⚙    │
└────────────────────────────────┘
```

The chart is not the only representation. Every visual series has a semantic summary and data values available to TalkBack.

### 5.6 Settings

```text
┌────────────────────────────────┐
│ Settings                       │
│                                │
│ Profile                        │
│  Body mass              72 kg  │
│  Activity level         Normal │
│  Preferred unit         ml     │
│                                │
│ Goal                           │
│  Daily goal             2 000  │
│  Goal mode              Auto   │
│                                │
│ Reminders                      │
│  Reminders             On   >  │
│                                │
│ Health Connect                 │
│  Hydration access       On   > │
│                                │
│ Containers / Export / About    │
├────────────────────────────────┤
│ Today   History   Stats   ⚙    │
└────────────────────────────────┘
```

Settings uses Android list rows and system settings intents. Do not reproduce iOS grouped-form styling.

### 5.7 Onboarding

```text
┌────────────────────────────────┐
│                         Skip   │
│                                │
│       A calm water rhythm      │
│       short explanation        │
│                                │
│       ● ○ ○ ○ ○ ○ ○            │  Progress indicator
│                                │
│       [ Continue ]             │
│                                │
│       Android system back      │
└────────────────────────────────┘
```

Permission steps launch native Health Connect/notification permission UI and refresh state on return. A denied permission is a recoverable state, not a failed onboarding session.

### 5.8 Tablet History split

```text
┌──────────────────┬───────────────────────────────────────────┐
│ Navigation rail  │ History                         September │
│                  ├───────────────────────┬───────────────────┤
│ Today            │ month grid            │ Day Detail        │
│ History          │                       │ Tue, 8 Sep        │
│ Stats            │ one ring/day          │ 1 250 / 2 000 ml  │
│ Settings         │                       │ intake rows       │
│                  │                       │ edit/delete       │
└──────────────────┴───────────────────────┴───────────────────┘
```

Selecting a day updates the detail pane without replacing the month context. On narrower widths it becomes the nested Day Detail route.

## 6. Wear OS wireframes

Wear is a separate Android surface with Android Wear conventions. It is not a miniature phone app or a copy of Apple Watch pages.

### 6.1 Wear Today

```text
┌───────────────┐
│ 09:42          │  TimeText
│               │
│   water       │  Full-canvas field
│  ~~~~~~~~~    │
│  750 ml left  │
│               │
│ [250] [500]   │  Predefined amounts
│       [750]   │
│   rotate for  │  Rotary custom amount hint
│   custom ml   │
└───────────────┘
```

Use a Wear `Chip`/`CompactChip` or equivalent for actions, rotary input for custom amount, and a short confirmation. Do not add an always-moving water animation.

### 6.2 Wear History

```text
┌───────────────┐
│ History       │
│ Today  1 250  │
│ Tue    1 800  │
│ Mon    2 050  │
│ Sun      900  │
│ Sat    2 000  │
│ Fri    1 450  │
│ Thu    2 100  │
└───────────────┘
```

Show seven elapsed local days. Selecting a day opens a Wear-native Day Detail where individual entries can be deleted/restored. There is no month calendar.

### 6.3 Wear Stats

```text
┌───────────────┐
│ Stats          │
│ ISO week 37    │
│ Avg 1 820 ml   │
│ 5 / 7 goals    │
│               │
│   ▂ ▆ ▅ ▇ ▃   │  One compact chart
│               │
│ Best Tue       │
└───────────────┘
```

There is no Wear period picker, month calendar, or multi-chart dashboard.

### 6.4 Wear complications and Tiles

Show only the focused surface:

```text
ring/level + remaining amount + tap-to-open or default log
```

Do not render a chart, month grid, pour stream, or sensor tilt in a complication/Tile.

## 7. Widgets and Android system surfaces

### 7.1 Glance widgets

Provide small, medium, and large responsive layouts.

Small:

```text
┌────────────┐
│ 1 250 ml   │
│ 750 left   │
│   +250     │
└────────────┘
```

Medium:

```text
┌──────────────────────┐
│ Ripple     63%       │
│ water level          │
│ 1 250 / 2 000 ml     │
│ [ +250 ] [ Today ]   │
└──────────────────────┘
```

Large:

```text
┌──────────────────────────────┐
│ Today                  63%   │
│ contained static water field │
│ 1 250 ml of 2 000 ml         │
│ remaining 750 ml             │
│ [ +250 ] [ +500 ] [ Open ]   │
└──────────────────────────────┘
```

Widgets are static and glanceable. They have no tilt, pour stream, surface response, Health Connect access, or direct Room mutation. Every action is a pending intent/Glance callback into the application write boundary.

### 7.2 Quick Settings Tile

The default Tile is a single quick-log action with a clear label and current enabled/disabled state. It does not display the full Today screen. Custom amount selection opens a small Activity/dialog.

### 7.3 Notification

The reminder notification has a concise title, current remaining amount, and one default logging action. It uses the standard Android notification template and remains useful when collapsed. No custom iOS-like notification layout is required.

## 8. Interaction flows

### 8.1 Quick log and undo

```text
User taps quick amount
        |
        v
ViewModel emits LogIntake(APP)
        |
        v
Room commits one UUID-addressed row
        |
        +--> Today snapshot refreshes
        +--> one pour series begins/coalesces
        +--> projection/outbox work is scheduled
        +--> snackbar offers Undo
        |
        v
Pour settles; final number/confirmation updates
```

If Undo is tapped, call `UndoLastIntake`. Do not remove a row from a ViewModel list or infer the last row from visual state.

### 8.2 Onboarding and permissions

```text
Welcome
  -> Profile
  -> Goal mode
  -> Health Connect availability
  -> Hydration write permission
  -> Optional weight/workout read permissions
  -> Notification permission
  -> Reminder setup
  -> Complete
```

Each permission step has three states: not requested, granted, and denied/recoverable. Returning from system UI always re-reads permission state. Continue remains possible when Health Connect or notifications are unavailable.

### 8.3 History edit/delete/restore

```text
History month -> select past/today -> Day Detail
                                      |
                                      +--> edit -> EditIntake -> refresh
                                      +--> delete -> soft delete -> undo/restore
                                      +--> add -> only if local day is today
```

Future dates have no route/action. A deleted row remains represented when the screen needs to explain undo/restore or export state.

### 8.4 Wear offline/reconnect

```text
Wear logs locally
      |
      +--> Room row committed
      +--> mutation enters outbox
      |
phone unavailable? keep row/outbox and show stale status
      |
phone reconnects
      |
phone applies UUID/mutation idempotently
      |
phone acknowledges after commit
      |
watch removes outbox entry and receives refreshed snapshot
```

### 8.5 Reminder scheduling

```text
Settings changes reminder rule
        |
        v
RescheduleReminders
        |
        +--> cancel/replace next request
        +--> check notification permission
        +--> clamp to wake/sleep window
        +--> schedule next local reminder
```

Permission denial never prevents logging. Reboot/time-zone changes trigger reconciliation, not duplicate reminder creation.

## 9. State matrix

Every screen must implement the states below. A state is not complete until its TalkBack text and action behavior are defined.

| State | Today | History | Stats | Settings | Wear/system surfaces |
| --- | --- | --- | --- | --- | --- |
| First run | Onboarding gate | Not reachable until onboarding policy allows | Not reachable until onboarding policy allows | Onboarding entry | Default static empty state |
| Loading | Hero skeleton/quiet loading surface; no fake water motion | Month skeleton | Summary/chart skeleton | Row-level loading | Last known snapshot or empty |
| Empty | Zero fill, quick add visible | Empty month message with current month | Empty period message, no fake chart | Defaults/seed state | Remaining/goal unavailable message |
| Ready | Hero, quick add, recent rows | Rings and selected-day summary | Summary and accessible charts | Current values and actions | Focused current snapshot |
| Goal reached | Lagoon success semantics, no celebration noise | Day ring at cap | Hit-day data | No special settings mutation | Ring/remaining reflects true state |
| Over goal | Numeric total remains true; visual fill follows domain cap | Ring remains capped at 1.0 | Over-goal data remains visible | No hidden normalization | Numeric value remains true |
| Error after save | Keep intake; show projection/system status | Keep local summary; retry action | Keep local data; explain unavailable projection | Retry/open settings | Show stale/error status, not a crash |
| Offline | Full local logging | Local history available | Local stats available | Local settings available | Watch outbox/stale indicator |
| Permission denied | Logging remains enabled | No permission-specific blockage | Health-derived goal falls back | Clear reconnect action | No Health Connect access on watch |
| Stale Wear sync | Phone unaffected; show sync status | Local phone truth | Local phone truth | Link status/action | Watch shows last sync and offline action |
| Reduced motion | No stream/surface/tilt; cross-fade | No animated ring flourish | Chart transitions disabled/shortened | No decorative animation | No idle animation |
| Large text | Hero scales; controls wrap | Calendar labels remain readable | Chart labels expose data separately | Rows wrap, no clipping | Wear uses scroll and concise labels |

## 10. Accessibility and input requirements

### TalkBack semantics

- Today hero announces one aggregate: consumed, goal, remaining, and percentage.
- Quick-add controls announce their exact amount and action.
- Intake rows announce local time, amount, source, deleted state, and available actions.
- Calendar cells announce date, total, percentage, goal-hit state, and future/disabled state.
- Charts expose a text summary and navigable values; visual marks are not the only data channel.
- Permission rows announce current state and the action that opens system settings.

### Input and navigation

- All touch targets are at least 48dp.
- Every action has pressed, focused, disabled, and loading semantics.
- Hardware keyboard navigation reaches all primary controls on tablets/ChromeOS-compatible environments.
- System back and predictive back work for nested routes.
- Wear rotary input changes custom amount in stable increments and announces the current amount.
- No gesture is the only route to a critical action.

## 11. Screenshot and visual acceptance matrix

Screenshots are generated from the real Android implementation. They are validation artifacts, not the source of layout decisions.

Store implementation captures under `release/screenshots/android/` using stable names:

| Capture | Form factor | State |
| --- | --- | --- |
| `phone-compact-today-light` | compact phone | ready, light |
| `phone-compact-today-dark` | compact phone | ready, dark |
| `phone-compact-today-empty` | compact phone | zero intake |
| `phone-compact-today-pour` | compact phone | active coalesced pour |
| `phone-compact-history` | compact phone | populated month |
| `phone-compact-day-detail` | compact phone | entries and actions |
| `phone-compact-stats-week` | compact phone | chart and summaries |
| `phone-compact-settings` | compact phone | settings sections |
| `phone-compact-onboarding` | compact phone | permission step |
| `tablet-history-split` | expanded tablet | month plus Day Detail |
| `tablet-stats` | expanded tablet | responsive chart layout |
| `wear-today` | Wear OS | quick logging |
| `wear-history` | Wear OS | seven-day list |
| `wear-stats` | Wear OS | ISO-week summary |
| `widget-small` | launcher | static focused widget |
| `widget-medium` | launcher | static level and actions |
| `widget-large` | launcher | full glanceable surface |
| `notification-reminder` | notification shade | default action |
| `quick-settings-tile` | Quick Settings | default logging action |

For each screen, compare hierarchy, state, type scale, contrast, touch targets, and system context. Do not compare against the iOS screenshots as a pixel target. A screenshot failure must be classified as one of: content, layout, token, state, accessibility, or platform-behavior mismatch.

## 12. Implementation handoff

Map the UI contract to these Android modules:

| UI responsibility | Module |
| --- | --- |
| Theme, dimensions, typography, shapes, semantics | `core:designsystem` |
| Today screen and hero | `feature:today` + `core:designsystem` |
| Month grid and Day Detail | `feature:history` |
| Charts and period selection | `feature:stats` + `core:designsystem` |
| Profile, goal, containers, reminders, health, export | `feature:settings` |
| Permission/setup flow | `feature:onboarding` |
| Glance layouts | `system:widgets` |
| Quick Settings Tile | `system:quicksettings` |
| Shortcuts/App Actions/deep links | `system:appactions` |
| Wear screens and complications/Tiles | `wear` |

Every feature screen must have:

- a `ScreenState` with loading/content/error/permission-sensitive states;
- a `ViewModel` that calls domain use cases only;
- previews/fixtures for empty, ready, error, dark, large-text, and reduced-motion states;
- Compose semantics tests for the primary actions;
- no direct Room, Health Connect, AlarmManager, WorkManager, or Data Layer import.

## 13. Definition of UI complete

- [ ] Compact, medium, and expanded navigation behave as specified.
- [ ] Today prioritizes logging and the water state with Android-native controls.
- [ ] History and Stats remain separate and have all specified states.
- [ ] Day Detail supports edit/delete/restore and only allows add for today.
- [ ] Settings and onboarding use native Android permission/system flows.
- [ ] Wear uses Wear-native navigation, chips/lists, rotary input, and offline status.
- [ ] Widgets, notification, and Quick Settings layouts are static, focused, and actionable.
- [ ] All layouts survive dark mode, large text, TalkBack, reduced motion, and empty/error/offline states.
- [ ] Screenshot matrix is captured on real/emulated Android targets and reviewed against this document.
- [ ] No UI decision depends on an iOS screenshot or an unrecorded agent preference.

## 14. Maintenance and timeline

This document is maintained with [Ripple Android Architecture](ANDROID_ARCHITECTURE.md). When a screen, interaction, breakpoint, token, state, system surface, or accessibility contract changes, update this document in the same change as the implementation and append a timeline entry. Use semantic document versions: MAJOR for incompatible UI/workflow contracts, MINOR for new screens/states/surfaces, and PATCH for corrections or clarifications.

Newest entries are appended at the bottom. Historical entries are immutable.

| Version | Date | Change | Impact |
| --- | --- | --- | --- |
| 1.0.0 | 2026-09-07 | Initial Android UI specification with native Material/Wear wireframes, responsive layouts, state matrix, interaction flows, and screenshot acceptance matrix. | Removes screen-level ambiguity for Android implementation while preserving functional parity without copying iOS UI. |
