# Ripple Design System

**Document type:** Shared visual, interaction, and reusable-element contract  
**Version:** 1.0.0 — 11 September 2026  
**Last verified:** 2026-09-11  
**Status:** Normative companion to [`Ripple_PRD.md`](Ripple_PRD.md)

Ripple has one design system. The iOS implementation owns its token values in
`Packages/RippleUI`; the Android project owns the equivalent native token
definitions in its design-system module. The semantic names, roles, states,
accessibility requirements, and motion meaning are shared. Platform documents
map them to native controls and materials.

Product behavior and screen meaning live in the [PRD](Ripple_PRD.md), the
[screen index](Ripple_SCREEN_CATALOG.md), and its one-file-per-surface
descriptions in [`screens/`](screens/). Data values and mutation rules live in
[`Ripple_DATA_MODEL.md`](Ripple_DATA_MODEL.md). This document defines how
those meanings look, feel, and behave at the reusable-element level.

## 1. Design principles

1. **Calm water hierarchy:** Deep text, Lagoon actions, Aqua water, and Foam
   surfaces establish hierarchy without extra accent colors.
2. **System-native behavior:** Use the platform's text fields, sliders,
   toggles, pickers, sheets, alerts, permission prompts, share flows, keyboard,
   pointer, and rotary controls when they provide the required behavior.
3. **Ripple-specific visuals are components:** The glass hero, contained water,
   quick-add cluster, cards, chips, toast, day rings, and motion primitives are
   built once and reused. They are not recreated in feature screens.
4. **Tokens before literals:** Feature code consumes semantic tokens. A raw
   color, font, spacing, radius, target size, or duration is allowed only in a
   token definition, a documented geometry algorithm, or a platform adapter.
5. **Meaning survives adaptation:** Compact, regular, expanded, wearable, and
   system surfaces may change arrangement and chrome, but not the data meaning,
   action result, state announcement, or accessibility outcome.
6. **Readable at rest:** Numbers, goal status, and actions are understandable
   without motion, color alone, or an image.

## 2. Token naming and ownership

Semantic token names are written in dot notation in shared documentation and
map to platform-specific symbols in code:

| Shared namespace | iOS reference implementation | Android reference implementation |
|---|---|---|
| `color.*` | `RippleColor` and asset catalog colors | `RippleColors`/Material color roles in `core:designsystem` |
| `type.*` | `RippleFont` and `Font.TextStyle` helpers | Material typography roles with system font fallback |
| `space.*`, `size.*`, `radius.*` | `RippleSpace`, `RippleLayout`, `RippleRadius` | dimension resources or Compose design tokens |
| `motion.*` | `RippleMotion` and motion adapters | Compose animation specs and platform motion settings |
| `component.*` | `Packages/RippleUI/Sources/RippleUI/Components` or `Hero` | `core:designsystem` components |

Token ownership is centralized. A feature may choose among existing semantic
tokens and component variants; it may not add a feature-local color, font,
spacing constant, card style, toast style, or motion curve. If a new product
need cannot be expressed by the current tokens, update this document and the
platform design-system implementation in the same change.

## 3. Color tokens

The following sRGB values are the current canonical values. Hex is included for
cross-platform handoff; platform color assets may use an equivalent native
representation. Colors are roles, not decoration.

### 3.1 Water palette

| Token | Light | Dark | Allowed role |
|---|---|---|---|
| `color.water.deep` | `#0B3D4A` | `#B7E0E8` | Primary text, readable iconography, dark outline on light surfaces; never a low-contrast decorative wash. |
| `color.water.lagoon` | `#1A7A8C` | `#4FB3C6` | Primary action, selected stroke, success, selected state, chart reference. |
| `color.water.aqua` | `#4FB3C6` | `#6FDBE8` | Water fill, progress fill, active pour, supportive emphasis. |
| `color.water.foam` | `#E8F4F6` | `#152026` | App canvas and calm water-adjacent surface. |
| `color.surface` | `#E8F4F6` | `#12181C` | Root canvas/sheet background where a native material is not more appropriate. |
| `color.surface.elevated` | `#F7FCFD` | `#152026` | Card/control surface; preserve separation with stroke/material, not heavy shadow. |
| `color.surface.selected` | `#D9EEF1` | `#1E3A42` | Selected chip/control background; must remain distinguishable without color alone. |
| `color.icon.muted` | System secondary label role | System secondary label role | Supporting icons and disabled states; never the only encoding of a required action. |

