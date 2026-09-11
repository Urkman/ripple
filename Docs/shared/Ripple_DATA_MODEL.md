# Ripple Data Model and Persistence Contract

**Document type:** Shared domain, storage, synchronization, and projection
contract  
**Version:** 1.0.0 — 11 September 2026  
**Last verified:** 2026-09-11  
**Status:** Normative companion to [`Ripple_PRD.md`](Ripple_PRD.md)

This document defines the values Ripple owns, how they are validated, how they
are stored, and how screens receive read models. It deliberately separates
platform-independent domain semantics from iOS SwiftData records and Android
Room records.

The [PRD](Ripple_PRD.md) remains the product source of truth. Surface IDs and
canonical per-surface descriptions are indexed by
[`Ripple_SCREEN_CATALOG.md`](Ripple_SCREEN_CATALOG.md) and stored in
[`screens/`](screens/). Visual roles are in
[`Ripple_DESIGN_SYSTEM.md`](Ripple_DESIGN_SYSTEM.md), and platform mapping is
in [`IOS_ARCHITECTURE.md`](IOS_ARCHITECTURE.md) and
[`Android/ANDROID_ARCHITECTURE.md`](Android/ANDROID_ARCHITECTURE.md).

## 1. Ownership and source-of-truth rules

The local SwiftData/Room store is the source of truth for Ripple-owned
hydration data. Cloud sync and wearable transport replicate that data; they do
not become a second authority. HealthKit/Health Connect, widgets, reminders,
notifications, Watch/Wear surfaces, controls/tiles, and shortcuts are
projections or clients.

The domain layer owns values, invariants, use cases, and ports. The data layer
owns storage records, mapping, transactions, CloudKit/Health projections,
notifications, and reload scheduling. Features read snapshots and invoke
use cases; they do not write storage, mutate query results, or call health APIs
directly.

The one-store boundary is:

```text
surface/system entry
        -> feature/view model or platform adapter
        -> domain use case
        -> repository port
        -> ModelActor/Room transaction
        -> source-of-truth record
        -> projections and read snapshots
```

Every intake, regardless of entry point, uses the same `LogIntake` command.
There is no widget-specific, intent-specific, Watch-specific, or notification-
specific amount implementation.

## 2. Primitive and serialization rules

### 2.1 Identity

- User-owned entities use a stable UUID: `Intake.id` and `Container.id`.
- Identity survives edit, sync, export, and soft deletion.
- A retry with the same command ID/explicit intake ID must be idempotent at the
  repository boundary; it must not create duplicate intake rows.
- Derived snapshots use date/time identity only for presentation and never
  replace an entity UUID.

### 2.2 Amounts and units

- The canonical amount is a signed integer milliliter value at the domain
  boundary, with product validation requiring a positive amount for a stored
  intake or container.
- `Milliliters` wraps `Int` and provides comparison and arithmetic. It is not a
  floating-point storage type.
- `VolumeUnit` is a presentation preference with raw values `milliliters` and
  `fluidOunces`; its symbols are `ml` and `fl oz`.
- `UnitConverter` converts only at the UI/import/export boundary. Conversion
  uses the repository's deterministic rounding rule; the converted integer
  milliliters are what get validated and stored.
- The custom amount control accepts 50–2,000 ml in 10 ml steps in the current
  product contract. A localized fluid-ounce presentation still resolves to
  integer milliliters before a command is sent.
- Display formatting is locale-aware. Numeric values use monospaced/tabular
  digits where the design-system role requires stable visual width.

### 2.3 Dates and local days

- Stored `Date` values are absolute instants. A local calendar and time zone are
  supplied to derive a user-facing day.
- “Today” means the local calendar day at the surface's current time zone; it
  is not a fixed 24-hour UTC interval.
- History month/week/year bounds use the calendar supplied by the observing
  use case. ISO-week statistics use ISO week boundaries.
- Intake ordering is chronological by `date`, with a stable tie-breaker by
  `createdAt` and `id` where a view needs deterministic order.
