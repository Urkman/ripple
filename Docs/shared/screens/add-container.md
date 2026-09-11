# Ripple Surface — Add container

**Stable surface ID:** `add-container`  
**Surface contract version:** 1.0.0  
**Last verified:** 2026-09-11  
**Kind:** Sheet  
**Localized name:** `Behälter hinzufügen` / `Add container`

This is the canonical description of creating a saved container.

## Purpose and user outcome

The user creates a named, sized, icon-bearing container that can be used by
Today quick actions and the complete custom amount selection. The user may
also make it the one effective default.

## Entry and exit

Add container opens from the Containers region in Settings. Cancel, back, or
dismissal discards the draft. Save validates and calls `UpsertContainer`; a
successful save returns to Settings with the new container in persisted order.

## Layout and region order

1. Dismiss/cancel action and localized title.
2. Name field.
3. Horizontal icon selection showing icons only, without visible icon names.
4. Amount label and numeric readout.
5. Continuous amount slider.
6. Default-container control.
7. Inline validation.
8. Primary Save action.

The icon picker is a visual horizontal stack/selector; its semantic labels are
still available to assistive technology. The amount slider replaces a stepper
and is the direct amount control.

## Read model and draft

Read existing container names/order, the available icon identifiers, preferred
unit, amount bounds, locale, and current effective-default state. The local
draft contains a new stable ID candidate, trimmed name, icon identifier,
integer amount, and default intent. No field writes persistence before Save.

## Actions and domain operations

| User action | Operation | Result |
|---|---|---|
| Edit name | Local draft update | Trim/validate without persistence. |
| Select icon | Local draft update | Update selected icon; visible options remain icon-only. |
| Move amount slider | Local draft update | Update readout in display unit; convert deterministically on save. |
| Toggle default | Local draft update | Mark the new container as intended default; enforce one-default at save. |
| Save | `UpsertContainer` | Create the container, normalize order, clear prior default if required, and return to Settings. |
| Cancel/dismiss | None | Discard all draft fields. |

## States

- **Ready:** Start with valid localized defaults and a clear Save action.
- **Invalid name:** Explain that the trimmed name is empty or too long.
- **Invalid amount:** Explain the allowed range and keep Save disabled.
- **Icon unavailable:** Never show empty unlabeled targets; retain a valid
  fallback icon or block with explanation.
- **Persistence error:** Keep the draft and offer retry.
- **Success:** Return to Settings and expose the new order/default state.
- **Reduced motion:** Avoid decorative picker movement.

## Validation and destructive behavior

Names are non-empty after trimming and obey the documented maximum length.
Amounts are integer milliliters after conversion, within 50–2,000 ml in 10 ml
steps. Enabling default clears the former effective default atomically when
the use case persists. Cancel is non-destructive.

## Accessibility and large text

Icon-only options announce their icon meaning, selected state, and position.
The amount slider announces minimum, maximum, current value, and unit. The
default control explains that it is one of many possible defaults. Save
announces the new container name and amount. Large text may increase sheet
height and wrap labels but may not push Save into an unlabeled overflow.

## Design tokens and reusable elements

Use `ContainerSymbolPicker`, native text entry, native slider, native toggle,
`GlassCard`, and shared primary/secondary action tokens. The icon picker,
fields, sheet surface, type, spacing, colors, and motion come from
[`../Ripple_DESIGN_SYSTEM.md`](../Ripple_DESIGN_SYSTEM.md).

## Responsive/platform-independent behavior

The icon options may wrap or use a platform-native horizontal selector when
space is constrained, but visible choices remain icon-only. The sheet may grow
for large text. Name → icon → amount → default → validation → Save remains the
semantic order.

## Forbidden behavior

- Icon names as the visible selection UI.
- A stepper as the only amount control.
- Saving before the primary Save action.
- A default flag that permits two effective defaults.
- A feature-local icon, color, or spacing system.

## Related contracts

- [`../Ripple_PRD.md`](../Ripple_PRD.md)
- [`../Ripple_SCREEN_CATALOG.md`](../Ripple_SCREEN_CATALOG.md)
- [`../Ripple_DESIGN_SYSTEM.md`](../Ripple_DESIGN_SYSTEM.md)
- [`../Ripple_DATA_MODEL.md`](../Ripple_DATA_MODEL.md)
- [`settings.md`](settings.md)
- [`edit-container.md`](edit-container.md)