`color.success` aliases `color.water.lagoon`. `color.danger` uses the
platform's desaturated system red role with sufficient contrast; it is not a
new Ripple accent. The app does not add orange, purple, green, or gradient
accent families in v1.

### 3.2 Color behavior

- Deep text on Foam and elevated surfaces must remain readable at normal and
  accessibility text sizes. Dark mode uses the light Deep role shown above and
  cool anthracite surfaces; it does not invert the product into a generic black
  theme.
- Aqua is reserved for water/progress and active pour meaning. It is not used
  for long paragraphs or small text on light backgrounds.
- Lagoon is the action/selection/success role. Pair it with a label, stroke,
  shape, or state text so color is never the sole state indicator.
- Glass highlights use restrained white/material reflection. They never become
  a second accent palette.
- Alpha is a component-state decision, not a feature-local color. Disabled
  content follows the platform's disabled role; do not manually lower opacity
  on arbitrary text to hide a missing state.

## 4. Typography tokens

Use the platform system sans family: San Francisco on Apple platforms and the
Android system sans equivalent on Android. Do not bundle a custom font. Shared
roles map to platform text styles so Dynamic Type/large text remains active.

| Token | Semantic use | Weight/alignment | Numeric rule |
|---|---|---|---|
| `type.display` | Hero amount, major daily readout | Semibold, prominent, centered where the hero requires it | Always monospaced digits; scale or wrap before clipping. |
| `type.title` | Surface title, group title, selected period | Semibold; leading or platform title alignment | Use tabular/monospaced digits when values appear inline. |
| `type.body` | Labels, values, explanatory copy | Regular; leading | Localized, no hard-coded English. |
| `type.callout` | Primary action labels, important status, chart summaries | Regular/medium according to platform convention | Preserve unit and sign. |
| `type.caption` | Supporting amount, source, timestamp, note, legal copy | Regular; secondary role | Never use as the only location of a required value. |
| `type.numeric` | Amount, goal, percentage, chart annotation | Monospaced digits with the surrounding semantic role | Keep integer domain value; format only at presentation boundary. |

Rules:

- The type role is chosen by meaning, not by the current screen's visual size.
- Use sentence case and the localized strings from the product contract.
- Amounts always include `ml` or `fl oz`; percentages include `%`.
- Avoid manual kerning, all-caps labels, text baked into images, and fixed-size
  text that cannot respond to Dynamic Type.
- At XXXL/maximum large text, a card may grow, a row may wrap, or a chart may
  reduce decoration. It may not clip the amount, hide the primary action, or
  silently omit a container name.

## 5. Spacing, sizing, and shape tokens

All layout spacing is on a 4-point grid. The shared names are semantic; a
platform may map the interaction minimum to its own accessibility convention.

| Token | Value | Role |
|---|---:|---|
| `space.grid` | 4 | Base grid and small geometry increments. |
| `space.xs` | 4 | Icon/text micro-gap, divider inset. |
| `space.sm` | 8 | Label/value gap, compact internal padding. |
| `space.md` | 12 | Control gap, quick-add chip gap, row padding component. |
| `space.lg` | 16 | Standard card/section inset and surface gap. |
| `space.xl` | 24 | Section separation and sheet content inset. |
| `space.xxl` | 32 | Large composition separation, iPad column gap. |
| `space.xxxl` | 40 | Hero/title breathing room. |
| `space.hero` | 48–64 | Responsive hero separation; choose by available height, never by arbitrary screen. |

| Token | Value | Role |
|---|---:|---|
| `size.control.minimum` | 44 pt iOS reference; platform minimum on Android | Minimum interactive target in the shared contract. |
| `size.icon.standard` | 24 | Standard semantic icon box. |
| `size.icon.compact` | 20 | Supporting icon in a dense row. |
| `size.quick-add.gap` | 12 | Equal gap between the first three Today actions. |
| `size.container-chip.minimum-width` | 156 | Custom-amount container option reference width; may grow, may wrap. |
| `size.chart.height` | 180 | Reference chart plot height before accessibility reflow. |
| `size.vision.window.minimum` | 720 × 440 | Minimum vision window reference from the current architecture. |

