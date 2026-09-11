# Ripple Surface — Wear custom amount

**Stable surface ID:** `watch-custom-amount`  
**Surface contract version:** 1.0.0  
**Last verified:** 2026-09-11  
**Kind:** Wearable sheet  
**Localized name:** `Menge` / `Custom amount`

This is the canonical wearable custom amount contract.

## Purpose and user outcome

The user chooses one custom amount and confirms one local intake using a
rotary-first or equivalent adjustable input appropriate to a small surface.

## Entry and exit

The surface opens from Wear Today. Cancel/dismissal discards the draft. Confirm
calls `LogIntake` with source `watch` and returns to Wear Today after local
persistence.

## Layout and region order

1. Dismiss/back context.
2. Current amount and unit.
3. Adjustable amount input with minimum, maximum, and step.
4. Optional compact container selection when space permits.
5. Confirm action.

The amount remains the primary input. The full phone container catalog is not
required to appear at once.

## Read model

Read the wearable `TodaySnapshot`, preferred unit, valid amount range, and a
compact ordered container projection.

## Actions and domain operations

Input changes a local draft only. Confirm calls `LogIntake`; cancellation
performs no mutation.

## States

The standard amount range is 50–2,000 ml in 10 ml steps. Invalid or unresolved
values disable confirmation and state the range. Offline local persistence
remains usable. Projection failure does not roll back a stored log. Reduced
motion removes decorative transitions.

## Validation and destructive behavior

The amount must be positive and within the supported range. Cancel is
non-destructive; no delete action exists on this surface.

## Accessibility and large text

Announce current value, unit, minimum, maximum, selected container, and confirm
result. Crown/rotary, touch, voice, and assistive adjustment alternatives use
the platform's standard affordances. Content may page or scroll in a native
compact manner only when it preserves access to Confirm.

## Design tokens and reusable elements

Use wearable amount, action, selection, sheet, type, spacing, and feedback
contracts from [`../Ripple_DESIGN_SYSTEM.md`](../Ripple_DESIGN_SYSTEM.md).

## Responsive/platform-independent behavior

The surface may page or reflow for wearable size, but the amount remains above
selection and Confirm remains discoverable.

## Forbidden behavior

- Requiring a phone keyboard.
- Requiring phone-sized all-container selection.
- Logging while only adjusting the draft.
- A separate wearable persistence or amount-resolution path.

## Related contracts

- [`../Ripple_PRD.md`](../Ripple_PRD.md)
- [`../Ripple_SCREEN_CATALOG.md`](../Ripple_SCREEN_CATALOG.md)
- [`../Ripple_DESIGN_SYSTEM.md`](../Ripple_DESIGN_SYSTEM.md)
- [`../Ripple_DATA_MODEL.md`](../Ripple_DATA_MODEL.md)
- [`watch-today.md`](watch-today.md)
