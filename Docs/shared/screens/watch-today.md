# Ripple Surface — Wear Today

**Stable surface ID:** `watch-today`  
**Surface contract version:** 1.0.0  
**Last verified:** 2026-09-11  
**Kind:** Wearable root screen  
**Localized name:** `Heute` / `Today`

This is the canonical wearable Today contract. It preserves the domain outcome
of Today while using compact wearable navigation and input.

## Purpose and user outcome

The user sees current hydration level and logs a predefined or custom amount
with minimal interaction while away from the phone.

## Entry and exit

Wearable navigation opens this surface as the Today page. Predefined logging
completes in place. Custom amount opens [`watch-custom-amount.md`](watch-custom-amount.md).
History and Stats are sibling wearable pages. A supported transient feedback
surface may offer undo through `UndoLastIntake`.

## Layout and region order

1. Full-canvas contained water-level field.
2. Compact consumed/remaining, goal, percentage, and unit readout.
3. Predefined amount actions from the ordered container projection.
4. Custom amount action.
5. Transient confirmation/undo feedback.

The water field is a static idle surface with a readable level. It is not a
phone hero compressed into a smaller rectangle.

## Read model

Read `TodaySnapshot`, ordered containers, preferred unit, and sync status.

## Actions and domain operations

Predefined and custom logging call `LogIntake` with source `watch` through the
same domain boundary as the main app. Undo calls `UndoLastIntake` when the
wearable surface supports it. No wearable-specific amount logic may diverge.

## States

- Empty, ready, goal, over-goal, offline, and success follow [`today.md`](today.md).
- Permission is never required for a local log.
- Unavailable sync is visible but does not remove local logging.
- Reduced motion removes water motion and uses a level cross-fade.

## Validation and destructive behavior

Every predefined amount must be positive and resolved from the ordered
container projection. Undo is limited to the latest eligible own intake.

## Accessibility and large text

Every action announces amount, unit, container, source, and result. The level
announces consumed amount, goal, remaining, percentage, and goal status. The
available touch, crown/rotary, voice, and assistive input paths remain usable.

## Design tokens and reusable elements

Use wearable variants of the shared water, log, amount, day, toast, type,
spacing, and motion contracts in [`../Ripple_DESIGN_SYSTEM.md`](../Ripple_DESIGN_SYSTEM.md).

## Responsive/platform-independent behavior

The platform may change page chrome, hit targets, and input order for wearable
ergonomics, but not the logging outcome.

## Forbidden behavior

- Phone tab chrome or phone-sized hero geometry.
- A month calendar or Stats chart on this page.
- A scroll-heavy quick-add region.
- An idle wave loop, pour stream in a system surface, or projection-only log.
- A second `LogIntake` implementation.

## Related contracts

- [`../Ripple_PRD.md`](../Ripple_PRD.md)
- [`../Ripple_SCREEN_CATALOG.md`](../Ripple_SCREEN_CATALOG.md)
- [`../Ripple_DESIGN_SYSTEM.md`](../Ripple_DESIGN_SYSTEM.md)
- [`../Ripple_DATA_MODEL.md`](../Ripple_DATA_MODEL.md)
- [`today.md`](today.md)
- [`watch-custom-amount.md`](watch-custom-amount.md)