- `ClockTime` stores hour/minute without a date and clamps hour to 0–23 and
  minute to 0–59. It is used only for daily reminder/wake/sleep rules.

### 2.4 Enumerations and optional values

- Persisted enums use stable lowercase raw strings, not localized display
  text: `Beverage`, `IntakeSource`, `VolumeUnit`, `GoalMode`, `ActivityLevel`,
  and notification authorization states.
- Unknown persisted enum values map to a safe documented fallback when reading;
  migrations may preserve the raw value for diagnostics.
- `nil` means “not supplied/unknown”, not zero, false, or an empty string.
- Optional `containerId` preserves the fact that an intake was logged without
  a known saved container. It must not be silently assigned to a new container
  during history rendering.
- Timestamps are absolute `Date`/instant values and are updated only by the
  owning use case or mapping transaction.

## 3. Domain entities and value types

### 3.1 `Intake`

One stored hydration event. It is the atomic unit for logging, editing,
deleting, restoring, undo, sync, and export.

| Field | Type | Required/default | Authority and rules | Storage |
|---|---|---|---|---|
| `id` | UUID | Required; generated at creation | Stable identity; may be supplied for idempotent retry. | `IntakeRecord.id`; Room primary key. |
| `date` | Instant | Required; command date or current instant | Determines local-day membership; may be edited by the explicit edit use case. | `IntakeRecord.date`. |
| `amountMl` | Int | Required; no implicit zero | Positive after command validation; integer milliliters. | `IntakeRecord.amountMl`. |
| `beverage` | `Beverage` | Required; `.water` | v1 supports water only; raw value is `water`. | `beverageRaw`. |
| `source` | `IntakeSource` | Required | Identifies entry point: app, widget, intent, watch, control, notification, health. It does not change amount logic. | `sourceRaw`. |
| `containerId` | UUID? | Optional; `nil` when unknown/custom | Historical reference; deleting a container does not rewrite old IDs. | `containerId` nullable. |
| `note` | String? | Optional; `nil` when empty | User note if the product surface supports it; trim/length policy is owned by edit validation. | `note` nullable. |
| `isDeleted` | Bool | Required; `false` | Soft-delete flag; deleted rows are excluded from normal totals but remain restorable/export-policy aware. | `isDeleted`. |
| `createdAt` | Instant | Required; creation instant | Immutable after creation except migration. | `createdAt`. |
| `updatedAt` | Instant | Required; creation instant | Set by create/edit/delete/restore transaction. | `updatedAt`. |

**Lifecycle:** `LogIntake` creates one row; `EditIntake` updates the same ID;
`DeleteIntake` sets `isDeleted`; `RestoreIntake` clears it; `UndoLastIntake`
soft-deletes the latest own eligible row. Projections run after the source
write and never roll it back on failure.

### 3.2 `Container`

A user-configurable amount preset and visual identity. It is not a beverage
record and does not retroactively change an intake.

| Field | Type | Required/default | Authority and rules | Storage |
|---|---|---|---|---|
| `id` | UUID | Required; generated for new container | Stable identity used by current/future intake references. | `ContainerRecord.id`; Room primary key. |
| `name` | String | Required; seeded `Glass`/`Glas` | Trimmed, non-empty, localized default only; user custom names remain user data. | `name`. |
| `amountMl` | Int | Required; seeded 250/200/500 | Positive; editor range 50–2,000 ml in 10 ml steps for current UI. | `amountMl`. |
| `isDefault` | Bool | Exactly one effective default when containers exist | Generic/default amount flows and initial selection use it. Today quick adds use order, not default status. | `isDefault`. |
| `sort` | Int | Required; zero-based normalized order | Lower values appear first; Settings reorder rewrites all affected positions in one logical update. | `sort`. |
| `symbolName` | String | Required; seeded symbol identifier | Stable platform symbol/icon identifier selected from the approved icon catalog; visible labels are localized separately. | `symbolName`. |
| `createdAt` | Instant | Required; creation instant | Immutable after creation except migration. | `createdAt`. |
| `updatedAt` | Instant | Required; creation instant | Updated on edit, reorder, default change, or migration. | `updatedAt`. |

