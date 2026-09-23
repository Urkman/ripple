# Ripple visual reference inventory

**Document type:** Shared visual-reference audit and visible-element inventory
**Document version:** 1.0.0
**Last verified:** 2026-09-23
**Reference release baseline:** Apple marketing version 1.1 — 17 September 2026

This review note records which visual references were inspected for each stable
surface, how each reference is classified, which operating-system chrome is
excluded from the platform-independent wireframe, and which product-owned
elements must remain visible. It is linked from the canonical surface files and
does not replace the product, data, design, or platform contracts.

## Audit rules

- The PRD remains authoritative for product behavior, domain meaning, and
  motion. A capture can expose visible composition, but it cannot invent a
  behavior that the written contract does not define.
- **Current visual target** means the reference is the current composition to
  reconcile against. **Supporting evidence** means it helps verify hierarchy or
  a native platform expression. **Wireframe** means the shared neutral
  illustration that must preserve the documented product-owned structure.
- Differences between iOS and Android captures are classified as native chrome,
  platform expression, localization, seeded sample data, or viewport/crop. A
  product-owned region is not removed merely because one capture does not show
  it.
- Product-owned elements retain their documented order, grouping, repetition,
  and action meaning. Native presentation may change the control expression,
  but may not silently drop, merge, reorder, or recomposite those elements;
  such a change requires an update to the canonical surface contract.
- Status bars, device frames, system tab/navigation chrome, notification
  grouping, permission dialogs, share destinations, and host complication/widget
  placement are system-owned unless the surface contract explicitly assigns
  their content to Ripple. They are not required in a shared wireframe; the
  product-owned labels, values, actions, and state indicators inside them are.
- The shared wireframes are neutral illustrations, not runtime screenshots.
  Runtime Android captures for resize/fold behavior do not yet exist; that gap
  remains explicit in the Android handoff.

## Reference register

### Apple/iOS evidence

| Reference | Classification | State / viewport | Visible scope and limitation |
|---|---|---|---|
| [`iphone-today.png`](screens/ios/iphone-today.png) | Current visual target | Ready, compact iPhone | Full Today product hierarchy; status bar and four-tab root chrome are native/platform presentation. |
| [`iphone-duo-today-outer.png`](screens/ios/iphone-duo-today-outer.png) | Current visual target | Zero/ready, compact outer display | Current fold/outer-display evidence; connectivity indicator and vertical root navigation are system/platform presentation. |
| [`iphone-history.png`](screens/ios/iphone-history.png) | Current visual target | Populated month, compact iPhone | Month grid and today-only add affordance; bottom root navigation and status bar are native chrome. |
| [`iphone-stats.png`](screens/ios/iphone-stats.png) | Supporting evidence | Week, compact iPhone, vertically cropped | Period selector, summaries, and first chart regions are visible; the crop does not remove the four-chart requirement in the written contract. |
| [`ipad-settings.png`](screens/ios/ipad-settings.png) | Supporting evidence | Ready, expanded iPad, vertically cropped | Profile through sync are visible; export/about remain required from the written Settings contract even though the capture ends before them. |
| [`watch-today.png`](screens/ios/watch-today.png) | Current visual target | Ready, wearable | Full-canvas water field, readout, and one Apple Watch add action; time/page indicators are platform chrome. |
| [`watch-history.png`](screens/ios/watch-history.png) | Supporting evidence | Recent history, wearable, cropped | Three rows are visible in the crop; the shared contract still requires seven elapsed local days and a continuation/scroll affordance. |
| [`watch-stats.png`](screens/ios/watch-stats.png) | Current visual target | Current ISO week, wearable, cropped | Week context, three summaries, and one compact chart; time/page indicators are platform chrome. |

### Android layout evidence

The PNGs in [`Android/UI/README.md`](Android/UI/README.md) are Android layout
evidence/reference captures, not pixel targets for iOS and not runtime proof.
They are inspected here for visible product composition and native-control
placement.

