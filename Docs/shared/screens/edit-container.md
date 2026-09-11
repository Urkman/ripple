# Ripple Surface — Edit container

**Stable surface ID:** `edit-container`  
**Surface contract version:** 1.0.0  
**Last verified:** 2026-09-11  
**Kind:** Sheet  
**Localized name:** `Behälter bearbeiten` / `Edit container`

This is the canonical description of changing an existing saved container.

## Purpose and user outcome

The user changes the existing container's name, icon, amount, or default
status while preserving its stable identity and historical references.

## Entry and exit

The sheet opens from a Settings container row. Cancel/back/dismissal returns
unchanged. Save calls `UpsertContainer` with the same stable ID. Delete is a
separate, explicit destructive action with confirmation and is not triggered by
Save.

## Layout and region order

Use the same semantic order as [`add-container.md`](add-container.md),
prepopulated with current values:

1. Dismiss/cancel and title identifying the container.
2. Name field.
3. Horizontal icon-only selection.
4. Amount readout and slider.
5. Default-container control.
6. Inline validation.
7. Save action.
8. Separated destructive Delete action.

The current icon and default state are visible on entry. The sheet does not
silently remove a container because its default control is off.

## Read model and draft

Read the selected `Container`, all containers for default/order validation, the
icon catalog, preferred unit, locale, and historical-reference policy. The
draft retains the selected stable ID and changes only editable fields.

## Actions and domain operations

| User action | Operation | Result |
|---|---|---|
| Edit name/icon/amount/default | Local draft update | Update preview and validation without persistence. |
| Save | `UpsertContainer` | Update the same container identity, normalize order/default, refresh Settings, and dismiss. |
| Delete | `DeleteContainer` after explicit confirmation | Apply documented fallback/retention behavior, return to Settings, and refresh the ordered collection. |
| Cancel/dismiss | None | Discard the draft. |

## States

- **Loading:** Keep title and identity context while values resolve.
- **Ready:** Show current values and selected icon/default state.
- **Invalid:** Disable Save and identify the exact correction.
- **Delete confirmation:** State impact on existing intake history and
  fallback/default behavior.
- **Delete/save error:** Keep the editor open and retain the draft.
- **Success:** Return to Settings with order/default state refreshed.
- **Reduced motion:** Remove decorative transitions.

## Validation and destructive behavior

Use the same name and amount rules as Add container. Changing default
atomically clears the old default. Deleting a container never rewrites
historical intakes; it follows the data model's stable-ID/display-retention
policy. Container deletion is not part of intake undo.

## Accessibility and large text

The selected icon, amount, and default status are announced. Delete is clearly
separated, destructive, and explicit about consequences. Save announces that
it updates the existing container. Large text may increase sheet height but
must keep Save and Delete discoverable in order.

## Design tokens and reusable elements

Use exactly the Add container contract: `ContainerSymbolPicker`, native text
entry, slider, toggle, `GlassCard`, shared actions, and tokens from
[`../Ripple_DESIGN_SYSTEM.md`](../Ripple_DESIGN_SYSTEM.md). Do not create an
editor-only visual language.

## Responsive/platform-independent behavior

Fields may reflow vertically or into wider regions, but identity → editable
values → validation → Save → Delete remains the semantic order. The platform's
native confirmation and dismissal affordances are retained.

## Forbidden behavior

- Creating a replacement container instead of updating the same ID.
- Changing historical intake values when a container changes.
- Deleting on a non-explicit gesture.
- A separate icon/token system from Add container.
- Allowing two effective defaults.

## Related contracts

- [`../Ripple_PRD.md`](../Ripple_PRD.md)
- [`../Ripple_SCREEN_CATALOG.md`](../Ripple_SCREEN_CATALOG.md)
- [`../Ripple_DESIGN_SYSTEM.md`](../Ripple_DESIGN_SYSTEM.md)
- [`../Ripple_DATA_MODEL.md`](../Ripple_DATA_MODEL.md)
- [`settings.md`](settings.md)
- [`add-container.md`](add-container.md)
