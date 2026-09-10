# Ripple Android UI Specification

**Status:** Android implementation companion specification
**Document version:** 2.9.0
**Last verified:** 2026-09-10
**Architecture:** [Ripple Android Architecture](ANDROID_ARCHITECTURE.md)
**Product contract:** [Ripple PRD](../Ripple_PRD.md)
**Visual reference pack:** [Android UI reference pack](UI/README.md)

This is the normative Android screen, flow, state, accessibility, and visual
acceptance contract. The current iOS implementation establishes the product
hierarchy and capability baseline. Android preserves those screens and flows,
then expresses them with Material 3, Android window-size behavior, Android
back/navigation conventions, native permission surfaces, and Compose for Wear
OS.

The existing iOS screenshots are evidence, not pixel targets. The annotated PNG
image references in `UI/` are Android layout contracts. Real Android and
Wear captures are the final acceptance artifacts. Nothing in this document
authorizes copying Liquid Glass, an iOS tab bar, SwiftUI navigation chrome, or
Apple Watch presentation into Android.

## 1. Source of truth and parity rule

The contract is maintained in layers:

| Concern | Authority | Android obligation |
|---|---|---|
| Product scope, platforms, domain language, Today, History, Stats, and motion | `Ripple_PRD.md` §22 and the Android project's `AGENTS.md` | Preserve capability and source-of-truth rules |
| Current iOS hierarchy and settings/onboarding composition | iOS source and captures listed below | Do not invent a dashboard or omit a screen |
| Android layout and system substitution | This document and `UI/*.png` | Use Android-native components and responsive layouts |

The current iOS source inspected for this revision includes:

- `Apps/RippleiOS/RootView.swift` — four roots: Today, History, Stats, Settings;
- `Packages/RippleFeatures/Sources/RippleFeatures/Today/TodayView.swift` —
  hero, remaining amount, floating confirmation toast, the first three
  saved-container quick adds, and custom amount, with no Recent section;
- `HistoryCalendarView.swift` — horizontal month paging, one ring per day, and
  Day Detail navigation;
- `DayDetailView.swift` — static contained glass/readout summary, goal and
  remaining status, and the entry list/actions for the selected day;
- `SettingsView.swift` — profile, daily goal, containers, reminders, Health,
  sync, export, and about sections;
- `OnboardingPages.swift` — six pages: Welcome, Units, Health, Goal,
  Containers, and Reminders.

### 1.1 Capability parity matrix

| Current iOS capability | Android destination | Android reference |
|---|---|---|
| Today glass hero and daily readout | Today root | [phone Today](UI/phone-today.png) |
| Saved-container quick add and custom amount | Today root; native amount entry | [phone Today](UI/phone-today.png) |
| Calendar-first History | History root | [phone History](UI/phone-history.png) |
| Tap a day to inspect entries | Nested Day Detail with static glass/readout; split on expanded windows | [phone Day Detail](UI/phone-day-detail.png), [tablet History](UI/tablet-history-split.png) |
| Separate period-based Stats | Stats root | [phone Stats](UI/phone-stats.png), [tablet Stats](UI/tablet-stats.png) |
| Full settings surface | Settings root and native sub-destinations | [phone Settings](UI/phone-settings.png) |
| Six-page first-run flow | Onboarding route with native permission handoffs | [phone onboarding](UI/phone-onboarding.png) |
| Watch Today/History/Stats | Wear Today/History/Stats pages | [Wear pack](UI/README.md) |

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

Transient success feedback uses a centered or content-anchored Snackbar/Toast
overlay and never changes measured content. Today and today's Day Detail add
actions use the same localized confirmation. Delete / Undo uses a Snackbar action.
Sync, permission, loading, and unresolved errors remain visible in their
inline state surfaces until they are resolved or retried.

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
| Quick add | Filled/tonal buttons or labeled chips in a full-width, fixed, non-scrolling row of three | Same actions in a constrained content row |
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
  Confirmation toast: only after a completed log; floats over the lower actions,
  reserves no layout space, then fades
  QuickAddCluster: saved containers
  CustomAmountAction: opens amount entry
  NavigationBar / Rail: Today | History | Stats | Settings