**Container invariants:**

1. A container name is non-empty after trimming.
2. An amount is positive and within the editor's supported range.
3. IDs are unique and survive renaming/icon changes.
4. The effective display order is `sort` ascending, with deterministic UUID
   tie-breaking during repair.
5. If at least one container exists, exactly one is effective default. Setting
   one default clears every other default in the same use-case transaction.
6. Deleting the default promotes the first remaining container by order. If
   the last container is deleted, the empty state is explicit and a later seed
   or add operation creates a new default.
7. Deleting a container does not delete or rewrite historical intakes; old
   rows may display an unavailable/unknown container label.
8. Today selects `containers.sorted(sort).prefix(3)` for quick adds. Custom
   amount selection exposes every non-deleted saved container.

The seeded defaults are Glass 250 ml (default, order 0), Cup 200 ml (order 1),
and Bottle 500 ml (order 2), with locale-appropriate names and the documented
icon identifiers.

### 3.3 `Profile`

| Field | Type | Default | Rules/storage |
|---|---|---|---|
| `preferredUnit` | `VolumeUnit` | Metric locale: `.milliliters`; otherwise `.fluidOunces` | Presentation preference; raw string in `preferredUnitRaw`. |
| `bodyMassKg` | Double? | `nil` | Optional Health/profile input; positive when supplied; never source of hydration entries. |
| `activityLevel` | `ActivityLevel` | `.sedentary` | Raw values `sedentary`, `moderate`, `high`; goal calculation input only. |
| `wakeTime` | `ClockTime` | 07:00 | Daily reminder/goal context; stored as hour/minute. |
| `sleepTime` | `ClockTime` | 22:00 | Daily reminder/goal context; stored as hour/minute. |
| `remindersEnabled` | Bool | `true` | Enables scheduling after authorization; does not delete history. |
| `healthReadWorkoutsEnabled` | Bool | `false` | Permission/configuration preference; Health remains projection/input only. |
| `healthWriteEnabled` | Bool | `false` | User preference for writing projections; does not gate local logging. |
| `hapticsEnabled` | Bool | `true` | Presentation preference. |
| `onboardingCompleted` | Bool | `false` | Controls entry into onboarding; set only after required local setup is saved. |
| `updatedAt` | Instant | Creation/current instant | Updated by `UpdateProfile`. |

Storage is one `ProfileRecord`. Wake/sleep are flattened to hour/minute fields
for CloudKit/Room-safe persistence.

### 3.4 `GoalSettings` and goal values

`GoalMode` has raw values `manual` and `calculated`.

| Field | Type | Default/rules |
|---|---|---|
| `mode` | `GoalMode` | `.manual`; raw string `modeRaw`. |
| `manualGoalMl` | Int | 2,000 ml default; positive validated integer. |
| `updatedAt` | Instant | Set by `UpdateGoal`. |

`CalculateGoal` derives a `Milliliters` goal from profile inputs and workout
data according to the PRD formula. The calculated result is not a second
stored source of truth; `GoalSettings.mode` selects the formula. Daily totals
use the goal resolved for that local day.

### 3.5 `ReminderRule`

| Field | Type | Default/rules |
|---|---|---|
| `enabled` | Bool | `true`; scheduling preference. |
| `start` | `ClockTime` | 07:00; local daily window. |
| `end` | `ClockTime` | 22:00; local daily window. |
| `intervalMinutes` | Int | 120; positive scheduling interval. |
| `afterLastSipMinutes` | Int | 120; positive fallback interval. |
| `updatedAt` | Instant | Set by `RescheduleReminders`/settings update. |

Reminder scheduling is a projection. A notification authorization failure does
not alter the rule or the intake store.

### 3.6 Supporting enums and values

