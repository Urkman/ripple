# Ripple Surface — Share/export

**Stable surface ID:** `share-export`  
**Surface contract version:** 1.0.0  
**Last verified:** 2026-09-11  
**Kind:** System surface  
**Localized name:** Platform-local share/export copy

This is the canonical contract for exporting Ripple data through the operating
system's file/share flow.

## Purpose and user outcome

The user receives a complete, versioned export of the permitted Ripple data and
can save or share it using the system's native destination picker.

## Entry and exit

Export starts from Settings or an equivalent system entry. `ExportData` builds
the payload; after successful creation the system-owned share/save flow opens.
Cancel returns without domain mutation. Export errors retain Settings context
and offer retry.

## Layout and region order

1. Export description and scope.
2. Preparation/progress or error status.
3. Primary system share/save action.
4. Cancel/dismissal owned by the system.

## Read model

The export contains the documented profile, goals, containers, reminders, and
intake rows, including soft-deleted state where required for reconciliation.
It is versioned, localized where user-facing labels are included, and uses
integer milliliters as the canonical amount. The public contract never exposes
raw database files or internal storage schema.

## Actions and domain operations

`ExportData` builds the versioned payload; successful preparation opens the
system-owned share/save flow. Cancel performs no domain mutation.

## States

Loading explains that export is being prepared. Ready offers the system share/
save action. Empty data still produces a valid versioned payload. Error states
identify preparation or destination failure and offer retry. No permission or
sync projection failure may silently alter the payload's domain truth.

## Validation and destructive behavior

The payload must be complete, versioned, and valid for the export schema. The
surface has no destructive action and never deletes data during export.

## Accessibility and large text

The action announces what will be exported, file format/version, and result.
The system owns destination selection, share targets, cancellation, and file
permissions. Ripple supplies localized filename, description, and semantic
status.

## Design tokens and reusable elements

Use Settings action, status, copy, type, and accessibility contracts from
[`../Ripple_DESIGN_SYSTEM.md`](../Ripple_DESIGN_SYSTEM.md). Forbidden: deleting
## Responsive/platform-independent behavior

The system may present a centered, side-aligned, or host-specific destination
flow; export scope → status → share/save remains the semantic order.

## Forbidden behavior

Deleting data during export, exposing raw store files, inventing a second
export format without versioning, or replacing the native destination flow
with a fake app screen is forbidden.

## Related contracts

- [`../Ripple_PRD.md`](../Ripple_PRD.md)
- [`../Ripple_SCREEN_CATALOG.md`](../Ripple_SCREEN_CATALOG.md)
- [`../Ripple_DESIGN_SYSTEM.md`](../Ripple_DESIGN_SYSTEM.md)
- [`../Ripple_DATA_MODEL.md`](../Ripple_DATA_MODEL.md)
- [`settings.md`](settings.md)