| Token | Value | Role |
|---|---:|---|
| `radius.control` | 12 | Buttons, chips, fields, toggles, compact controls. |
| `radius.card` | 20 | Grouped cards and settings surfaces. |
| `radius.hero` | 28 | Hero vessel and hero readout surfaces. |
| `stroke.standard` | 1 | Card/control boundary and divider where needed. |
| `stroke.hero` | Product-defined vessel stroke | Hero outline; follows the PRD geometry. |

There are no heavy drop shadows. Use native material/blur sparingly for
separation and preserve a visible stroke or tonal difference in reduced
transparency settings. A component must not add a shadow merely to look
“polished”.

## 6. Motion tokens

Motion communicates a state change and is never required to understand the
amount or outcome.

| Token | Value | Use |
|---|---:|---|
| `motion.duration.quick` | 0.28 s | Button, chip, selection, and small control transitions. |
| `motion.duration.hero.pour` | 0.40–0.70 s | Active stream and level rise, derived from the series amount. |
| `motion.duration.hero.lead-in` | 0.14 s | Stream travels from above the vessel to the water surface. |
| `motion.duration.hero.settle` | 0.90 s maximum reference | Surface response/settle after contact; not an idle loop. |
| `motion.duration.confirm` | 1.30 s reference | Transient confirmation lifetime, with a 0.30 s fade. |
| `motion.duration.undo` | 0.45 s | Reversal after undo. |
| `motion.spring.snappy` | response 0.28, damping 0.85 | Controls and selected states. |
| `motion.spring.liquid` | response 0.55, damping 0.72 | Readout and non-pour refresh. |
| `motion.level.rise` | pour duration + 0.14 s, linear | Active-pour level, exact target at stream disappearance. |
| `motion.reduce.crossfade` | 0.20 s | Replacement for removed decorative motion. |

Required behavior:

- There is no `motion.idle.loop`. Idle water is flat.
- One shared pour clock drives stream, level, and final surface response.
- The active level does not spring, overshoot, or reach its target before the
  stream disappears.
- The stream starts above the vessel, remains contained, and uses the PRD's
  amount-derived width/depth/duration range.
- Device tilt is screen-aligned, full-range, damped, and disabled on simulator,
  Mac, Watch, widgets, face-up surfaces, and Reduce Motion.
- Coalesced taps produce one continuous visual pour while retaining one store
  row per log.
- Reduce Motion removes pour stream, surface reaction, tilt, and idle movement;
  the level cross-fades over 0.20 s and all values remain immediately readable.

## 7. Component contract format

Every reusable element has one contract with:

1. Purpose and semantic outcome.
2. Anatomy and content order.
3. Variants and state transitions.
4. Required tokens and forbidden literals.
5. Interaction and domain boundary.
6. Accessibility label/value/trait and focus order.
7. Localization and Dynamic Type behavior.
8. Responsive and platform-native mapping.
9. Reduce Motion and contrast behavior.
10. Owning source file/module.

The contracts below are the current required inventory. A component may be
implemented with a native platform control inside its owning file. “Custom”
means Ripple owns the semantic wrapper/visual composition; it does not mean
that Ripple reimplements text entry, sliders, toggles, permissions, or share
behavior.

## 8. Reusable components

### 8.1 Surface and feedback components

#### `GlassCard`

- **Purpose:** Group related content on a calm elevated surface.
- **Anatomy:** Optional title/header, ordered content, optional footer/action;
  the card itself is not a navigation destination unless the owning screen
  explicitly gives it an accessible action.
- **Variants/states:** Standard, compact, interactive, disabled, loading,
  error, and empty. Interactive state adds selected/focused treatment without
  changing the card's semantic role.
- **Tokens:** `color.surface.elevated`, `radius.card`, `stroke.standard`,
  `space.lg`, `type.title/body/caption`, native material only when it improves
  contrast.
- **Accessibility:** Expose one group heading and child controls in reading
  order. Do not flatten a card containing independent actions into one
  unlabeled element.
- **Native mapping:** Use the platform's grouped surface/card primitive when it
  supports the required grouping and accessibility; Ripple styling supplies
  semantic colors and shape.
- **Owner:** iOS `Packages/RippleUI/Sources/RippleUI/Components/GlassCard.swift`;
  Android `core:designsystem` surface primitive.

#### `GlassCardRow`

- **Purpose:** Consistent leading-icon, label/value, and trailing-action row
  inside a grouped surface.