| Reference | Classification | State / viewport | Visible scope and limitation |
|---|---|---|---|
| [`phone-today.png`](Android/UI/phone-today.png) | Supporting evidence / Android layout target | Ready, compact phone | Hero, readout, three ordered quick adds, custom amount, and root navigation; the Android navigation bar is native chrome. |
| [`phone-history.png`](Android/UI/phone-history.png) | Supporting evidence / Android layout target | Populated month, compact phone | Month pager, weekday row, day rings, selected-day context; top/bottom Android chrome is native. |
| [`phone-day-detail.png`](Android/UI/phone-day-detail.png) | Supporting evidence / Android layout target | Ready, compact phone | Selected date, static summary, add action, three intake rows, and row actions. |
| [`phone-stats.png`](Android/UI/phone-stats.png) | Supporting evidence / Android layout target | Week, compact phone | Android groups chart content under Daily intake, Patterns, and Highlights; the shared semantic contract retains four distinct chart families. |
| [`phone-settings.png`](Android/UI/phone-settings.png) | Supporting evidence / Android layout target | Ready, compact phone | Profile, goal, containers, reminders/health, data, and about; native list/control rendering is platform-owned. |
| [`phone-onboarding.png`](Android/UI/phone-onboarding.png) | Supporting evidence / Android layout target | First run, compact phone | Six-page sequence overview and Continue action; native permission surfaces are not pictured. |
| [`tablet-history-split.png`](Android/UI/tablet-history-split.png) | Supporting evidence / Android layout target | Ready, expanded tablet | Calendar and selected day detail are visible side by side; rail and top app bar are native chrome. |
| [`tablet-stats.png`](Android/UI/tablet-stats.png) | Supporting evidence / Android layout target | Week, expanded tablet | Summary row and four chart/highlight regions in an adaptive grid. |
| [`wear-today.png`](Android/UI/wear-today.png) | Supporting evidence / Android layout target | Ready, wearable | Android-native predefined amount chips and full-canvas field; this is a platform expression of the wearable logging action, not Apple Watch chrome. |
| [`wear-history.png`](Android/UI/wear-history.png) | Supporting evidence / Android layout target | Seven-day history, wearable | Six rows are visible in the crop; the contract requires seven elapsed days and native scroll/paging for the remaining row. |
| [`wear-day-detail.png`](Android/UI/wear-day-detail.png) | Supporting evidence / Android layout target | Ready, wearable | Selected date, summary, three entry rows, and individual delete action. |
| [`wear-stats.png`](Android/UI/wear-stats.png) | Supporting evidence / Android layout target | Current ISO week, wearable | Summary and one compact chart; no period picker. |

## Surface inventories

Each section is the visual inventory for the linked canonical surface. The
wireframe column names the required shared image; platform-owned chrome is
listed separately so it is not mistaken for a missing product region.

## today

**Canonical surface:** [`screens/today.md`](screens/today.md)
**Reference set:** iPhone Today, iPhone Duo outer Today, Android phone Today,
shared ready/adaptive wireframes.
**Classification:** Mixed current iOS target, Android supporting evidence, and
current shared semantic wireframe.
**States/viewports:** Ready compact; zero/ready outer display; constrained and
expanded/fold-region adaptive composition.
**Excluded chrome:** Status bars, connectivity indicators, iOS tab bar, Android
NavigationBar/Rail, and device/fold frame.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Header/context | Ripple identity and localized local date/context | Ready compact; outer display | `today--ready--compact`, adaptive header/context note |
| Hero vessel | Contained 2D glass silhouette, water level, flat idle surface, consumed amount/unit and percentage/goal readout | Ready, zero, adaptive | Hero/readout region; no circular progress |
| Remaining status | Remaining amount and goal status with units | All ready/zero states | Remaining region below hero |
| Ordered quick adds | Exactly the first three saved containers, each with icon/name/amount and equal-width non-scrolling action bounds | Compact and expanded | Quick-add row/action region |
| Custom amount | Explicit labeled action opening custom entry | All compact/expanded layouts | Safe action region |
| Confirmation feedback | Localized completed-log feedback and optional undo without moving measured content | Success | Floating feedback annotation |
| Reflow regions | Hero/actions side-by-side only when they fit; constrained vertical fallback; state/draft retention | Resize/fold | `today--resize--adaptive.png/.svg` |