| Type | Values/fields | Persistence/status |
|---|---|---|
| `Milliliters` | `value: Int`; zero, comparison, addition, subtraction | Codable integer wrapper; no floating storage. |
| `VolumeUnit` | `milliliters`, `fluidOunces`; symbols `ml`, `fl oz` | Codable raw string. |
| `Beverage` | `water` in v1 | Codable raw string; no beverage factors in v1. |
| `IntakeSource` | `app`, `widget`, `intent`, `watch`, `control`, `notification`, `health` | Codable raw string; analytics/behavior must not fork by source. |
| `ActivityLevel` | `sedentary`, `moderate`, `high`; bonus 0/350/700 ml | Codable raw string; goal input only. |
| `Daypart` | morning 05–11, midday 11–14, afternoon 14–18, evening 18–05 | Codable raw string; derived stats bucket. |
| `ClockTime` | hour/minute | Codable value; clamps input to valid clock range. |
| `StatsPeriod` | week/month/year with anchor date | Transient command value; derives calendar bounds. |
| `HistoryRange` | day/week/month/recentDays(anchor,count) | Transient query value; not a record. |
| `NotificationAuthorizationStatus` | notDetermined, denied, authorized, provisional, ephemeral | External status; not source of truth. |
| `HealthAuthorizationStatus` | `waterWrite`, `workoutRead` booleans | External status; not source of truth. |
| `HealthOnboardingAccess` | optional body mass, water-write authorization | One authorization result; not hydration data. |
| `SyncStatus` | available, importing, failed(message), unavailable | Runtime status; not persisted as user domain data. |

## 4. Derived read models

Read models are immutable snapshots assembled by use cases from source records.
They are safe to pass to UI and system projections. They are not additional
stores and are not independently edited.

### 4.1 `TodaySnapshot`

| Field | Meaning |
|---|---|
| `date` | Current local-day anchor. |
| `consumed` | Sum of non-deleted water intakes in the local day. |
| `goal` | Resolved goal for that day. |
| `remaining` | `max(goal - consumed, 0)` for display; actual consumed remains available. |
| `percent` | Goal ratio for presentation; visual hero may cap at 1.0/defined max. |
| `entries` | Non-deleted local-day intakes in deterministic chronological order. |
| `unit` | Current preferred display unit. |
| `defaultAddMl` | Resolved fallback amount for generic/default logging. |
| `containers` | All available saved containers in persisted order. |
| `pacingMlPerHour` | Optional derived pacing value; never written as a log. |

`isEmpty` and `isGoalMet` are derived convenience values. `containers` is not
truncated in the snapshot; the Today surface selects the first three, while
Custom Amount selects all.

### 4.2 `HistorySnapshot`, `DayTotal`, and `DaySummary`

- `HistorySnapshot.range` identifies the requested range, `days` contains one
  `DayTotal` per calendar day, and `entries` contains the relevant non-deleted
  intakes.
- `DayTotal` contains `date`, `consumed`, and `goal`; its identity is derived
  from the date only for rendering.
- `DaySummary` contains `date`, `consumedMl`, `goalMl`, `entryCount`, and
  `hitGoal`; `progress` is `min(1, consumed/goal)` for the History ring.
- Future days remain present as zero/disabled categories where the product
  requires a calendar grid, but they are not tappable or counted as elapsed.

### 4.3 `StatsSnapshot`

`StatsSnapshot` contains `range: DateInterval`, daily `[DaySummary]`,
`byDaypart: [Daypart: Int]`, `byContainer: [UUID?: Int]`, optional `bestDay`,
and `currentHitRun`. It supports total, elapsed-day, hit-day, average,
empty-day, and weakest-day derived summaries. Stats uses source-of-truth
intakes and goals, not Health data or artificial empty bars.

### 4.4 `ExportPayload`

`ExportPayload` is transient output containing JSON data, CSV data, and
localized/suggested JSON/CSV file names. Export includes source-of-truth data
according to the documented deletion/export policy and never mutates records.

## 5. Storage mapping

### 5.1 iOS SwiftData schema

The current SwiftData schema contains exactly these record classes:

| Domain | Record | Notes |
|---|---|---|
| Intake | `IntakeRecord` | Flat fields; `beverageRaw` and `sourceRaw`; nullable `containerId` and `note`; soft delete. |
| Container | `ContainerRecord` | Flat fields; `sort`, `isDefault`, icon identifier, timestamps. |
| Profile | `ProfileRecord` | One logical record; enum raw values and flattened clock fields. |
| Goal | `GoalSettingsRecord` | One logical record; `modeRaw`, `manualGoalMl`, timestamp. |
| Reminder | `ReminderRuleRecord` | One logical record; flattened clock fields and intervals. |

`RippleSchema.models` registers these records in the one shared model
container. There are no SwiftData relationships required for current
CloudKit-safe behavior; `containerId` is an explicit stable reference.

Writes occur through the `@ModelActor` store/repositories. Views do not use a
query result as a mutation API. Extensions use the App Group/shared store and
fresh read contexts where another process may have written data.

### 5.2 Android Room schema

The Android implementation maps the same semantics to Room entities and
repositories:

| Domain | Room table guidance | Required columns |
|---|---|---|
| Intake | `intakes` | UUID primary key, instant/date, integer ml, beverage/source raw strings, nullable container UUID/note, deleted flag, created/updated instants. |
| Container | `containers` | UUID primary key, name, integer ml, default flag, normalized sort, icon ID, created/updated instants. |
| Profile | `profile` singleton | Unit/activity raw strings, optional body mass, flattened clock values, preferences, onboarding flag, updated instant. |
| Goal | `goal_settings` singleton | Mode raw string, integer manual goal, updated instant. |
| Reminder | `reminder_rule` singleton | Enabled, flattened start/end, intervals, updated instant. |

Room is Android local source of truth. DataStore may hold non-domain UI or
permission preferences only; it must not hold intakes, containers, goals, or a
second default. Repository transactions enforce the same container and intake
invariants as iOS.

### 5.3 CloudKit and sync constraints

- Use private database/App Group configuration already defined by the platform
  architecture; no shared public user data or account system is introduced.
- Records are flat, Codable-safe, and identified by stable UUIDs.
- Sync merges preserve the newest valid field values by the documented
  timestamp/conflict policy and then repair container order/default invariants.
- A conflict must not duplicate an intake by UUID or resurrect a soft-deleted
  row without an explicit restore operation.
- A sync/import failure produces `SyncStatus.failed` or `.unavailable`; it does
  not roll back a successfully stored local intake.
- Health projections are best effort. A Health failure is recorded as status or
  feedback, not as a failed domain write.

### 5.4 Phone/Wear synchronization

Wear transports versioned domain mutation envelopes and acknowledgements over
the platform Data Layer. An envelope includes operation/version, stable ID,
amount/date/source/container reference as required, and idempotency metadata.
The phone/source store remains authoritative; Wear local cache is used for
offline interaction and reconciles by stable ID. Merge and delete semantics
are the same as the main store.

## 6. Use-case and port contracts

Only domain use cases or read APIs call repositories. Screen files and system
adapters do not write records directly.

### 6.1 Write operations

| Use case | Input/result | Required behavior |
|---|---|---|
| `LogIntake` | amount, source, date, optional container ID/note/id; returns `Intake` | Validate/store one event, then project to widget/Health/reminders; never duplicate source logic or roll back on projection failure. |
| `UndoLastIntake` | no input; returns eligible intake or no result | Select latest own, non-deleted eligible row and soft-delete it. |
| `EditIntake` | intake ID and changed fields | Update same identity/timestamp; reject deleted/missing row. |
| `DeleteIntake` | intake ID | Set `isDeleted`, update timestamp, preserve history identity, offer restore/undo. |
| `RestoreIntake` | intake ID | Clear `isDeleted` for a valid deleted row and update timestamp. |
| `UpsertContainer` | complete `Container` | Validate name/amount/order; atomically enforce one default; save same ID on edit. |
| `DeleteContainer` | container ID | Remove from active container settings, preserve intake references, promote first remaining default when needed. |
| `UpdateGoal` | mode, optional manual goal, time | Validate positive goal and persist goal settings. |
| `UpdateProfile` | complete profile | Validate optional profile values and persist one profile record. |
| `RescheduleReminders` | current rule/time/last sip | Schedule/cancel projection; no domain log mutation. |
| `ExportData` | current time/policy | Produce JSON/CSV payload without mutation. |