```

There is no Recent section, no additional motivation card, and no separate
last-entry block on Today. History and Day Detail are the places for inspecting
entries.

### 4.1 Compact layout

See [phone Today image](UI/phone-today.png). The hero is the visual
center and the first three saved-container actions, in Settings order, remain
reachable in a full-width, fixed, non-scrolling horizontal row whose three
buttons share the available width. Custom amount is a clearly
labeled secondary primary action, not an unlabeled symbol-only control; its
sheet places the amount field and a compact slider before a wider, horizontally
scrollable selection of every saved container. The selection has no visible
section heading and uses the selected container's amount as the starting value.

The glass hero must:

- use the contained 2D silhouette and water-level rules from `Ripple_PRD.md` §22.1;
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

The confirmation is a transient centered toast overlay above the lower action
region. It must not reserve a row, push the quick-add controls, or change the
hero's measured size. Android may express it with a native Material Snackbar or
Toast-style surface; if Undo is offered, it remains the Snackbar action rather
than a second inline confirmation row. The copy remains localized in DE and EN.

Android may draw the silhouette with Compose paths and animate with Compose
animation primitives, but it must not add a permanent sine loop, particles,
photoreal water, a single-drop metaphor, or simulated Liquid Glass chrome.

### 4.2 Today states

| State | Required presentation |
|---|---|
| First run | Onboarding route gates the app; do not show a fake Today behind it |
| Zero intake | Empty contained field; no water fill or bottom shimmer; quick adds visible |
| Ready | True consumed amount, percent, goal, remaining, first three saved containers, custom amount with all-container selection |
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
        -> final amount/remaining/toast update
        -> snackbar offers UndoLastIntake
```

Today exposes the first three saved containers in Settings order. The custom
amount sheet exposes every saved container; selecting one fills its saved
amount, while changing the amount keeps the entry a custom amount. Selecting a
container or preset alone never writes until the user confirms Add.

Three fast taps create three store rows but one continuous visual pour. Undo
targets the last own, non-deleted intake; it does not reconstruct a visual list.

### 4.4 Today motion and animation contract

The shared PRD §22.1 defines the product behavior. This section is the
normative Android rendering and timing mapping. Android uses `dp` for geometry
and milliseconds for timing; it must preserve the same observable sequence,
containment, and reduced-motion behavior. The animation is a finite interaction
state, never a continuously running water simulation.

#### 4.4.1 Motion state and one shared clock

The Today hero has these visual states:

| State | Required behavior |
|---|---|
| `Idle` | Flat water surface; no autonomous wave, sine loop, or timeline animation |
| `Pouring` | One stream, one retargetable level rise, and one active surface-contact profile |
| `SurfaceSettling` | The single post-pour crest/reflection sequence decays to exactly zero |
| `ReducedMotion` | No stream, surface reaction, or sensor tilt; level cross-fades in 200 ms |

On every frame of an active pour, sample one `pourProgress` clock and derive
the stream geometry, stream opacity, contact profile, and level from that same
sample. Do not create separate `animate*AsState`/`Animatable` timelines for the
stream and fill: they must not drift apart.

When `LogIntake` succeeds:

1. Start or retarget one `PourSession` from the currently rendered level to
   the new visual target.
2. Keep the committed store row and the visual session separate; a failed
   Health Connect/projection write must not cancel the local log or animation.
3. Keep the amount, remaining label, percent, and confirmation stable during
   the active pour. They settle to the store snapshot after the stream has
   completely disappeared.
4. After the stream ends, run the one surface-contact sequence and then return
   to `Idle`.

If another tap arrives while a session is active, commit another store row but
retarget the same session: use the currently rendered level as the new start,
sum the active series amount, restart `pourProgress` at zero for that series,
and keep the stream visibly continuous. Never stack a second stream, level
animator, or independent ripple.

#### 4.4.2 Pour stream and level fill

For the active series amount `addedMl`, use the following Android mapping:

```text
amountT             = clamp((addedMl - 50) / 700, 0, 1)
streamWidth         = 7.dp + 5.dp * amountT       // 7…12 dp
pourDuration        = 400 ms + 300 ms * amountT   // 400…700 ms
levelRiseDuration   = pourDuration + 140 ms
contactDepth        = 5.dp + 4.dp * amountT       // 5…9 dp
```

- Start the stream at the glass center, `glass.top - 32.dp`, visibly above
  the rim. It must never begin inside the glass or appear detached from the
  surface.
- Establish the stream to the current water surface during the first 140 ms
  with an `easeOut` curve. The stream then remains continuous for the active
  pour duration and contracts/fades over the final 140 ms.
- The linear level rise reaches the actual target exactly when stream opacity
  reaches zero. There is no level spring, bounce, or overshoot during a pour.
- Draw order is: stream behind the water/glass stroke and below the readout;
  the submerged part is clipped into the water rather than drawn as a second
  line above it.
