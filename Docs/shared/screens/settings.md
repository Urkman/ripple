# Ripple Surface — Settings

**Stable surface ID:** `settings`  
**Surface contract version:** 1.0.0  
**Last verified:** 2026-09-11  
**Kind:** Root screen  
**Localized name:** `Einstellungen` / `Settings`

This is the canonical description of configuration and account-independent
app settings.

## Purpose and user outcome

The user can configure the daily goal, ordered containers, reminders, profile
and unit preferences, optional health/notification access, sync visibility, and
data export. Each setting explains its scope and persists through a named
domain operation.

## Entry and exit

Settings opens from root navigation. Groups remain on Settings unless the
platform opens a dedicated child surface. Returning from a child surface
refreshes the affected group without surprising navigation or duplicate
mutations.

## Layout and region order

Present grouped regions in this semantic order, adapting the exact grouping to
the platform's settings conventions:

1. Profile and preferred unit.
2. Daily goal and calculation mode.
3. Containers.
4. Reminders.
5. Health permissions/projections.
6. Notification and synchronization status.
7. Data export.
8. About/support and version information.

The Containers region shows the complete ordered collection. Each row includes
icon, localized name, amount, default indicator when applicable, reorder
affordance, and edit affordance. Direct drag/reorder interaction changes the
persisted order; it is not a visual-only sort.

## Read model

Render `Profile`, `GoalSettings`, ordered `[Container]`, `ReminderRule`,
permission statuses, `SyncStatus`, locale/unit settings, and export
availability. Container order comes from persisted `sort`. The effective
default is at most one container and is represented by the container model,
not by a second preferences store.

## Actions and domain operations

| User action | Operation | Result |
|---|---|---|
| Edit goal/mode | `UpdateGoal` or `CalculateGoal` | Persist the goal and update displayed daily target. |
| Add/edit a container | Open [`add-container.md`](add-container.md) or [`edit-container.md`](edit-container.md), then `UpsertContainer` | Refresh the complete ordered collection. |
| Reorder containers | `UpsertContainer` or the repository's normalized reorder command | Persist normalized `sort`, announce the new position, and keep the same IDs. |
| Select default | `UpsertContainer` | Atomically clear the previous effective default and set the selected one. |
| Delete a container | `DeleteContainer` after explicit confirmation | Apply the documented fallback while preserving historical intake identity/metadata. |
| Edit reminders | Open [`edit-reminder.md`](edit-reminder.md), then `RescheduleReminders` | Persist rule and update notification status. |
| Request permission | Relevant request use case | Invoke platform permission flow; denial does not block local logging. |
| Export data | `ExportData` | Produce the versioned export and open the platform share/save flow. |
| Edit profile/unit | `UpdateProfile` | Persist profile preferences and refresh dependent displays. |

## States

- **Loading:** Keep group headings and per-group shells stable.
- **Ready:** Show all configured values and the complete container order.
- **No containers:** Offer Add container and keep the setting usable.
- **Permission unknown:** Explain purpose and offer request.
- **Permission denied:** Explain consequence and offer the platform settings
  route; never disable local intake logging.
- **Offline/sync unavailable:** Show inline status; local settings remain
  usable when the domain store is available.
- **Mutation error:** Retain the previous value or draft and offer retry.
- **Success:** Update the affected row and show layout-neutral feedback.

## Validation and destructive behavior

There may be zero or more containers, but there is never more than one
effective default. Reordering preserves stable IDs. Deleting a container does
not rewrite historical intakes; the data model's fallback/retention rule is
shown before confirmation. All writes go through their named use cases; views
do not write persistence directly.

## Accessibility and large text

Group headings are announced. A container row exposes name, icon meaning,
amount, order, default status, and edit/delete actions. Reordering announces
the new position. Selecting a new default explains that the previous marker
will be removed. Destructive delete states its effect on historical entries.
Large text may make groups taller or move controls below labels but may not
silently truncate the ordered collection.

## Design tokens and reusable elements

Use `GlassCard`, `GlassCardRow`, container row/chip elements,
`SyncStatusView`, `EmptyState`, and `RippleToast`. Use native settings controls
for text, slider, toggle, picker, reorder, permission, confirmation, and export
behavior, wrapped only with Ripple tokens and semantics from
[`../Ripple_DESIGN_SYSTEM.md`](../Ripple_DESIGN_SYSTEM.md).

## Responsive/platform-independent behavior

Compact layouts stack groups. Regular or expanded layouts may use columns or a
persistent settings detail region. Reordering remains possible through touch,
pointer, keyboard, or the platform equivalent. The complete container list is
never silently truncated.

## Forbidden behavior

- A checkmark with no documented default meaning.
- Multiple effective defaults or a default stored only in transient settings.
- A visual-only reorder that is not persisted.
- A second source of truth in user preferences storage.
- Direct persistence writes from a view.
- A container list that hides available containers without an explicit action.

## Related contracts

- [`../Ripple_PRD.md`](../Ripple_PRD.md)
- [`../Ripple_SCREEN_CATALOG.md`](../Ripple_SCREEN_CATALOG.md)
- [`../Ripple_DESIGN_SYSTEM.md`](../Ripple_DESIGN_SYSTEM.md)
- [`../Ripple_DATA_MODEL.md`](../Ripple_DATA_MODEL.md)
- [`add-container.md`](add-container.md)
- [`edit-container.md`](edit-container.md)
- [`edit-reminder.md`](edit-reminder.md)