### 6.2 Read operations

| Use case | Output |
|---|---|
| `ObserveToday` | `TodaySnapshot` for local day. |
| `ObserveMonth`/`ObserveHistory` | `HistorySnapshot` for requested range. |
| `ObserveStats` | `StatsSnapshot` for week/month/year interval. |
| `CalculateGoal` | Derived `Milliliters` goal from profile/workout inputs. |
| Settings repository reads | Profile, goal, ordered containers, reminder, sync status. |

### 6.3 External authorization/projection ports

`RequestHealthOnboardingAccess`, `RequestHealthReadAccess`,
`RequestHealthWaterWrite`, and `RequestNotificationAuthorization` return
authorization/status values. They do not become a data source and do not block
`LogIntake`.

## 7. Validation and migration rules

### 7.1 Validation boundaries

- Screens validate drafts for immediate feedback; use cases validate again at
  the domain boundary.
- Names are trimmed, non-empty, localized labels are separate from stored
  custom names, and maximum length is enforced consistently on both platforms.
- Amounts are positive integer milliliters. The current container/custom UI
  range is 50–2,000 ml with a 10 ml step; imported data outside the UI range is
  either rejected with a migration error or preserved under an explicit
  compatibility policy, never silently rounded to zero.
- Dates are valid instants; local-day queries always receive a calendar/time
  zone rather than assuming UTC.
- Enum raw values are validated with safe fallback and diagnostics.
- Container order is normalized after reorder/import/merge. Default repair is
  deterministic by order.

### 7.2 Soft deletion and restoration

Soft delete is mandatory for intakes. Normal observations exclude
`isDeleted == true`; restore explicitly re-includes the same intake. Container
deletion is a settings operation, not intake deletion; historical IDs remain
available for export/audit display. No hard wipe is allowed without a user-
initiated export/recovery path.

### 7.3 Migration

Storage schema migrations preserve UUIDs, absolute timestamps, integer amounts,
raw enum values, soft-delete flags, and container references. A migration that
finds multiple defaults selects the lowest valid `sort` and clears the rest; a
missing default selects the first active container. A migration that finds
duplicate intake IDs must stop and report a recoverable error rather than
silently merging user events.

## 8. Data-model acceptance tests

Every implementation provides tests for:

- integer milliliter arithmetic and deterministic unit conversion;
- local-day boundaries across time zones and daylight-saving transitions;
- positive amount/name validation and custom UI range conversion;
- container ordering, one-default repair, deletion fallback, and historical
  `containerId` preservation;
- `LogIntake` one-row semantics from every source and projection failure
  without rollback;
- edit/delete/restore/undo identity and timestamps;
- goal formula and manual/calculated mode;
- History future-day exclusion, capped progress, and empty periods;
- Stats aggregation by daypart/container and no artificial empty data;
- SwiftData/Room mapping round trips and raw enum fallback;
- export excluding or representing soft-deleted data according to policy;
- idempotent phone/Wear and Cloud sync envelopes.

## 9. Maintenance and timeline

Update this document in the same change when a domain field, default, invariant,
storage record, sync envelope, projection, use case, validation rule, unit/date
rule, or snapshot changes. Update the PRD for the corresponding product
behavior and the platform architecture documents for storage/API mapping.
Prior timeline entries are immutable.

| Version | Date | Change | Impact |
|---|---|---|---|
| 1.0.0 | 2026-09-11 | Established the shared domain field contract, container/default/order rules, intake lifecycle, SwiftData/Room mapping, use-case boundary, and projection policy. | iOS and Android can implement compatible source-of-truth storage and read models without copying platform annotations into the domain. |

*End of Ripple data model 1.0.0.*
