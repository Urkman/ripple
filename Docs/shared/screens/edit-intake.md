# Ripple Surface — Edit intake

**Stable surface ID:** `edit-intake`  
**Surface contract version:** 1.0.0  
**Last verified:** 2026-09-11  
**Kind:** Sheet  
**Localized name:** `Eintrag bearbeiten` / `Edit intake`

This is the canonical description of editing one existing intake.

## Purpose and user outcome

The user can correct the amount or permitted metadata of one existing intake
without creating a second intake or changing the selected day implicitly.

## Entry and exit

The sheet opens from an intake row in Day Detail. Cancel, back, or dismissal
returns unchanged. Save calls `EditIntake` and returns to Day Detail after
successful persistence. Delete belongs to Day Detail, not this sheet.

## Layout and region order

1. Selected date/time and entry context.
2. Amount control and current amount readout.
3. Optional supported container, beverage, or note fields.
4. Inline validation message when required.
5. Cancel and primary Save actions.

Labels precede values. The original entry identity and relevant context remain
visible while the draft is edited.

## Read model and draft

Read the selected `Intake`, available containers, preferred unit, locale, and
the allowed editable fields. Maintain a local draft separate from persistence.
The draft carries the original stable intake ID and may not silently change its
date or source unless the product contract explicitly permits that field.

## Actions and domain operations

| User action | Operation | Result |
|---|---|---|
| Adjust an editable field | Local draft update | Update the readout and validation state without writing. |
| Save valid draft | `EditIntake` | Update the original row, refresh the Day Detail total, and dismiss. |
| Cancel/dismiss | None | Discard the draft and leave the original intake unchanged. |
| Retry a failed save | `EditIntake` again | Preserve the draft and report the new result. |

## States

- **Loading:** Keep the selected entry context visible while fields resolve.
- **Ready:** Show the original values and enabled editable controls.
- **Invalid:** Keep Save disabled and explain the exact correction required.
- **Offline/sync unavailable:** Permit local persistence if the domain store is
  available; report projection status separately.
- **Error:** Retain the unsaved draft and offer retry.
- **Success:** Update Day Detail and dismiss without a duplicate row.
- **Reduced motion:** Avoid decorative sheet transitions.

## Validation and destructive behavior

Amounts must be positive integer milliliters after deterministic conversion.
Text and metadata follow the data model's allowed ranges. Save updates the
original identity and timestamps according to the use case. Cancel is
non-destructive; deleting is not available here.

## Accessibility and large text

The amount control announces current value and unit. Every field has a clear
label, validation text is associated with its field, and Save announces that it
updates an existing entry. Focus begins at the context/title and ends at the
primary action. Large text may grow the sheet but must not hide Save.

## Design tokens and reusable elements

Use the same amount-control, field, card, type, spacing, and native-control
tokens as [`custom-amount.md`](custom-amount.md), with `RippleToast` only for
the resulting status where needed. Do not create an editor-only visual system.

## Responsive/platform-independent behavior

The surface may be a bottom-attached, centered, or side-aligned modal. Fields
may reflow vertically on compact displays and use a wider two-region layout on
expanded displays while preserving context → fields → validation → actions.

## Forbidden behavior

- Saving by inserting a new intake.
- Mutating persistence while merely changing a draft control.
- Hiding the original date/time context.
- Deleting from this sheet without the Day Detail destructive contract.
- Using a projection as the source of the editable value.

## Related contracts

- [`../Ripple_PRD.md`](../Ripple_PRD.md)
- [`../Ripple_SCREEN_CATALOG.md`](../Ripple_SCREEN_CATALOG.md)
- [`../Ripple_DESIGN_SYSTEM.md`](../Ripple_DESIGN_SYSTEM.md)
- [`../Ripple_DATA_MODEL.md`](../Ripple_DATA_MODEL.md)
- [`day-detail.md`](day-detail.md)