- Use the PRD's contained glass path and clip all water geometry to the inner
  glass. A true amount over goal remains numerically true while the visual fill
  follows the capped display rule. At `level == 0`, draw no fill and no bottom
  shimmer.
- At every upright level, derive the water boundary from the tapered inner glass
  path. Preserve only the defined stroke/clip inset: do not add fixed
  horizontal padding. As the level rises toward the wider rim, the fill must
  widen with the glass walls and remain clipped to the inner path.

The Android implementation may use Compose `Canvas`, `Path`, `DrawScope`, and
`Animatable`/frame sampling, but it must not use a circular or linear
`ProgressIndicator` as the hero, Lottie, particles, a fluid solver, or a
photoreal water effect.

#### 4.4.3 Surface contact and settle sequence

The surface response is part of the water boundary, not a separate ripple
icon, ellipse, or overlay:

| Relative timing | Visual response |
|---|---|
| During the stream | A central 5…9 dp depression with two shoulders; it stays stable and does not flap |
| Stream end + 0…380 ms | Two symmetric crests travel from the contact point toward the walls |
| Wall contact | Hold the crest for 60 ms, reverse direction once |
| Reflection + 0…220 ms | One weaker return at no more than 36% of the original amplitude |
| Final settle + 0…240 ms | Remaining amplitude decays to exactly zero; surface is flat |

The complete surface response is quiet 900 ms after the stream ends. Clip all
motion to the glass. Keep the response subtle: for a fill below 15%, cap the
crest amplitude at 4.dp. New taps retarget/restart the existing profile; they
never add independent wave profiles.

#### 4.4.4 Device motion and contained slosh

On phones and tablets, collect gravity/rotation data through a platform motion
adapter, not directly from a composable. Collect only while the Today surface
is resumed and visible, and stop collection when it leaves Today, enters the
background, or Reduce Motion is enabled.

- Transform gravity into the current display orientation, including rotation
  lock. The target angle is `atan2(-gravityRight, gravityDown)` with no 16° cap;
  choose the shortest path across ±π.
- Apply a damped response around the target (PRD reference: 12 rad/s,
  damping 0.48). Motion changes may excite a temporary surface deformation
  (PRD reference: 10 rad/s, damping 0.18, maximum amplitude 6% of glass
  width). Sensor noise below 0.002 rad must not start a visible response.
- Build the water boundary in tangent/normal coordinates and clip it to the
  inner glass path. At 45°, 90°, and inverted orientations, water remains
  contained and the logged amount never changes.
- Returning the device upright changes the equilibrium to zero; it does not
  abruptly cancel velocity or slosh. A normal 45° return should show at least
  two visibly decaying oscillations before settling over roughly 0.5…1.5 s.
- Face-up (`abs(gravity.z) > 0.92`) immediately resets angle, velocity, and
  surface deformation to zero. Simulator, desktop, Wear, widgets, and any
  surface without supported motion sensors use `tilt = 0`.
- There is no autonomous idle wave. When sensors stop producing meaningful
  motion, the deformation decays to exactly zero and remains there.

#### 4.4.5 Reduced motion, system surfaces, and accessibility

- Reduced Motion removes the stream, contact depression, crests, reflection,
  and sensor tilt. Cross-fade the level to its new value over 200 ms, update
  the text state without decorative motion, and keep logging fully functional.
- Wear Today is a flat water-level field with no tilt, stream, or surface
  reaction. Wear History/Stats and all widgets, notifications, Quick Settings,
  and shortcuts use static focused surfaces.
- A button may use the Android quick interaction token (approximately 280 ms)
  and native haptic feedback, but it must not delay `LogIntake` or alter the
  hero timing contract.
- TalkBack must receive semantic amount/goal/remaining updates, not a stream
  of per-frame announcements. Announce the final committed state once the
  pour settles; animation is never the only indication of a log.
- Large text, dark mode, and font-scale changes must not change timing or
  create clipped readouts. The surface and stream remain behind the readout.

#### 4.4.6 Animation verification

Use a fake frame clock and fake motion source for deterministic Compose tests
and previews. Verify at minimum:

- zero level has no fill or shimmer;
- 50 ml, 250 ml, and large adds map to the specified width/duration ranges;
- the stream starts 32.dp above the rim and reaches the surface in 140 ms;
- the fill reaches its target exactly when the stream disappears, without
  spring or overshoot;