## custom-amount

**Canonical surface:** [`screens/custom-amount.md`](screens/custom-amount.md)
**Reference set:** Shared custom-amount wireframe; no runtime capture in the
current reference pack.
**Classification:** Current shared semantic wireframe; native sheet expression
is intentionally deferred to platform contracts.
**States/viewports:** Ready compact; large text/reflow described by text.
**Excluded chrome:** Native sheet drag handle, keyboard/rotary chrome, and
platform dismissal affordance.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Sheet context | Dismiss/back affordance and localized title | Ready compact | Sheet boundary/header |
| Amount readout | Current amount and unit | Ready/invalid | Large numeric readout |
| Amount control | Minimum, maximum, current value, and meaningful step | Ready/invalid | Slider plus endpoint labels |
| Container selection | Every saved container, icon/name/amount, selected state; selection does not log | Ready, variable count | Repeated selectable region; continuation must remain reachable |
| Primary action | Add with final amount and optional container context | Ready/invalid/success | Full-width Add action |

## history

**Canonical surface:** [`screens/history.md`](screens/history.md)
**Reference set:** iPhone History, Android phone History, Android tablet History
split, shared compact/expanded/adaptive wireframes.
**Classification:** Current compact iOS target plus Android compact/expanded
supporting evidence and shared semantic wireframes.
**States/viewports:** Populated month compact; selected-day expanded split;
constrained height and active-fold regions.
**Excluded chrome:** Status bars, iOS/Android root navigation, device frame, and
native split/rail chrome; the today-only add meaning remains product-owned.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Today-only add | Plus/add action beside the root context when the selected day is today | Compact and expanded ready | History ready compact/expanded |
| Month context | Localized month title, previous/next controls, and horizontal month paging | All calendar states | Month header |
| Weekday row | Locale-ordered weekday labels | All calendar states | Calendar header |
| Day grid | One day number and one capped ring/marker per calendar day | Ready, empty, future | Calendar grid; future cells visibly unavailable |
| Selection/status | Selected day indication plus goal/progress status and selected-day context | Selected day | Context/legend region |
| Detail region | Same selected day remains reachable beside calendar only above the documented width threshold | Expanded/fold | `history--ready--expanded`, `history--resize--adaptive` |

## day-detail

**Canonical surface:** [`screens/day-detail.md`](screens/day-detail.md)
**Reference set:** Android phone Day Detail, Android tablet History split, shared
compact/expanded wireframes; no dedicated Apple capture.
**Classification:** Android supporting evidence and current shared semantic
wireframe.
**States/viewports:** Today with add; past day without add; compact nested and
expanded split.
**Excluded chrome:** Native top app bar/rail/sidebar and system destructive
confirmation; selected date and row actions remain product-owned.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Date context | Localized selected weekday/date without a duplicate compact heading | Compact and expanded | Header/title |
| Static summary | Contained glass/readout, consumed amount/unit, goal, remaining or goal-reached status | All ready states | Summary region |
| Entries collection | Entries heading and chronological repeated rows | Ready/empty | Intake collection; count varies with sample data |
| Row content/actions | Time, amount/unit, container/source, edit/delete affordances where supported | Ready | Row metadata/action region |
| Today add | Explicit add action only for the local current day | Today | Compact/expanded action region |
| Empty/recovery | No-entry copy, sync/error status, and retry/undo feedback without moving rows | Empty/error/delete | Text contract and feedback annotation |

## edit-intake