- **Anatomy:** Leading semantic icon, primary label, optional secondary value,
  optional selected/default marker, trailing native action.
- **States:** Normal, focused, selected, disabled, destructive, loading, and
  error; states are announced through value/trait and not color alone.
- **Tokens:** `space.md/lg`, `size.icon.standard`, `type.body/caption`,
  `color.water.deep`, `color.icon.muted`, `stroke.standard`.
- **Accessibility/native mapping:** Keep row controls independently actionable;
  use a native settings row/list item where available and apply Ripple tokens.
- **Owner:** iOS `GlassCardRow.swift`; Android `core:designsystem` row.

#### `RippleToast`

- **Purpose:** Layout-neutral transient confirmation or undo feedback.
- **Anatomy:** Localized message, amount/outcome when relevant, optional one
  action such as Undo, compact glass/material surface, accessible timeout.
- **Variants:** Log success, delete-with-undo, restore, and recoverable local
  result. Persistent sync, permission, loading, and unresolved errors do not
  use a toast; they use an inline state surface.
- **Tokens:** `color.surface.elevated`, `color.water.deep`, `radius.control`,
  `space.md`, `type.callout/caption`, `motion.duration.confirm`,
  `motion.duration.quick`.
- **Interaction:** It overlays without reserving layout space. Action is
  keyboard/touch/assistive-technology reachable and remains available for the
  announced timeout. It must not steal focus from a just-completed form unless
  the platform requires it.
- **Accessibility:** Announce the message once, include amount/unit and action
  consequence, and provide a deterministic accessible timeout. Do not rely on
  color or disappearing motion to communicate success.
- **Native mapping:** iOS may use a custom overlay because Ripple requires a
  consistent layout-neutral confirmation; Android maps the same contract to a
  native Snackbar/Toast pattern with an action when supported.
- **Owner:** iOS `RippleToast.swift`; Android `core:designsystem` transient
  feedback host.

### 8.2 Logging and container components

#### `LogButton`

- **Purpose:** Execute one explicitly identified hydration log action.
- **Anatomy:** Optional icon, localized label, amount/container context, clear
  pressed/disabled state.
- **Variants:** Primary full-width, compact quick-add, wearable, system-surface
  action, and destructive only when the product contract explicitly names it.
- **Tokens:** `color.water.lagoon` primary, `color.water.deep` text/icon where
  contrast permits, `radius.control`, `size.control.minimum`, `space.md`,
  `type.callout`, `motion.duration.quick`.
- **Boundary:** The button sends a command to the injected feature/use-case
  boundary; it never writes storage, computes goal totals, or owns a second
  intake path.
- **Accessibility:** Label includes action, amount, unit, and container when
  known. Disabled state includes a reason if the reason is not obvious.
- **Native mapping:** Use a native button with Ripple styling and platform
  press/haptic behavior.
- **Owner:** iOS `LogButton.swift`; Android `core:designsystem` button wrapper.

#### `QuickAddCluster`

- **Purpose:** Show the first three ordered container actions on Today.
- **Anatomy:** One fixed horizontal row; exactly three slots when at least
  three containers exist; each slot is an equal-width `ContainerChip`/log
  action; no horizontal scroll.
- **States:** Loading placeholders keep bounds, fewer-than-three containers
  show only available slots without invented values, ready, disabled while a
  command is being committed if required, and error feedback through the
  owning surface/toast.
- **Tokens:** `size.quick-add.gap`, `size.control.minimum`, `space.md`,
  `radius.control`, `color.surface.elevated`, `color.water.lagoon`,
  `type.body/caption`.
- **Boundary:** Receives ordered `[Container]`; selecting a slot calls the
  shared logging command with the container's amount and ID.
- **Accessibility:** Each action names position only if useful (“Glass,
  250 ml”); no invisible fourth action. Reading order is persisted order.
- **Native mapping:** Use a platform horizontal layout, not a scrolling
  collection, with native button semantics for each slot.
- **Owner:** iOS `QuickAddCluster.swift`; Android Today feature with shared
  design-system container action.

#### `ContainerChip`

- **Purpose:** Represent a saved container as a selectable/loggable option.
- **Anatomy:** Container icon, localized name, amount/unit, selected/default
  indicator only when the owning surface needs it.