- surface contact, crest, 60 ms reversal, 36%-maximum reflection, and 900 ms
  settle timing are observable and then exactly flat;
- coalesced taps produce multiple store rows but one continuous pour and one
  final surface response;
- sensor lifecycle, face-up, rotation, and inverted-device behavior remain
  contained;
- Reduced Motion, Wear, widgets, and system surfaces never start a stream or
  sensor animation.

## 5. History and Day Detail

History is calendar-first. It is not a list of recent entries and is not a
combined Stats screen. See [phone History](UI/phone-history.png),
[phone Day Detail](UI/phone-day-detail.png), and [tablet History
split](UI/tablet-history-split.png).

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
  TopAppBar: back + localized weekday/date title on compact windows
  StaticDayGlass: contained 2D glass + height-based water fill + consumed/unit/percent readout
  GoalStatus: localized goal + remaining/goal reached text below the glass
  Entries: time, amount, container, source, deleted state
  Row actions: edit, soft delete, restore/undo
  Today-only add action; today's add confirmation uses the transient toast
```

On a compact phone, Day Detail is a real nested destination with Android back
behavior, and the top app bar title is the selected day's localized weekday and
date. Do not repeat that date as a second heading in the compact detail
content. On an expanded window it is the detail pane beside the calendar,
where the date remains in the detail content rather than adding a redundant
pane title. The selected day's summary is a read-only static contained glass:
consumed amount,
unit, and percentage live in the glass readout, while goal and remaining (or
goal-reached) text stay below it. It has no pour stream, sensor tilt, surface
reaction, `Timeline` animation, or continuous animation. Render the product
content with Compose `Canvas`/`Path`; this does not authorize copying iOS
Liquid Glass chrome or replacing the glass with a Material card.

The water fill uses the same inner glass geometry as Today. Keep only the
stroke/clip inset at the sides. Because the glass walls open toward the rim,
the water boundary must widen as the level rises; a fixed side padding would
create an artificial larger gap at high levels and is not allowed. Clip the
final fill to the inner glass path. A zero level has no fill. A past day never
shows an enabled add action. Delete is soft delete and can be undone or
restored; edit changes the existing intake identity and must not make a hidden
duplicate. Empty past days show a clear empty state; an empty today may
include the add CTA.

After a delete, show a short Snackbar with an Undo action over the active
content pane. It must not reserve a persistent row or move the Day Detail
summary and entry list. The action restores the last own, non-deleted intake
through the shared undo use case.

### 5.3 History and detail accessibility

Each day cell announces its full date, amount, percentage, goal status, and
future/disabled status. Each intake row announces local time, amount, container,
source, and available edit/delete action. The detail summary, including the
static glass, is a single aggregate announcement before the row collection;
announce date, consumed amount and unit, goal, percentage, and
remaining/goal-reached status once. Do not expose every water path segment or
animation frame.

## 6. Stats

Stats is its own root and remains separate from History. See [phone Stats
image](UI/phone-stats.png) and [tablet Stats image](UI/tablet-stats.png).

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
  `Ripple_PRD.md` §22.2.5.
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
image](UI/phone-settings.png).

Use a scrollable Material settings list with these sections and capabilities:

1. **Profile** — name/profile values and preferred unit;
2. **Daily goal** — automatic goal from available Health Connect data or manual
   profile input, with current target visible;
3. **Containers** — create, edit, reorder/default, and delete saved containers
   used by Today quick add. Today shows the first three saved containers in
   Settings order, while the custom amount sheet exposes every saved container
   as a selectable amount preset. The editor exposes name, an icon-only
   horizontal icon selection, amount, and default-container state through native
   Material controls, including a compact amount slider;
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

Onboarding is six pages. See [phone onboarding image](UI/phone-onboarding.png).

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
Today, History, Stats. See the [Wear layout images](UI/README.md).

### 9.1 Wear Today

See [wear Today](UI/wear-today.png). Use the full canvas as a flat
water-level field with the consumed/remaining readout. Provide predefined
amount actions and a Crown-equivalent rotary-first custom amount flow. Use Wear
chips or compact buttons; keep labels short and touch targets safe.

No idle wave loop, pour stream, surface reaction, motion tilt, or phone-sized
top-level navigation is used on Wear. The shared write boundary still applies.
After a completed log, show the localized success confirmation as a transient
Snackbar/Toast overlay above the action region without reserving layout space.
Persistent sync, permission, loading, and unresolved errors remain inline.

### 9.2 Wear History and Day Detail

See [wear History](UI/wear-history.png) and [wear Day Detail](UI/wear-day-detail.png).

- Show today and the six previous elapsed local days, newest first.
- Empty days remain visible so the seven-day context is stable.
- Do not show a month calendar or month pager.
- Tapping a day opens Wear Day Detail with the daily total and individual
  entries.
- Individual entries can be deleted with a standard Wear action and restored
  with a short Snackbar/Toast action overlay; it must not reserve layout space.
  Edit and add are phone/tablet flows unless
  the Wear interaction explicitly remains within the supported Today action.

### 9.3 Wear Stats

See [wear Stats](UI/wear-stats.png). Show only the current ISO-week
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
| Ready | Hero, readout, quick adds, custom amount | Rings, selected day, static glass/readout, goal status, entries | Summary and four accessible charts | Current values and native controls | Focused current surface |
| Goal reached | Success semantics without celebration noise | Day ring caps at 1.0 | Hit data remains visible | No hidden goal mutation | Ring/readout reflects state |
| Over goal | True numeric total; capped visual rule | Ring remains capped | Over-goal values remain true | No normalization | Numeric state remains true |
| Save/projection error | Keep local log; show status/retry | Keep local summary; retry projection | Keep local data; explain unavailable projection | Recoverable retry | Stale/error indicator, not a crash |
| Offline | Local logging remains available | Local history remains available | Local stats remain available | Local changes remain visible | Outbox/stale state |
| Permission denied | Logging remains enabled | No permission block | Goal fallback is explicit | Reopen/retry native settings | No Health Connect dependency on Wear |
| Reduced motion | No stream/reaction/tilt; cross-fade only | Static Day Detail glass; no ring-spin/page flourish | Disable decorative chart transitions | No decorative motion | No idle motion |
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

- [iPhone Today](../screens/ios/iphone-today.png)
- [iPhone History](../screens/ios/iphone-history.png)
- [iPhone Stats](../screens/ios/iphone-stats.png)
- [iPad Settings](../screens/ios/ipad-settings.png)
- [Watch Today](../screens/ios/watch-today.png)
- [Watch History](../screens/ios/watch-history.png)
- [Watch Stats](../screens/ios/watch-stats.png)

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
- [ ] Today has the contained hero, the first three saved-container quick adds,
      and custom amount with access to every saved container, with no Recent
      list or replacement dashboard.
- [ ] Today motion implements the single-clock pour/fill contract, contained
      sensor slosh, surface settle sequence, coalescing, and zero-state rules.
- [ ] Today and Day Detail water fills follow the tapered inner walls, preserve
      only the stroke/clip inset, widen toward the rim, and remain clipped to
      the inner glass path.
- [ ] History has horizontal month paging, one ring per day, disabled future
      days, and a real Day Detail route.
- [ ] Day Detail exposes the static glass/readout, goal status, entry
      inspection, and edit/delete/restore semantics; add is possible only for
      today. Historical detail has no pour stream, tilt, or surface reaction.
- [ ] Stats is separate and has Week/Month/Year, summaries, four chart
      families, highlights, empty states, and TalkBack data.
- [ ] Settings has all eight product sections and native Android controls.
- [ ] Onboarding has all six pages and recoverable native permission handoffs.
- [ ] Wear has Today, seven-day History plus Day Detail, and current ISO-week
      Stats without a month calendar or period picker.
- [ ] Widgets, notifications, and Quick Settings remain focused and static.
- [ ] Light/dark mode, large text, TalkBack, reduced motion, offline, empty,
      and error states are reviewed on representative targets.
- [ ] Animation tests use a fake clock/sensor source and verify no stream or
      tilt appears on Wear, widgets, system surfaces, or Reduced Motion.
- [ ] Runtime Android captures are stored and reviewed against this contract.

## 17. Maintenance and timeline

This document is maintained with [Ripple Android Architecture](ANDROID_ARCHITECTURE.md)
and the shared [Ripple PRD](../Ripple_PRD.md). When a screen, interaction,
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
| 2.0.1 | 2026-09-08 | Consolidated the Android UI specification and SVG reference pack under `Docs/Android/`; updated local evidence and companion links without changing the screen contract. | Android UI documentation now has one discoverable product-docs root under `Docs/`. |
| 2.0.2 | 2026-09-08 | Updated the product-contract links after moving the maintained PRD, Hero Motion, and History/Stats documents into `Docs/Product/`; no Android screen contract changed. | Android UI implementation now resolves its shared behavior contracts from the maintained `Docs/` tree, while task planning records remain separate and ignored. |
| 2.0.3 | 2026-09-08 | Updated the Android UI contract to use the consolidated `Docs/Product/Ripple_PRD.md` as its only shared product source; no Android screen behavior changed. | Android layout and state guidance now has one product contract plus the Android-native UI mapping and visual reference pack. |
| 2.1.0 | 2026-09-08 | Synchronized the Android UI reference pack with the single versioned PRD and removed the retired ADR/document-tree assumptions. | The Android UI specification, README, and SVG pack now point to one current product contract and remain maintainable as one Android documentation set. |
| 2.1.1 | 2026-09-08 | Repointed the product contract to `Docs/shared/` and removed the iOS architecture dependency. | The Android UI contract now depends only on the shared product source and Android-owned implementation documents. |
| 2.1.2 | 2026-09-08 | Moved the complete Android handoff under `Docs/shared/`, replaced SVG wireframes with raster PNG images, and made iOS evidence captures self-contained. | Android agents receive one portable image-based reference pack without relying on the iOS release-assets tree or SVG rendering support. |
| 2.2.0 | 2026-09-09 | Added the Android-native Today motion contract for pour/fill timing, surface response, sensor-driven contained slosh, coalesced taps, reduced motion, static system surfaces, accessibility, and deterministic animation verification. | Android implementation now has explicit animation behavior instead of relying only on the shared PRD or visual images. |
| 2.3.0 | 2026-09-09 | Added the static contained glass/readout to Android Day Detail, kept goal and remaining status below it, and specified tapered inner-wall water geometry with only the stroke/clip inset. | Android Day Detail now matches the updated shared History presentation while remaining Android-native: historical detail has no pour stream, tilt, surface reaction, or continuous animation, and higher levels widen toward the rim without an artificial fixed side gap. |
| 2.3.1 | 2026-09-09 | Clarified that compact Day Detail uses the selected day's localized weekday/date as the nested top-app-bar title, while expanded detail keeps the date in the pane content. | Android navigation context now matches the iPhone Day Detail contract without changing the expanded split layout. |
| 2.3.2 | 2026-09-09 | Clarified that compact Day Detail must not repeat the top-app-bar date as a second in-content heading, while expanded detail keeps its pane date heading. | Android compact navigation now matches the iPhone presentation without duplicating the selected date; expanded split context remains explicit. |
| 2.4.0 | 2026-09-10 | Changed Today's completed-log confirmation from an inline row to a centered transient toast overlay that reserves no layout space; Android maps the same behavior to a native Snackbar/Toast surface. | Quick-add controls and the hero keep stable measured positions while feedback remains visible and localized; the static phone Today reference remains a ready-state layout capture. |
| 2.5.0 | 2026-09-10 | Standardized transient feedback across Android app surfaces: Today and Wear Today use localized Snackbar/Toast confirmations, Day Detail delete offers Undo as an action, and sync, permission, loading, and unresolved errors remain inline until resolved or retried. | Phone, tablet, and Wear content keeps stable measured layout while transient feedback is visible; the existing static reference images remain ready-state contracts. |
| 2.5.1 | 2026-09-10 | Clarified that the transient localized confirmation also appears when a custom amount is added from today's Day Detail, while delete keeps Undo as the Snackbar action and persistent errors remain inline. | Every supported in-app add entry point has the same layout-neutral success feedback without changing the static reference images. |
| 2.6.0 | 2026-09-10 | Clarified that every saved container is available from Today quick add and that the Settings editor exposes icon, amount, and default-container controls using native Android controls. | Custom containers remain usable after creation, the default amount has an explicit selection flow, and the existing seeded Settings image remains a baseline rather than a limit. |
| 2.7.0 | 2026-09-10 | Settings container rows are reorderable. Today shows the first three saved containers in that order, while the custom amount sheet exposes every saved container as a selectable preset. The editor uses a horizontal icon-only selection. | The compact Today action row stays limited to three common actions without hiding custom containers; order, icon, amount, and default state remain configurable and localized. |
| 2.8.0 | 2026-09-10 | Today renders its first three saved-container actions in a fixed, non-scrolling horizontal row. The custom amount sheet puts a compact slider before the wider, unlabeled all-container selector. | The compact action row has stable bounds, while custom logging keeps arbitrary slider values and access to every saved container without an extra section heading. |
| 2.9.0 | 2026-09-10 | The three fixed Today quick-add buttons now share the full available width of the compact horizontal row. | Quick-add actions use the complete compact Today action region without introducing horizontal scrolling. |
