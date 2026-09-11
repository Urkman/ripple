# Ripple Screen and Sheet Catalog

**Document type:** Shared, platform-independent surface index and contract  
**Version:** 1.1.0 — 11 September 2026  
**Last verified:** 2026-09-11  
**Language:** English identifiers; user-visible copy is DE + EN  
**Status:** Normative companion to [`Ripple_PRD.md`](Ripple_PRD.md)

This document is the index for Ripple's user-facing surfaces. It owns the
stable IDs, the shared semantic schema, the global state vocabulary, and the
maintenance rules. The detailed description of a screen or sheet does **not**
live in this index: every surface has exactly one canonical,
platform-independent Markdown file in [`screens/`](screens/).

The product contract remains in the [Ripple PRD](Ripple_PRD.md). Visual roles,
tokens, reusable elements, and native-control policy are in
[`Ripple_DESIGN_SYSTEM.md`](Ripple_DESIGN_SYSTEM.md). Domain values,
persistence, and use-case boundaries are in
[`Ripple_DATA_MODEL.md`](Ripple_DATA_MODEL.md). Platform mappings are in
[`IOS_ARCHITECTURE.md`](IOS_ARCHITECTURE.md),
[`Android/ANDROID_ARCHITECTURE.md`](Android/ANDROID_ARCHITECTURE.md), and
[`Android/ANDROID_UI_SPEC.md`](Android/ANDROID_UI_SPEC.md).

## 1. Authority and terminology

The documentation authority is intentionally layered:

1. `AGENTS.md` governs repository process, architecture boundaries, bans, and
   synchronization requirements.
2. [`Ripple_PRD.md`](Ripple_PRD.md) governs product scope, user-visible
   behavior, flows, domain invariants, and motion contracts.
3. This index governs stable surface IDs, the canonical-file structure, the
   shared surface schema, and cross-surface rules.
4. The individual files in [`screens/`](screens/) govern the complete
   platform-independent meaning of one surface: layout order, function,
   read model, actions, states, validation, accessibility, tokens, responsive
   behavior, and forbidden behavior.
5. [`Ripple_DESIGN_SYSTEM.md`](Ripple_DESIGN_SYSTEM.md) governs visual roles,
   tokens, reusable UI elements, and system-control policy.
6. [`Ripple_DATA_MODEL.md`](Ripple_DATA_MODEL.md) governs data fields,
   snapshots, persistence, and use-case contracts.
7. Platform architecture and UI documents map the shared contracts to native
   implementation modules, controls, navigation, and system surfaces.

The canonical surface files are semantic documents, not framework recipes.
They must not require SwiftUI, UIKit, Jetpack Compose, Material, or another
specific UI toolkit. A platform may use its own navigation chrome, input
affordances, layout density, and permission presentation, but it must preserve
the outcome, information priority, state behavior, and domain operation.

The following terms are semantic:

- **Surface:** A user-facing screen, sheet, dialog-like system surface, or
  system entry point with a defined outcome.
- **Screen:** A navigable app surface that can be revisited through the
  platform's navigation model.
- **Sheet:** A transient app surface presented above an owning screen and
  dismissed or completed by an explicit action.
- **Canonical surface file:** The one Markdown file under `screens/` that
  completely describes one stable surface ID. It is the source of truth for
  the surface's layout and function, independent of implementation language.
- **Region:** A visually and semantically ordered area of a surface. A region
  is not automatically a reusable component or a separate document.
- **System surface:** A platform-owned entry point such as a widget, shortcut,
  notification action, control, complication, or share/export surface.
- **Primary action:** The action that completes the surface's stated outcome.
- **Inline feedback:** Persistent or stateful feedback that remains in the
  surface layout, such as sync, permission, loading, or unresolved errors.
- **Transient feedback:** A layout-neutral confirmation or undo affordance
  that floats above the owning surface and then disappears.

## 2. Canonical surface files

Each row below maps one stable surface ID to exactly one detailed description
file. The file is the authoritative place for that surface's layout and
function. Platform documents may link to it and may add native implementation
mapping, but they must not create a competing semantic description.