- **Variants:** Today quick add (equal flexible width), custom-amount selection
  (wider, all-container), Settings row, selected, unselected, disabled, and
  missing/unknown icon fallback.
- **Tokens:** `size.icon.standard`, `size.control.minimum`,
  `size.container-chip.minimum-width`, `radius.control`, `space.sm/md`,
  `color.water.deep`, `color.water.lagoon`, `color.surface.elevated`,
  `color.surface.selected`, `type.body/caption`.
- **Boundary:** It emits selection/activation; it does not decide default
  invariants or persist a container.
- **Accessibility:** Announces name, amount, selected/default state, and
  action. Icon-only visual selection is allowed only in `ContainerSymbolPicker`,
  where each option still has an accessible icon name.
- **Native mapping:** Use native selectable/button semantics, preserving
  platform focus, pointer, keyboard, and rotary behavior.
- **Owner:** iOS `ContainerChip.swift`; Android `core:designsystem` chip.

#### `ContainerSymbolPicker`

- **Purpose:** Select a saved-container icon while keeping the editor compact.
- **Anatomy:** Horizontal icon-only visual options; selected stroke/shape;
  accessible semantic name for every icon; no visible symbol-name text.
- **States:** Selected, unselected, focused, disabled, and invalid/unavailable
  fallback. The picker never displays a blank target.
- **Tokens:** `size.icon.standard`, `size.control.minimum`, `radius.control`,
  `color.water.lagoon`, `color.surface.selected`, `stroke.standard`,
  `motion.duration.quick`.
- **Boundary:** Emits a symbol identifier to the local editor draft. The
  editor performs validation and calls `UpsertContainer`.
- **Native mapping:** Use a native selectable group/collection when it keeps
  icon options accessible; style the selection with Ripple tokens.
- **Owner:** iOS `ContainerSymbolPicker.swift`; Android `core:designsystem`
  icon selector.

#### `AmountStepper`

- **Purpose:** Shared legacy/secondary discrete amount control where a product
  surface explicitly needs stepwise adjustment.
- **Policy:** It is not the primary control for the current `custom-amount`
  surface or container editor; those use a native slider as specified by the
  screen catalog. It remains available only where a stepper is semantically
  appropriate.
- **Tokens/accessibility:** `size.control.minimum`, `radius.control`,
  `type.numeric`, `color.water.lagoon`; expose decrement/increment labels,
  current value, unit, min/max, disabled bounds, and keyboard/rotary actions.
- **Owner:** iOS `AmountStepper.swift`; Android native increment/decrement
  controls wrapped by the design system.

### 8.3 Information and state components

#### `DayHeader`

- **Purpose:** Establish app identity and localized date context.
- **Anatomy:** App/product label, localized weekday/date, optional navigation
  context. It does not duplicate a date that the platform title already
  exposes in compact Day Detail.
- **Tokens:** `type.title/body`, `space.lg/xl`, `color.water.deep`.
- **Accessibility:** Announces one coherent date context. Locale determines
  order and grammar.
- **Owner:** iOS `DayHeader.swift`; Android shared header contract.

#### `RemainingLabel`

- **Purpose:** State the remaining amount and goal in a concise sentence.
- **Anatomy:** `remaining` plus localized separator and `goal`; goal-met copy
  follows the PRD and still exposes actual consumed value elsewhere.
- **Tokens:** `type.callout/body`, `type.numeric`, system secondary role, `space.md`.
- **Accessibility:** One sentence with units; never only a color or progress
  bar.
- **Owner:** iOS `RemainingLabel.swift`; Android text component.

#### `IntakeRow`

- **Purpose:** Show one stored intake in chronological context.
- **Anatomy:** Localized time, amount/unit, beverage, container name/icon when
  known, source when relevant, and edit/delete/restore actions.
- **States:** Normal, edited, deleted/restoreable, selected, loading mutation,
  and mutation error.
- **Tokens:** `type.body/caption/numeric`, `space.md`, `size.icon.compact`,
  `stroke.standard`, `color.water.deep`, `color.danger` for destructive action.
- **Boundary:** Emits edit/delete/restore commands; it does not mutate records.
- **Accessibility:** Announces all meaningful fields and action consequences.
- **Owner:** iOS `IntakeRow.swift`; Android design-system row plus feature file.

#### `SyncStatusView`