**Canonical surface:** [`screens/edit-intake.md`](screens/edit-intake.md)
**Reference set:** Shared edit-intake wireframe; no runtime capture.
**Classification:** Current shared semantic wireframe.
**States/viewports:** Ready compact; validation/error and large-text reflow in
text.
**Excluded chrome:** Native sheet, keyboard, picker, and dismissal chrome.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Entry context | Selected date/time and original identity context | Ready/editing | Header/context |
| Editable fields | Amount/unit plus supported container, metadata, and time fields | Ready/invalid | Ordered field stack |
| Validation | Field-associated correction message | Invalid | Inline validation region |
| Actions | Cancel/dismiss and primary Save | Ready/invalid/success | Bottom action row |

## stats

**Canonical surface:** [`screens/stats.md`](screens/stats.md)
**Reference set:** iPhone Stats, Android phone Stats, Android tablet Stats, shared
compact/expanded wireframes.
**Classification:** iOS current visual evidence, Android layout evidence, and
shared semantic target; the iPhone image is visibly vertically cropped.
**States/viewports:** Week compact; expanded adaptive grid; month/year and empty
states in text.
**Excluded chrome:** Status bar, root navigation, and native picker chrome.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Period/range context | Week/Month/Year selector plus selected period/date range and navigation context | All ready periods | Period region; dependent range row is not optional |
| Summary row | Average/day, goal reached, and total with units | All ready periods | Three grouped summary tiles |
| Actual vs goal | Consumed series plus goal reference, unit-aware axes/labels | All ready periods | Chart family 1 |
| Goal rate | 0–100% hit-rate series with accessible values | All ready periods | Chart family 2 |
| Daypart distribution | Morning, midday/noon, afternoon, evening buckets | All ready periods | Chart family 3 |
| Container distribution | Container bars with bounded Other grouping | All ready periods | Chart family 4 |
| Highlights | Best day, weakest completed day, no-entry days, qualifying run | Ready | Dedicated highlight region |
| Empty/accessibility | Localized no-data state and text/value alternatives for every chart | Empty/large text | State text and chart annotations |

## settings

**Canonical surface:** [`screens/settings.md`](screens/settings.md)
**Reference set:** iPad Settings, Android phone Settings, shared compact
wireframe.
**Classification:** Android phone is the fullest current composition; iPad is a
vertically cropped expanded reference; shared wireframe is the platform-neutral
target.
**States/viewports:** Ready compact and expanded; no-container, permission,
sync-error, and large-text states in text.
**Excluded chrome:** Status bar, root navigation, and native switch/picker/
reorder/share control rendering.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Profile and unit | Profile context and preferred unit | Ready | Group 1 |
| Daily goal | Calculation mode, target amount/unit, and non-medical helper text where applicable | Ready/invalid | Group 2 |
| Containers | Complete ordered rows with icon, name, amount, default, reorder, edit/delete/add affordances | Ready/no containers | Group 3; count is variable and never silently truncated |
| Reminders | Enabled state, schedule/interval summary, and child editor route | Ready/permission | Group 4 |
| Health | Read/write/projection status and permission action | Ready/denied | Group 5 |
| Sync | Local/cloud/device freshness and recoverable status | Ready/offline/error | Group 6, separate from Health |
| Export | Versioned JSON/CSV export action and status | Ready/error | Group 7 |
| About/support | Version, license/privacy/source links | Ready | Group 8 |

## add-container

**Canonical surface:** [`screens/add-container.md`](screens/add-container.md)
**Reference set:** Shared add-container wireframe; no runtime capture.
**Classification:** Current shared semantic wireframe.
**States/viewports:** Ready compact; invalid and large-text sheet in text.
**Excluded chrome:** Native text entry, slider, toggle, sheet dismissal, and
keyboard chrome.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Sheet context | Dismiss/cancel and localized title | Ready | Sheet header |
| Name | Labeled editable field | Ready/invalid | Name field |
| Icon selection | Icon-only options with semantic labels and selected state | Ready/invalid | Symbol selector |
| Amount | Label, current amount/unit, range endpoints, and slider | Ready/invalid | Amount region |
| Default | One-effective-default control and current state | Ready | Default control |
| Validation/save | Inline validation and primary Save | Invalid/ready/success | Action/status region |