| Stable ID | Surface | Kind | Canonical description |
|---|---|---|---|
| `today` | Today | Root screen | [`screens/today.md`](screens/today.md) |
| `custom-amount` | Custom amount | Sheet | [`screens/custom-amount.md`](screens/custom-amount.md) |
| `history` | History | Root screen | [`screens/history.md`](screens/history.md) |
| `day-detail` | Day Detail | Child screen | [`screens/day-detail.md`](screens/day-detail.md) |
| `edit-intake` | Edit intake | Sheet | [`screens/edit-intake.md`](screens/edit-intake.md) |
| `stats` | Stats | Root screen | [`screens/stats.md`](screens/stats.md) |
| `settings` | Settings | Root screen | [`screens/settings.md`](screens/settings.md) |
| `add-container` | Add container | Sheet | [`screens/add-container.md`](screens/add-container.md) |
| `edit-container` | Edit container | Sheet | [`screens/edit-container.md`](screens/edit-container.md) |
| `edit-reminder` | Edit reminders | Sheet | [`screens/edit-reminder.md`](screens/edit-reminder.md) |
| `onboarding` | Onboarding | Onboarding surface | [`screens/onboarding.md`](screens/onboarding.md) |
| `watch-today` | Wear Today | Wearable root screen | [`screens/watch-today.md`](screens/watch-today.md) |
| `watch-custom-amount` | Wear custom amount | Wearable sheet | [`screens/watch-custom-amount.md`](screens/watch-custom-amount.md) |
| `watch-history` | Wear History | Wearable screen | [`screens/watch-history.md`](screens/watch-history.md) |
| `watch-day-detail` | Wear Day Detail | Wearable screen | [`screens/watch-day-detail.md`](screens/watch-day-detail.md) |
| `watch-stats` | Wear Stats | Wearable screen | [`screens/watch-stats.md`](screens/watch-stats.md) |
| `widget` | Widget | System surface | [`screens/widget.md`](screens/widget.md) |
| `quick-log-control` | Quick-log control | System surface | [`screens/quick-log-control.md`](screens/quick-log-control.md) |
| `notification-actions` | Notification actions | System surface | [`screens/notification-actions.md`](screens/notification-actions.md) |
| `shortcuts-and-intents` | Shortcuts and intents | System surface | [`screens/shortcuts-and-intents.md`](screens/shortcuts-and-intents.md) |
| `complication` | Complication | System surface | [`screens/complication.md`](screens/complication.md) |
| `share-export` | Share/export | System surface | [`screens/share-export.md`](screens/share-export.md) |

The catalog currently contains 22 stable surface IDs. Renaming a localized
surface does not change its ID. A new ID is required only when the user
outcome, lifecycle, or domain responsibility changes; a visual rearrangement
that preserves the outcome updates the existing file.

## 3. Required structure of every canonical surface file

Every file in [`screens/`](screens/) follows the same semantic template. It
must contain enough information for an independent iOS or Android team to
rebuild the surface without guessing:

| Section | Required content |
|---|---|
| Identity | Stable ID, version, verification date, localized name, and kind. |
| Purpose and outcome | What the user understands or completes. |
| Entry and exit | Entry points, dismissal/back behavior, completion, and mutation boundary. |
| Layout and region order | Semantic reading order, hierarchy, sizing intent, and responsive reflow. |
| Read model | Snapshot/settings data required to render the surface. |
| Actions and operations | User action, named domain operation, resulting state, and feedback. |
| State matrix | Loading, empty, ready, goal/over-goal, permission, offline/sync, error, success, and reduced motion as applicable. |
| Validation and destructive behavior | Ranges, disabled states, confirmation, soft delete, undo, and recovery. |
| Accessibility | Labels, values, traits, focus order, input alternatives, and large-text behavior. |
| Design contract | Named Ripple tokens and reusable elements; native controls where appropriate. |
| Responsive/platform behavior | Compact, regular, expanded, wearable, and system-surface adaptation without changing meaning. |
| Forbidden behavior | Specific implementations that violate the shared contract. |
| Related contracts | Links to the PRD, design system, data model, index, and platform mappings. |