- **Purpose:** Explain sync/import availability without blocking local truth.
- **Anatomy:** Status icon, localized message, optional retry/details action.
- **States:** Available, importing, failed with safe user-facing detail,
  unavailable, and hidden when there is no useful status to communicate.
- **Tokens:** `type.caption/callout`, `color.water.deep`, `color.icon.muted`,
  `color.danger` only for actionable failure, `space.sm/md`.
- **Accessibility:** Announces status and retry action; does not imply that a
  locally stored log is lost when a projection fails.
- **Native mapping:** Use platform status/inline feedback patterns; do not
  show a transient toast for a persistent sync problem.
- **Owner:** iOS `SyncStatusView.swift`; Android design-system status row.

#### `EmptyState`

- **Purpose:** Explain a valid empty data set and provide the next useful
  action.
- **Anatomy:** Short title, one-sentence explanation, optional primary action,
  optional non-interactive artwork/icon.
- **Tokens:** `type.title/body`, `space.lg/xl`, `color.water.deep`,
  `color.icon.muted`, `radius.card` where grouped.
- **Accessibility:** Announces why the state is empty and the available action;
  artwork is decorative unless it carries required meaning.
- **Owner:** iOS `EmptyState.swift`; Android design-system empty state.

#### `DayRing`

- **Purpose:** Show one day's capped goal progress in History.
- **Anatomy:** Date label, progress stroke capped at 1.0, selected/today/future
  state, and accessible text value.
- **States:** Empty, partial, goal reached, over goal (same visual cap), today,
  selected, future disabled.
- **Tokens:** `color.water.aqua`, `color.water.lagoon`, `color.surface.selected`,
  `stroke.standard`, `motion.reduce.crossfade`.
- **Accessibility:** Announces date, consumed, goal, percentage, and future
  disabled state. The ring is never the sole value.
- **Motion:** No ring-spin introduction under Reduce Motion; avoid repeated
  idle animation.
- **Owner:** iOS `DayRing.swift`; Android design-system day marker.

### 8.4 Hero and water primitives

These elements compose the `today` hero and static Day Detail summary. They
share geometry but not behavior: Today permits the active pour contract;
Day Detail is static.

#### `GlassShape`

Draws the stylized 2D vessel outline and defines the content clip/inset. It
uses `radius.hero`, hero stroke tokens, and documented geometry. It never
contains business state or computes a goal percentage.

**Owner:** iOS `Hero/GlassShape.swift`; Android custom drawing primitive in the
design-system module only where Material shape primitives cannot express the
required vessel.

#### `WaterFill`

Clips a flat or motion-adjusted water surface to `GlassShape`. It accepts a
normalized presentation level from the feature/read model, preserves visible
water area, and renders no fill at level zero. It uses `color.water.aqua` and
the hero geometry token; it does not own persistence.

**Owner:** iOS `Hero/WaterFill.swift`; Android design-system drawing primitive.

#### `PourStreamShape`

Renders one narrow active stream above the vessel through the shared pour clock.
Width is 7–12 pt and duration 0.40–0.70 s according to series amount. It is
absent when idle or Reduce Motion is active. It never starts inside the glass
or becomes a permanent drop icon.

**Owner:** iOS `Hero/PourStream.swift`; Android custom drawing/animation only
for the same active-pour contract.

#### `GlassReadout`

Shows consumed amount, unit, and optional percentage in a legible elevated
readout. It uses `type.display/numeric`, `radius.hero`, and the surface tokens;
it remains above the water/stream layer and never clips at XXXL.

**Owner:** iOS `Hero/GlassReadout.swift`; Android design-system hero readout.

#### `RippleHeroView`

Owns composition and motion coordination for `GlassShape`, `WaterFill`,
`PourStreamShape`, and `GlassReadout`. It receives a snapshot and animation
events, not a repository. It honors face-up/simulator/Reduce Motion rules and
exposes a complete accessibility summary.

**Owner:** iOS `Hero/RippleHeroView.swift`; Android Today feature host using
design-system primitives.

### 8.5 Watch, widget, and system primitives