## edit-container

**Canonical surface:** [`screens/edit-container.md`](screens/edit-container.md)
**Reference set:** Shared edit-container wireframe; no runtime capture.
**Classification:** Current shared semantic wireframe.
**States/viewports:** Ready compact; delete confirmation/error and large-text
reflow in text.
**Excluded chrome:** Native editor sheet, input controls, and destructive
confirmation dialog.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Identity/context | Dismiss and title identifying the existing container | Ready | Sheet header |
| Editable values | Name, icon-only selection, amount/readout/slider, default state | Ready/invalid | Ordered editor fields |
| Validation/actions | Inline validation, Save, and separated destructive Delete | Ready/invalid/delete | Save plus Delete action |
| Delete consequence | Explicit confirmation and historical-retention/fallback explanation | Delete confirmation | Text contract/native dialog mapping |

## edit-reminder

**Canonical surface:** [`screens/edit-reminder.md`](screens/edit-reminder.md)
**Reference set:** Shared edit-reminder wireframe; no runtime capture.
**Classification:** Current shared semantic wireframe.
**States/viewports:** Ready compact; permission denied and scheduling error in
text.
**Excluded chrome:** Native time pickers, toggle, permission surface, and
sheet dismissal chrome.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Sheet context | Dismiss/cancel and localized title | Ready | Header |
| Enabled state | Reminder toggle and current enabled value | Ready/off | Enabled control |
| Schedule | Start/end times and interval/after-last-sip value with units | Ready/invalid | Schedule fields |
| Permission/status | Authorization state and actionable explanation | Ready/denied/error | Status region |
| Validation/save | Field-associated validation and Save/reschedule action | Invalid/ready/success | Bottom action/status |

## onboarding

**Canonical surface:** [`screens/onboarding.md`](screens/onboarding.md)
**Reference set:** Android phone onboarding layout, shared onboarding wireframe;
no Apple runtime capture.
**Classification:** Android supporting evidence and current shared semantic
wireframe.
**States/viewports:** First run compact; six-page sequence; permission pending,
denied, and large text in text.
**Excluded chrome:** Native Health/notification permission dialogs and host
status/navigation chrome.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Page context | Page number/progress and current step | All six pages | Progress indicator |
| Page content | Illustration/copy plus the page-specific unit, health, goal, container, or reminder content | Six-page sequence | Representative page 6 wireframe; full sequence in text |
| Permission explanation | Optionality and why the permission is useful | Health/reminder pages | Explanation region/native handoff note |
| Navigation actions | Back, Skip where allowed, Next/Finish | All pages | Bottom action row |

## watch-today

**Canonical surface:** [`screens/watch-today.md`](screens/watch-today.md)
**Reference set:** Apple Watch Today, Android Wear Today, shared wearable
wireframe.
**Classification:** Platform-specific wearable evidence with an explicit
native action variation; shared outcome and water/readout structure remain
common.
**States/viewports:** Ready wearable; empty/goal/offline/reduced-motion in text.
**Excluded chrome:** Watch time, page dots, crown/rotary affordance, and
Wear/Watch page navigation.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Context/readout | Today context, consumed amount/unit, goal, remaining, percentage | Ready | Top/readout region |
| Full-canvas level | Static contained water-level field with no tilt or idle loop | Ready/empty/goal | Full wearable field |
| Logging action region | Platform-native predefined action or single add entry that reaches the documented custom amount flow; action meaning/amount stays explicit | Apple Watch vs Android Wear | Lower action region; native platform mapping resolves the variation |
| Feedback | Completed-log confirmation and eligible undo | Success | Floating feedback, no layout reservation |

## watch-custom-amount