The files use platform-independent terms such as “horizontal action row”,
“modal amount-entry surface”, and “primary action”. They do not prescribe a
production source-file layout. iOS and Android may split or co-locate private
implementation details according to their native architecture; the one-file
documentation requirement applies to the **canonical description**, not to
production source code. Reusable UI elements remain separately owned by the design-system
contract and implementation policy.

## 4. Shared state vocabulary

All canonical surface files use this vocabulary unless an entry narrows it:

- **Loading:** The surface has a stable shell and an announced loading state;
  actions that require unavailable data are disabled or deferred.
- **Empty:** The data set is valid but contains no entries. Empty copy gives
  the next useful action and never invents chart or history data.
- **Ready:** Required data is available and actions are enabled according to
  validation rules.
- **Goal reached/over goal:** Goal progress is capped visually at 100 percent;
  actual consumed milliliters remain available to text and accessibility.
- **Permission required:** The app explains why a permission is useful and
  invokes the platform permission flow; denying it does not block local logs.
- **Offline/sync unavailable:** Local source-of-truth actions remain usable;
  sync status is shown inline and no local log is rolled back because a
  projection or sync operation failed.
- **Unresolved error:** The affected operation is explained, retry is offered
  where meaningful, and unrelated actions remain available.
- **Success:** The changed state is reflected immediately and feedback names
  the amount or outcome in the active locale.
- **Reduced motion:** Pour streams, surface reactions, tilt, and decorative
  transitions are removed or cross-faded according to the motion tokens.

No surface may use a spinner, shimmer, animation, or decorative placeholder as
the only indication of a state. Numeric amounts use locale-aware formatting
and keep integer milliliters as the domain value.

## 5. Cross-surface accessibility and responsive baseline

- Every amount includes a unit and localized formatting. A number without
  `ml`/`fl oz` is incomplete copy.
- Every icon-only visual control has an accessible name and selected/disabled
  value. Visible icon-only presentation is allowed only when the semantic name
  remains available to assistive technology.
- Focus order follows semantic region order, not decorative geometry.
- Dynamic Type/large text may reflow, wrap, or increase surface height. It may
  not clip numeric readouts, hide the primary action, or remove an available
  container without an explicit overflow affordance.
- Reduced motion is a behavior change, not merely a shorter duration: no idle
  sine loop, no pour stream, no tilt, and no surface reaction. A 0.20-second
  cross-fade is the maximum replacement transition unless a platform requires
  less.
- Light/dark mode changes semantic surfaces and contrast roles, not product
  meaning. The same state must remain distinguishable without color alone.
- The platform's standard hit targets, keyboard/rotary behavior, permission
  prompts, back/dismiss gestures, and destructive confirmations are retained
  when they satisfy the outcome.

## 6. Maintenance and versioning

Update the affected canonical surface file in the same change when its
purpose, layout, function, action, state, validation, accessibility, or
responsive behavior changes. Update this index when a surface is added,
removed, renamed, or its stable ID/kind changes. Update the design-system,
data-model, PRD, or platform documents when their contracts change.

The platform architecture/UI documents may describe native implementation
entry points and mappings. They must link back to the canonical file and must
not duplicate or contradict its semantic surface contract. A platform-only
expression change belongs in the platform document, not in a forked semantic
surface file.

Every versioned document updates `Last verified` and appends an immutable
Timeline row. Reference captures are evidence; they do not override the
canonical text.

## 7. Timeline

The history is append-only. Prior entries are not rewritten.

| Version | Date | Change | Impact |
|---|---|---|---|
| 1.0.0 | 2026-09-11 | Established the platform-independent catalog, stable surface IDs, and the shared state/accessibility contract. | iOS and Android can map native surfaces to one semantic surface definition without duplicating product behavior. |
| 1.1.0 | 2026-09-11 | Converted the catalog into an index and split every screen, sheet, wearable surface, and system surface into one canonical platform-independent Markdown description file. Clarified that this rule applies to documentation, not production source-file organization. | Each surface now has one unambiguous place for its layout and function while iOS and Android remain free to use native implementation structure. |

*End of Ripple screen and sheet catalog 1.1.0.*