| Element | Contract | iOS owner | Android/native mapping |
|---|---|---|---|
| Watch water backdrop | Full-canvas flat level field; no phone hero tilt; supports reduced motion. | `Components/WatchWaterBackdrop.swift` | Wear Compose/custom canvas design-system primitive. |
| Watch log button | Crown/touch-friendly predefined log with amount/unit and source. | `Components/WatchLogButton.swift` | Wear-native button styled with shared tokens. |
| Watch quick amount row | Compact predefined actions with stable hit targets and no phone tab chrome. | `Components/WatchQuickAmountRow.swift` | Wear-native action row. |
| Watch day row | Seven-day local history row with amount/goal/status. | `Components/WatchDayRow.swift` | Wear-native list item. |
| Watch stat chart | One compact current-ISO-week chart with textual summary. | `Components/WatchStatChart.swift` | Wear chart primitive. |
| Widget glass | Read-only glass silhouette/remaining surface; no stream/tilt/calendar/chart. | `Components/WidgetGlass.swift` plus widget extension | Glance/widget native layout with shared roles. |
| Control/intent/notification result | Focused system action and localized result; shared use-case boundary. | App/extension adapters | Native tile, shortcut, Assistant, notification, or permission surface. |

System primitives are projections or command clients. They do not become a
second source of truth or a second `LogIntake` implementation.

## 9. Native-control policy

Use native controls when the behavior is ordinary platform behavior:

| Behavior | Preferred native expression | Ripple-specific responsibility |
|---|---|---|
| Text entry | Native text field/editor | Label, validation copy, tokenized surface, localization, and domain draft. |
| Continuous amount | Native slider/adjustable control | Range, step, numeric readout, unit, and tokenized track/thumb styling. |
| Boolean setting | Native toggle/switch | Label, default invariant, permission explanation, and tokenized surrounding row. |
| Choice among modes/periods | Native picker/menu/segmented control | Localized labels, selected value, data operation, and responsive placement. |
| Modal surface | Native sheet/dialog presentation | Content regions, tokenized surface, dismissal policy, and accessibility. |
| Destructive confirmation | Native confirmation dialog/action surface | Exact consequence copy, soft-delete semantics, undo/restore result. |
| Permission request | OS permission flow | Pre-permission explanation and post-denial recovery; never impersonate the OS prompt. |
| Share/export | Native share/document flow | `ExportData` output, localized names, and no domain mutation. |
| Keyboard/rotary/pointer | Platform input system | Keep focus order, adjustable values, and hit targets meaningful. |

A custom component is justified only when the product requires Ripple-specific
visual composition, hero geometry, reusable grouping, or a semantic overlay
that the native control does not provide. The custom wrapper must preserve the
native control's focus, accessibility actions, keyboard/rotary behavior,
hit-target size, and platform-standard dismissal/permission affordances.

## 10. Accessibility and acceptance matrix

Every new or changed component is reviewed in these configurations:

| Configuration | Required check |
|---|---|
| Light mode | Deep/Lagoon/Aqua/foam contrast, selection, destructive state, and readable strokes. |
| Dark mode | Cool anthracite surfaces, light Deep text role, readable Aqua/Lagoon, no black-on-black cards. |
| Dynamic Type/large text through XXXL | No clipped amounts, hidden actions, or unlabeled overflow. |
| Reduce Motion | No idle loop, stream, surface reaction, or tilt; values remain immediate. |
| VoiceOver/TalkBack | Labels, values, traits, adjustable actions, focus order, and destructive consequences. |
| Keyboard/pointer/rotary | Native focus, adjustable slider, reorder, selection, and dismissal paths. |
| Empty/loading/error/offline | State is explicit, actionable, and does not invent domain data. |
| DE/EN | No hard-coded English; dates, units, pluralization, and action copy localize. |

## 11. Design-system maintenance

Update this document in the same change when:

- a new token, component, component state, or native-control wrapper is added;
- an existing color, type, spacing, shape, material, motion, accessibility, or
  responsive rule changes;
- a screen requires a new component contract or a changed component variant;
- a platform cannot preserve the shared contract with the current mapping;
- a reference capture or acceptance criterion reveals a reusable-system defect.

The corresponding platform source file and platform architecture/UI document
must be updated in the same change. Do not fix a one-off feature by adding a
feature-local design system. Prior timeline entries are immutable.

## 12. Timeline

| Version | Date | Change | Impact |
|---|---|---|---|
| 1.0.0 | 2026-09-11 | Established canonical Ripple tokens, reusable UI contracts, native-control policy, and accessibility/motion acceptance requirements. | iOS and Android can implement the same visual semantics while retaining platform-native controls and behavior. |

*End of Ripple design system 1.0.0.*