**Canonical surface:** [`screens/watch-custom-amount.md`](screens/watch-custom-amount.md)
**Reference set:** Shared wearable custom-amount wireframe; no runtime capture.
**Classification:** Current shared semantic wireframe.
**States/viewports:** Ready wearable; invalid/offline/reduced-motion in text.
**Excluded chrome:** Native rotary/crown and sheet dismissal chrome.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Context | Back/dismiss and localized amount title | Ready | Header |
| Amount draft | Current amount/unit and adjustable range/step | Ready/invalid | Numeric readout/rotary note |
| Optional presets | Compact saved-container selection when supported | Ready, variable | Selection region |
| Confirm | Explicit confirm/log action; selection or adjustment alone does not write | Ready/invalid/success | Primary action |

## watch-history

**Canonical surface:** [`screens/watch-history.md`](screens/watch-history.md)
**Reference set:** Apple Watch History, Android Wear History, shared wearable
wireframe.
**Classification:** Wearable supporting evidence with cropped/variable native
density; shared contract is authoritative for seven elapsed days.
**States/viewports:** Seven-day ready list; empty/offline and continuation in
text.
**Excluded chrome:** Watch time, page dots, crown/rotary chrome, and host list
scroll indicators.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Context | History title and local-day framing | Ready | Header |
| Seven-day collection | Today plus six previous elapsed local days, chronological meaning, one row per day | Ready | Seven repeated rows |
| Row values | Localized day/date, total, goal/progress status, and selection affordance | Ready/empty | Row metadata |
| Continuation | Native scrolling/paging cue when all seven rows do not fit at once | Cropped wearable view | Bottom continuation cue |
| Empty/sync | No-entry and freshness/error status | Empty/offline | State text |

## watch-day-detail

**Canonical surface:** [`screens/watch-day-detail.md`](screens/watch-day-detail.md)
**Reference set:** Android Wear Day Detail and shared wearable wireframe; no
Apple runtime capture.
**Classification:** Android supporting evidence and shared semantic wireframe.
**States/viewports:** Ready selected day; empty and delete/undo states.
**Excluded chrome:** Native swipe-back, rotary focus, and confirmation surface.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Date/summary | Selected date, total, goal/remaining status | Ready | Header/summary |
| Entries | Chronological rows with time, amount/unit, source/container | Ready/empty | Repeated rows |
| Delete action | Individual row-level soft delete, explicit consequence, and Undo feedback | Ready/delete | Row/action region |

## watch-stats

**Canonical surface:** [`screens/watch-stats.md`](screens/watch-stats.md)
**Reference set:** Apple Watch Stats, Android Wear Stats, shared wearable
wireframe.
**Classification:** Current wearable evidence and shared semantic wireframe.
**States/viewports:** Current ISO week ready; empty/offline/reduced-motion in
text.
**Excluded chrome:** Watch time/page indicators and native chart interaction
chrome.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Week context | Current ISO-week range and elapsed-day meaning | Ready | Header/context |
| Summary | Average per elapsed day, goal hits, and total with units | Ready | Summary region |
| Chart | Exactly one compact chart with date/value semantics | Ready/empty | Chart region |
| Text alternative | Accessible chart summary and no-data/error status | All states | Footer/annotation |

## widget

**Canonical surface:** [`screens/widget.md`](screens/widget.md)
**Reference set:** Shared widget wireframe; no runtime capture in the current
pack.
**Classification:** Current shared system-surface illustration; host family
geometry remains native.
**States/viewports:** Static ready; small/medium/large families and stale state
in text.
**Excluded chrome:** Host placement, family frame, refresh controls, and system
widget chrome.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Snapshot | Consumed/remaining, goal, percentage, and static water/progress representation | Ready/goal/over-goal | Static projection region |
| Focused action | Permitted predefined amount/action with unit | Supported families | Action region |
| Freshness/error | Explicit stale/unavailable status | Stale/error | Status annotation |

## quick-log-control

**Canonical surface:** [`screens/quick-log-control.md`](screens/quick-log-control.md)
**Reference set:** Shared quick-log wireframe; no runtime capture.
**Classification:** Current shared system-entry illustration.
**States/viewports:** Ready/unavailable/success.
**Excluded chrome:** Host control placement, focus, and system interaction.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Focused action | Action name, resolved amount/unit, and source meaning | Ready | Control card |
| Result | Success/error result without a second persistence path | Success/error | Result/status line |

## notification-actions

**Canonical surface:** [`screens/notification-actions.md`](screens/notification-actions.md)
**Reference set:** Shared notification-action wireframe; no runtime capture.
**Classification:** Current shared system-entry illustration.
**States/viewports:** Ready/invalid/permission/success.
**Excluded chrome:** Notification shade grouping, sound, priority, dismissal,
and host action styling.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Reminder context | Localized title/body plus remaining/goal context where useful | Ready | Notification content |
| Actions | One configured log action with amount/unit and optional open-app action | Ready/invalid | Action row |
| Result | Stored-log feedback or unavailable state | Success/error | System feedback mapping |

## shortcuts-and-intents

**Canonical surface:** [`screens/shortcuts-and-intents.md`](screens/shortcuts-and-intents.md)
**Reference set:** Shared shortcut/intent wireframe; no runtime capture.
**Classification:** Current shared semantic invocation illustration.
**States/viewports:** Ready/validation/success/error.
**Excluded chrome:** Voice assistant, shortcut editor, and platform invocation
shell.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Parameters | Amount/unit and optional container selection | Ready/invalid | Parameter fields |
| Result | Localized result naming amount/source and success/error | Success/error | Result region |

## complication

**Canonical surface:** [`screens/complication.md`](screens/complication.md)
**Reference set:** Shared complication wireframe; no runtime capture.
**Classification:** Current shared system-surface illustration.
**States/viewports:** Ready/stale/action-supported; host families vary.
**Excluded chrome:** Host family geometry, placement, refresh cadence, and
watch-face chrome.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Focused snapshot | Remaining/goal or capped progress with actual amount accessible | Ready/stale | Ring/remaining region |
| Optional action | Explicit positive amount/unit and logging meaning | Action-supported | Focused action region |

## share-export

**Canonical surface:** [`screens/share-export.md`](screens/share-export.md)
**Reference set:** Shared share/export wireframe; no runtime capture.
**Classification:** Current shared system-handoff illustration.
**States/viewports:** Ready/preparing/error/empty export.
**Excluded chrome:** Native save/share destination, file permission prompts,
and host picker chrome.

| Product-owned region or element | Required visible content | State / viewport | Wireframe mapping |
|---|---|---|---|
| Scope/format | Export description, included data categories, versioned JSON/CSV formats | Ready | Scope region |
| Preparation status | Loading, empty-but-valid, or error/retry state | Preparing/empty/error | Status region |
| Handoff action | Prepare/export and system-owned save/share destination | Ready/success | Primary action and handoff note |

## Reconciled differences and remaining gaps

- The shared Stats wireframes now preserve four separate chart-family regions
  and a dedicated highlights region. Android's compact reference groups some of
  those charts under “Patterns”; that is classified as native grouping, not a
  license to remove the four semantic families.
- The shared Settings wireframe now keeps Health, Sync, Export, and About as
  distinct product-owned groups even though the Android reference visually
  groups some rows. The platform mapping may group native rows only when it
  preserves those meanings and actions.
- The shared History wireframes now show the today-only add affordance. The
  adaptive overview remains a responsive composition diagram, not a runtime
  capture.
- The shared Wear History wireframe now represents all seven elapsed days and a
  continuation cue. The Apple and Android captures show fewer rows only because
  their visible crops/densities differ.
- Android resize/fold runtime evidence is still missing. The current iPhone Duo
  outer-display capture verifies only the pictured compact zero state; it does
  not prove live reflow, active-fold placement, or state retention.

## Timeline

| Version | Date | Change | Impact |
|---|---|---|---|
| 1.0.0 | 2026-09-23 | Added the evidence classification and visible-element inventory for all 22 stable surfaces; reconciled current captures, shared wireframes, and platform-owned chrome. | Documentation review can verify product-owned region order, density, repeated elements, chart structure, wearable continuation, and known evidence gaps without treating screenshots as a second product authority. |
