# Ripple Android Architecture and Implementation Guide

**Status:** Approved design for implementation

**Last verified:** 2026-09-08

**Platform scope:** Android phones, tablets/foldables, Android home-screen/system surfaces, and Wear OS
**Out of scope:** iOS/Android data sharing, macOS, tvOS, and visionOS

**Document version:** 1.3.1

**Companion document:** [Ripple Architecture](../ARCHITECTURE.md)

**UI companion:** [Ripple Android UI Specification](ANDROID_UI_SPEC.md)

This document is the implementation contract for an Android version of Ripple. It defines the functionality that must exist, the Android architecture that should contain it, the platform-native UI behavior, and the verification required before release.

The Android app is a separate product implementation. It must preserve the
current iOS product screens, information hierarchy, and user flows while
looking and behaving like a well-designed Android app. It must not copy iOS
navigation chrome, controls, typography, glass treatment, or platform-specific
presentation merely to achieve functional parity.

The existing iOS architecture is described in [`Docs/ARCHITECTURE.md`](../ARCHITECTURE.md). Android screen composition and state behavior are specified in [`Docs/Android/ANDROID_UI_SPEC.md`](ANDROID_UI_SPEC.md). Product behavior is specified by the [Ripple PRD](../../Ripple_Handoff/Ripple_PRD.md), [hero motion specification](../../Ripple_Handoff/Ripple_Hero_Motion.md), and [History/Stats specification](../../Ripple_Handoff/Ripple_History_Stats.md). Where this document says “parity,” it means equivalent capability and domain result, not identical pixels or gestures.

## 1. Product boundary and non-negotiable rules

### 1.1 Data boundary

Android and iOS do not share data. There is no CloudKit dependency, iCloud account flow, cross-platform import, cross-platform export protocol, or shared backend contract in this Android port.

Android owns its own local data store:

```text
Android phone/tablet Room database  <---->  Android widgets/system surfaces
                 ^
                 |
       Wear Data Layer replication
                 |
        Wear OS local Room database
```

The phone and Wear OS app share Android-side data only through an explicit, versioned Wear Data Layer protocol. Neither device opens the other device's database.

Android Auto Backup and device-to-device transfer may restore Android data when the user moves to another Android device. That is backup/restore, not live synchronization. Live Android-to-Android sync is not part of this port.

### 1.2 Functional invariants

- Every intake is created through one `LogIntake` use case.
- Amounts are integer milliliters inside the domain and database.
- Health Connect is a projection, never the source of truth.
- A Health Connect failure never rolls back a saved intake.
- Undo means the last own, non-deleted intake.
- Deletion is a soft delete; restore and export remain possible.
- All platform entry points use the same use cases as the main app.
- Widgets and Wear OS can work from local data while offline.
- The app supports German and English, TalkBack, large text, dark mode, and reduced motion.
- The Android UI uses Android conventions even when the domain model matches iOS.
- No TV, visionOS, macOS, plants, social features, streak product, or beverage-factor scope is added.

## 2. Capability parity matrix

The agent must implement the following Android capabilities. The right-hand column describes what must remain equivalent; the Android presentation is intentionally different.

| iOS capability | Android implementation | Required behavior |
| --- | --- | --- |
| Today | Compose Today destination with Android `Scaffold`, contained water hero, saved-container quick-add controls, custom amount action, and remaining label | Log, undo, goal progress, pacing, confirmation, errors, and empty states behave equivalently; Today has no Recent/last-entry list |
| Hero water level | Custom Compose `Canvas`/path rendering | Water level, pour series, containment, zero state, reduced motion, and no-overshoot rules remain; the container and controls are Android-native |
| Quick logging | Material buttons/chips/FAB and system entry points | Every tap creates its own intake row through `LogIntake` |
| History | Adaptive horizontal month calendar and Android list/detail navigation | One ring per day, future days disabled, tap opens Day Detail, edit/delete/restore, add only today |
| Stats | Android-native period selector and custom accessible Compose charts | Week/month/year, summary row, actual-vs-goal, hit-rate, day-part, container charts, highlights, and empty states |
| Settings | Material list sections, switches, dialogs, permission rows, system settings links | Profile, units/activity, daily goal, containers, reminders, Health Connect, sync, export, about, and onboarding reset |
| Onboarding | Six-step Android back-aware Compose flow and native permission contracts | Welcome, units, Health Connect, goal, containers, reminders, and completion state |
| HealthKit projection | Health Connect adapter | Write hydration; optionally read weight and exercise; permissions can be revoked; failure does not erase Ripple data |
| Notifications/reminders | Notification channels, `AlarmManager` for reminder timing, WorkManager for durable projection/retry work | Wake/sleep bounds, replaceable next reminder, default log action, permission-aware scheduling |
| iOS widgets | Jetpack Glance home-screen widgets | Static level/remaining views with quick logging; no pour stream, tilt, or surface reaction |
| Control/widget quick log | Android Quick Settings Tile and launcher shortcuts | Default amount routes to `LogIntake`; custom amount launches a small Android screen/dialog |
| Siri/App Intents | Android intents, launcher shortcuts, Google Assistant/App Actions | Stable parameters and deep links end at the same use cases; direct app/widget paths work without Assistant |
| Watch app | Wear OS app with Compose for Wear OS | Today, seven-day History with Day Detail, current ISO-week Stats, offline logging, phone replication |
| Watch complications | Wear complications and Tiles | Focused ring/remaining surfaces; no calendar or Stats chart |
| Export | Android document/share flow around `ExportData` | User can create/share a complete export without direct database access |

## 3. Android technology decisions

### 3.1 Required stack

- Kotlin with Kotlin Coroutines and Flow.
- Jetpack Compose for phone/tablet UI.
- Material 3 components and Android adaptive layouts.
- One phone/tablet Activity hosting Compose destinations.
- `ViewModel` state holders with lifecycle-aware Flow collection.
- Room over SQLite for structured local persistence.
- DataStore only for non-domain preferences such as UI presentation preferences.
- WorkManager for durable, deferrable, retryable work.
- AlarmManager for user-visible reminder timing; do not use periodic WorkManager as an exact alarm substitute.
- Health Connect for hydration, weight, and workout integration.
- Jetpack Glance for home-screen widgets.
- Compose for Wear OS and Wear Material components for the watch app.
- Wearable Data Layer for Android phone/watch replication.
- Compose `Canvas` for charts and water geometry; no third-party chart or fluid-rendering library.
- `java.time` for instants, local dates, time zones, and ISO-week calculations.

Use current stable Kotlin, Android Gradle Plugin, AndroidX, Compose, Room, Health Connect, Glance, WorkManager, and Wear OS versions when the project is bootstrapped. Pin every version in `Android/gradle/libs.versions.toml`; do not scatter versions through module build files.

Phone/tablet uses `minSdk 28`, matching the supported Health Connect app baseline. The Wear module uses `minSdk 30` for the first release and targets the current stable Wear OS SDK. Compile/target SDK values are the current stable SDK selected at project bootstrap and recorded in the version catalog.

Do not add Hilt, a chart framework, a UI kit, a navigation abstraction, or a fluid simulation library merely for convenience. Manual composition keeps the Android boundary explicit and matches Ripple's small dependency policy. A new non-AndroidX dependency requires an ADR.

### 3.2 Official platform references

The implementing agent must consult the current versions of these official references while setting up the project:

- [Android app architecture](https://developer.android.com/topic/architecture)
- [Room persistence](https://developer.android.com/training/data-storage/room)
- [DataStore](https://developer.android.com/topic/libraries/architecture/datastore)
- [WorkManager](https://developer.android.com/develop/background-work/background-tasks/persistent)
- [Health Connect](https://developer.android.com/health-and-fitness/health-connect)
- [Health Connect permissions and data access](https://developer.android.com/health-and-fitness/health-connect/ui/permissions)
- [`HydrationRecord`](https://developer.android.com/reference/kotlin/androidx/health/connect/client/records/HydrationRecord)
- [Jetpack Glance](https://developer.android.com/develop/ui/compose/glance)
- [Quick Settings Tiles](https://developer.android.com/develop/ui/views/quicksettings-tiles)
- [Google Assistant/App Actions](https://developer.android.com/develop/devices/assistant/overview)
- [Wear OS app architecture](https://developer.android.com/training/wearables/get-started/creating)
- [Wear Data Layer](https://developer.android.com/training/wearables/data/overview)
- [Android Auto Backup](https://developer.android.com/identity/data/autobackup)

## 4. Android repository layout

Create a new Gradle build under `Android/`. Do not mix Android source files into the Swift package directories.

```text
Android/
  settings.gradle.kts
  build.gradle.kts
  gradle.properties
  gradle/
    libs.versions.toml

  app/
    src/main/
      AndroidManifest.xml
      kotlin/de/stefansturm/ripple/android/
        RippleApplication.kt
        AppContainer.kt
        MainActivity.kt
        RootNavHost.kt
    src/test/
    src/androidTest/

  wear/
    src/main/
      AndroidManifest.xml
      kotlin/de/stefansturm/ripple/wear/
        RippleWearApplication.kt
        WearAppContainer.kt
        WearMainActivity.kt
        WearRootNavHost.kt
    src/test/
    src/androidTest/

  core/domain/
  core/storage/
  core/preferences/
  core/health/
  core/system/
  core/designsystem/
  core/testing/
  core/wear-sync/

  feature/today/
  feature/history/
  feature/stats/
  feature/settings/
  feature/onboarding/

  system/widgets/
  system/quicksettings/
  system/appactions/

  docs/
    Android-Testing.md
```

The package name should be `de.stefansturm.ripple.android` for the phone application and a matching Wear package namespace. Use a single Android application identity for the phone product and a separate Wear APK identity that is associated with it in Play Console.

## 5. Module responsibilities and dependency graph

```text
app --------------------------> feature/*
 |                               core/domain
 |                               core/designsystem
 |                               core/storage
 |                               core/preferences
 |                               core/health
 |                               core/system
 |                               system/*
 |
wear -------------------------> core/domain
 |                               core/designsystem (tokens/shared primitives only)
 |                               core/storage
 |                               core/wear-sync
 |                               feature/today, feature/history, feature/stats
 |
feature/* --------------------> core/domain + core/designsystem
system/widgets ---------------> core/domain + core/storage + core/system
system/quicksettings ---------> core/domain + core/storage + core/system
system/appactions ------------> core/domain + core/storage + core/system

core/domain ------------------> no Android, Compose, Room, Health Connect, or Play Services
core/storage -----------------> core/domain
core/health ------------------> core/domain
core/system ------------------> core/domain
core/wear-sync ---------------> core/domain
core/designsystem ------------> Compose/Material; no storage or domain write logic
core/testing -----------------> test dependencies and domain contracts only
```

### `core:domain`

Pure Kotlin entities, value types, ports, use cases, calculations, aggregators, unit conversion, formatting contracts, and fake-friendly clocks. This module must compile without the Android SDK.

### `core:storage`

Room entities, DAOs, database configuration, migrations, mappings, repository implementations, transaction helpers, and the projection/outbox tables. It owns no Compose or Android system UI.

### `core:preferences`

DataStore-backed preferences that are not domain truth, such as whether a one-time Android education card was dismissed or which widget configuration was selected. Profile, goals, containers, reminders, and intakes do not belong here; they remain in Room.

### `core:health`

Health Connect client factory, permission mapping, hydration projection, weight reader, workout reader, projection queue worker, and health availability state. It implements domain ports and does not expose `HealthConnectClient` to features.

### `core:system`

Notification channels, reminder scheduler, notification action receiver, WorkManager factories, widget invalidation, export file adapter, clock/time-zone adapters, and Android permission adapters.

### `core:designsystem`

Android-native Ripple theme, Material role mapping, dimensions, typography, shapes, reusable controls, hero drawing primitives, day rings, chart primitives, semantics, and motion helpers. It must not call repositories or use cases.

### `core:wear-sync`

Versioned phone/watch mutation envelopes, Data Layer clients/listeners, acknowledgements, snapshot transfer, retry/outbox handling, and deterministic merge policy. It transports domain values but does not decide goal formulas or perform direct Room writes outside repository/use-case boundaries.

### Feature modules

Each feature contains Compose screens, screen-specific `ViewModel`s, UI state, event reducers, and navigation destinations. Features depend on domain contracts and design components, never on Room, Health Connect, WorkManager, or Data Layer APIs.

### System modules

Widgets, Quick Settings, and App Actions are separate Android entry-point modules. Each obtains the process `AppContainer` and calls a domain use case. They do not duplicate amount resolution or intake persistence.

## 6. Composition roots and concurrency

### 6.1 Application composition

`RippleApplication` creates one `AppContainer` for the phone process. The container constructs:

1. application context and clock/time-zone provider;
2. Room database and DAOs;
3. repositories and transaction coordinator;
4. Health Connect adapters and projection queue;
5. reminder, notification, widget, export, and permission adapters;
6. `UseCases` assembled from those ports;
7. WorkManager configuration and worker factory;
8. Wear sync client/listener registration when supported.

`RippleWearApplication` creates the watch-local equivalent. It has its own Room database, local use cases, outbox, and Data Layer client. It does not assume that the phone process is running.

System entry points obtain the application instance and its container through Android's normal application lifecycle. Do not create a static mutable service locator, a second container per click, or direct singleton repositories.

### 6.2 UI state

Each screen ViewModel:

- accepts use cases through its constructor/factory;
- exposes immutable `StateFlow<ScreenState>`;
- receives user events through methods such as `onQuickAdd`, `onUndo`, or `onSelectDay`;
- launches coroutines in `viewModelScope`;
- converts typed domain/system failures into localized UI state;
- cancels stale refresh/motion work when the screen leaves the back stack.

Composables collect with `collectAsStateWithLifecycle()` and render state. They do not open Room, call Health Connect, schedule alarms, or mutate domain models.

### 6.3 Isolation rules

- Room access stays off the main thread through suspend DAO methods and injected dispatchers.
- Health Connect calls are suspend operations and run through the health adapter/worker.
- WorkManager workers reconstruct their dependencies from the application container and are idempotent.
- Domain values crossing module/device boundaries are immutable and serializable.
- The phone and watch each use a process-local `CoroutineScope` only for app lifetime work; durable work belongs in WorkManager or the Data Layer outbox.

## 7. Domain model and use-case API

### 7.1 Core values

Use Kotlin value/data types equivalent to these concepts:

```text
Milliliters(Int)
IntakeId(UUID/String)
ContainerId(UUID/String)
DeviceId(String)
MutationId(UUID/String)

Intake
  id, dateTime, amountMl, beverage, source, containerId?, note?,
  isDeleted, createdAt, updatedAt, originDeviceId

Container
  id, name, amountMl, isDefault, sortOrder, symbolName, createdAt, updatedAt

Profile
  preferredUnit, bodyMassKg?, activityLevel, wakeTime, sleepTime,
  remindersEnabled, healthWriteEnabled, healthReadEnabled, hapticsEnabled,
  onboardingCompleted, updatedAt

GoalSettings
  mode(manual/calculated), manualGoalMl?, updatedAt

ReminderRule
  enabled, startTime, endTime, intervalMinutes, afterLastIntake, updatedAt
```

Use `Int` for individual milliliter values and `Long` for aggregate sums before converting back to display values. Dates are stored as absolute instants plus enough local-time context to calculate the user's current local day correctly.

### 7.2 Ports

The domain ports should expose intent-level operations, not Room types:

```kotlin
interface IntakeRepository {
    suspend fun insertIfAbsent(intake: Intake): InsertResult
    suspend fun update(intake: Intake)
    suspend fun find(id: IntakeId): Intake?
    suspend fun lastOwnNonDeleted(): Intake?
    suspend fun observeRange(range: InstantRange): Flow<List<Intake>>
    suspend fun monthSummaries(range: LocalDateRange, goalMl: Int): List<DaySummary>
    suspend fun statsSnapshot(range: InstantRange, goalMl: Int): StatsSnapshot
}

interface SettingsRepository {
    suspend fun profile(): Profile
    suspend fun saveProfile(profile: Profile)
    suspend fun goalSettings(): GoalSettings
    suspend fun saveGoalSettings(settings: GoalSettings)
    suspend fun containers(): List<Container>
    suspend fun saveContainer(container: Container)
    suspend fun deleteContainer(id: ContainerId)
    suspend fun reminderRule(): ReminderRule
    suspend fun saveReminderRule(rule: ReminderRule)
}
```

Actual Kotlin signatures may use `Flow` directly for observations, but the dependency direction and method meaning must stay the same. No feature should receive a DAO.

### 7.3 Use cases

`LogIntake` accepts an amount, source, date, optional container/note, and optional stable ID for replay. It validates non-negative integer milliliters, creates or preserves the intake UUID, and delegates the transaction to the repository.

All of these use cases must exist before feature work is considered complete:

```text
LogIntake
UndoLastIntake
EditIntake
DeleteIntake
RestoreIntake

ObserveToday
ObserveHistory
ObserveMonth
ObserveStats

UpdateGoal
CalculateGoal
UpdateProfile
UpsertContainer
DeleteContainer
ExportData
RescheduleReminders

RequestHealthOnboardingAccess
RequestHealthReadAccess
RequestHealthWaterWrite
RequestNotificationAuthorization
```

### 7.4 Goal and aggregation rules

Keep the iOS domain formula equivalent:

- Manual goal mode returns the configured positive manual goal.
- Calculated mode uses a valid body-mass baseline of `bodyMassKg * 33`, rounded to the nearest 50 ml.
- Workout adjustment, when enabled and available, adds `(workoutMinutes / 30) * 350 ml`.
- When workout adjustment is not used, the configured activity-level adjustment applies.
- The calculated result has a minimum of 250 ml.
- Missing/invalid body mass falls back to the documented 2000 ml baseline.

Historical summaries use a stable fallback goal for the requested period. They do not retroactively change because the user edited today's profile. History excludes soft-deleted rows, creates empty days, caps visual progress at 1.0, and marks goal hits. Stats separately derives totals, averages, hit/empty/weak days, day-part/container groups, best day, and current hit run.

### 7.5 Unit conversion and localization

The domain works in ml. `UnitConverter` converts to/from ml and fluid ounces with explicit rounding rules. `VolumeFormatter` produces DE/EN strings and TalkBack descriptions. No localized string is used as an input to a calculation.

## 8. Room persistence design

### 8.1 Tables

Use explicit Room entities with stable primary keys and versioned migrations.

```text
intakes
  id TEXT PRIMARY KEY
  date_time_epoch_millis INTEGER NOT NULL
  local_date TEXT NOT NULL
  amount_ml INTEGER NOT NULL
  beverage_raw TEXT NOT NULL
  source_raw TEXT NOT NULL
  container_id TEXT NULL
  note TEXT NULL
  is_deleted INTEGER NOT NULL
  created_at_epoch_millis INTEGER NOT NULL
  updated_at_epoch_millis INTEGER NOT NULL
  origin_device_id TEXT NOT NULL

containers
  id TEXT PRIMARY KEY
  name TEXT NOT NULL
  amount_ml INTEGER NOT NULL
  is_default INTEGER NOT NULL
  sort_order INTEGER NOT NULL
  symbol_name TEXT NULL
  created_at_epoch_millis INTEGER NOT NULL
  updated_at_epoch_millis INTEGER NOT NULL

goal_settings
  singleton_id INTEGER PRIMARY KEY CHECK(singleton_id = 1)
  mode_raw TEXT NOT NULL
  manual_goal_ml INTEGER NULL
  updated_at_epoch_millis INTEGER NOT NULL

profile
  singleton_id INTEGER PRIMARY KEY CHECK(singleton_id = 1)
  preferred_unit_raw TEXT NOT NULL
  body_mass_kg REAL NULL
  activity_level_raw TEXT NOT NULL
  wake_time_minutes INTEGER NOT NULL
  sleep_time_minutes INTEGER NOT NULL
  reminders_enabled INTEGER NOT NULL
  health_write_enabled INTEGER NOT NULL
  health_read_enabled INTEGER NOT NULL
  haptics_enabled INTEGER NOT NULL
  onboarding_completed INTEGER NOT NULL
  updated_at_epoch_millis INTEGER NOT NULL

reminder_rules
  singleton_id INTEGER PRIMARY KEY CHECK(singleton_id = 1)
  enabled INTEGER NOT NULL
  start_minutes INTEGER NOT NULL
  end_minutes INTEGER NOT NULL
  interval_minutes INTEGER NOT NULL
  after_last_intake INTEGER NOT NULL
  updated_at_epoch_millis INTEGER NOT NULL

health_projection_operations
  operation_id TEXT PRIMARY KEY
  intake_id TEXT NOT NULL
  operation_raw TEXT NOT NULL
  state_raw TEXT NOT NULL
  attempt_count INTEGER NOT NULL
  next_attempt_epoch_millis INTEGER NULL
  last_error_code TEXT NULL
  updated_at_epoch_millis INTEGER NOT NULL

wear_mutation_outbox
  mutation_id TEXT PRIMARY KEY
  entity_id TEXT NOT NULL
  mutation_raw TEXT NOT NULL
  payload TEXT NOT NULL
  state_raw TEXT NOT NULL
  attempt_count INTEGER NOT NULL
  updated_at_epoch_millis INTEGER NOT NULL
```

Use indexes for `intakes(date_time_epoch_millis)`, `intakes(local_date)`, `intakes(is_deleted, date_time_epoch_millis)`, and projection/outbox state. Avoid storing display strings, localized labels, or derived chart arrays.

### 8.2 Transactions and idempotency

`LogIntake`, delete, restore, and replayed Wear mutations must be transactionally idempotent:

1. validate the command;
2. check the stable entity/mutation ID;
3. insert or apply only if the incoming mutation wins the deterministic ordering;
4. write/update the projection or Wear outbox operation in the same transaction;
5. commit Room;
6. schedule external work after commit.

An external failure after commit is a retryable projection failure, not a domain failure. The UI must never display a successful log and then remove it because Health Connect or the phone/watch link was unavailable.

### 8.3 Time and local-day handling

Store absolute event time and a derived local-date key. `ObserveToday` computes the current day using the device's current time zone. Historical queries use explicit local-date ranges. Tests must cover time-zone changes, daylight-saving transitions, midnight boundaries, and a user changing the device time zone after logging.

### 8.4 Backup and privacy

Configure `android:dataExtractionRules` deliberately:

- include the Room database and required non-sensitive settings for device restore;
- exclude caches, WorkManager transient state, widget preview caches, and failed network payloads;
- exclude secrets because the app has no account token in this version;
- do not use backup configuration as an iOS/Android sync mechanism.

Do not log intake contents, body mass, Health Connect records, or user notes to Logcat in release builds.

## 9. Unified write path and external projections

### 9.1 Entry points

These entry points all call the same `LogIntake`:

```text
Today quick-add / FAB
History Day Detail add action
Glance widget action
Quick Settings Tile
notification action
launcher shortcut
Google Assistant/App Action fulfillment
Wear OS predefined amount
Wear OS rotary custom amount
```

Source values include `app`, `widget`, `control`, `notification`, `assistant`, and `watch`. The source is metadata on the intake; it never selects a different amount algorithm or persistence path.

### 9.2 `LogIntake` sequence

```text
Entry point receives command
          |
          v
Resolve/validate amount in the adapter
          |
          v
LogIntake.run(command)
          |
          +--> normalize amount to Milliliters
          +--> preserve supplied replay UUID or create UUID
          +--> Room transaction inserts intake if absent
          +--> transaction records Health projection operation
          +--> transaction records Wear mutation if required
          |
          v
Room commit is authoritative
          |
          +--> enqueue HealthProjectionWorker
          +--> reload Glance/widget surfaces
          +--> reschedule next reminder
          +--> notify active Wear peer
```

The foreground app may attempt Health Connect immediately for a responsive result, but the durable projection operation remains the recovery path. A worker uses exponential backoff and marks a permanent permission/provider failure for Settings/status presentation rather than deleting the intake.

### 9.3 Undo, edit, delete, restore

- `UndoLastIntake` finds the last own, non-deleted row, soft-deletes it, enqueues a Health delete operation, updates widgets, and reschedules reminders.
- `DeleteIntake` performs the same soft-delete behavior for a selected ID.
- `RestoreIntake` clears the tombstone, re-enqueues the Health write, and syncs the restored value to Wear.
- `EditIntake` updates amount/date/container/note as allowed, keeps the same UUID, and enqueues a delete/rewrite projection sequence when the external record must change.
- Snackbar undo is presentation state only; the actual operation is the domain use case.

## 10. Health Connect integration

Health Connect is optional and never authoritative.

### 10.1 Hydration projection

Write one `HydrationRecord` per Ripple intake with:

- volume converted from integer ml to Health Connect volume;
- event start/end derived from the intake instant with a short valid interval;
- metadata identifying the Ripple intake UUID, source, app package, and device;
- a stable client record ID/version when supported by the installed SDK.

Before every write/delete/read, query current permissions and provider availability. The user may revoke access outside the app. A denied permission leaves the Ripple intake intact and exposes a reconnect action in Settings.

### 10.2 Reads

- Weight is read only when the user grants the required Health Connect read permission and is used as an input to `CalculateGoal`.
- Exercise sessions/workout duration are read only when the user enables the workout adjustment and grants the required permission.
- Read data is never copied into the intake table as if Ripple had logged it.
- Health Connect data is filtered to supported record types and the app's intended time range.

### 10.3 Permission UX

Settings and onboarding expose separate actions for:

- Health Connect onboarding/availability;
- hydration write access;
- weight/workout read access;
- opening Health Connect app permissions.

The app must show a meaningful state for unavailable provider, not installed provider, denied, partially granted, and granted permissions. It must not repeatedly prompt after the user has declined without an explicit user action.

## 11. Android-native UI system

### 11.1 Visual identity

Create `RippleTheme` in `core/designsystem`. Map the Ripple palette to Material color roles without enabling uncontrolled dynamic accent colors in v1:

| Ripple token | Android role |
| --- | --- |
| Water Deep `#0B3D4A` | `onBackground`, `onSurface`, primary text/icon emphasis |
| Water Lagoon `#1A7A8C` | `primary`, selected controls, goal success |
| Water Aqua `#4FB3C6` | progress/water fill, secondary emphasis |
| Water Foam `#E8F4F6` | light background and low-emphasis surfaces |
| Cool anthracite surfaces | dark background/surface roles |
| System desaturated red | destructive/error role |

Use Android's default system sans font, Material typography roles, 4dp spacing, platform-appropriate elevation, and Material shape tokens. Do not import San Francisco, Liquid Glass, iOS card styling, or iOS-specific shadow behavior.

Reusable Android components should include:

```text
RippleWaterHero
RippleQuickAddRow
RipplePrimaryButton
RippleAmountSelector
RippleContainerChip
RippleRemainingLabel
RippleDayRing
RippleIntakeRow
RippleSyncStatus
RippleEmptyState
RippleChart
RippleSettingsRow
```

Components accept state and callbacks. They do not own use cases or repositories. Each component must have light/dark, large-font, TalkBack, and reduced-motion coverage.

### 11.2 Phone/tablet navigation and workflows

Use a canonical Android adaptive layout:

- compact width: `NavigationBar` with Today, History, Stats, Settings;
- medium width: `NavigationRail` with content beside it;
- expanded width: `ModalNavigationDrawer` or persistent navigation plus list/detail panes;
- tablet History: month grid beside Day Detail when space permits;
- tablet Stats: chart and summaries in responsive columns;
- tablet Settings: list/detail or two-column settings layout.

This is a functional mapping, not an iOS tab-bar copy. Use Android top app bars, Material buttons, FABs, snackbars, dialogs, and predictive back. Do not put a back button on top-level navigation destinations; use the system back gesture/button for nested destinations.

Today should feel like an Android home screen:

- a top app bar with the current day/status affordances;
- prominent saved-container quick-add row and custom amount action;
- native Material touch feedback;
- a snackbar action for undo;
- the water hero as the visual focus without turning the entire screen into a glass card.

Today deliberately does not render a Recent or last-entry list. Entry
inspection belongs to History and Day Detail, so Android must not introduce a
dashboard row that is absent from the current iOS Today hierarchy.

History Day Detail is a normal nested destination. Stats uses a Material segmented button row or exposed dropdown for week/month/year. Settings uses standard Android list sections, switches, permission rows, and system intents.

### 11.3 Onboarding

Onboarding is an Android back-aware six-page flow with clear progress and
skip/continue semantics:

1. welcome and purpose;
2. units;
3. Health Connect availability and hydration/optional read permission;
4. calculated/manual goal;
5. saved containers;
6. notification permission and reminder setup, then completion.

Do not embed permission screens inside a fake iOS-style form. Launch the native Health Connect and Android notification permission contracts at the appropriate step, then refresh permission state when the user returns.

## 12. Today hero and motion on Android

The Android hero keeps Ripple's water behavior while using Compose drawing and Android system motion settings.

### 12.1 Rendering rules

- Draw a stylized 2D container and contained water surface with `Canvas`/`Path`.
- Do not use `CircularProgressIndicator` or a ring as the daily hero.
- Do not use a single drop icon as the add metaphor.
- At zero level, draw no water fill and no bottom shimmer.
- Use one active stream for one coalesced rapid-add series.
- Start the stream above the container and connect it to the water surface.
- Keep numbers above the stream.
- Use a central contact depression, outward response, weak reflection, and settle to flat.
- Keep the water area contained and visually area-preserving under slosh.
- Never use particles, a fluid solver, a shader simulation, video, or a permanently moving idle surface.

### 12.2 Animation contract

Use a shared frame-sampled `PourClock` in a `LaunchedEffect` or equivalent animation controller. The clock drives the stream and water-level interpolation together.

```text
quick control response       0.28 s
pour lead-in                 0.14 s
active pour                  0.40–0.70 s based on series amount
level duration               active pour + 0.14 s
undo reverse                 0.45 s
reduced-motion cross-fade    0.20 s
```

The active level interpolation is linear and target-locked. No spring, overshoot, or independent animation may change the target while the stream is active. Use Android's animator duration scale and accessibility settings as the source for reduced-motion behavior.

### 12.3 Sensor behavior

Implement `AndroidTiltController` behind a domain-free UI adapter using the rotation-vector/gravity sensor APIs. It must:

- align values to current display rotation;
- support full rotation without a hardcoded 16-degree cap;
- damp the response and preserve containment;
- stop/unregister listeners when the screen is not active;
- return zero for unsupported devices, emulator/simulation, face-up mode, Wear OS, widgets, and reduced motion.

No sensor code may enter the domain or alter stored data.

## 13. Phone feature requirements

### 13.1 Today

`TodayViewModel` observes a `TodaySnapshot` and exposes:

```text
consumedMl
goalMl
remainingMl
percent
defaultContainer
pacing
sync/health status
motion phase
error/confirmation state
```

Quick-add taps call `LogIntake(source = APP)`. Rapid taps create multiple rows but one visual pour series. The final confirmation appears after the pour completes. Undo calls `UndoLastIntake`, not a local array mutation.

Today does not expose an entry list. The History calendar and Day Detail
feature own entry inspection and row actions.

### 13.2 History

History loads month summaries through `ObserveMonth`, shows all days in the month, disables future days, and opens a nested Day Detail route. The calendar uses one ring per day with progress capped at 1.0. A day detail shows entries, total, goal, source, and actions for edit/delete/restore. The add action is visible only for the local current day.

### 13.3 Stats

Stats uses `ObserveStats` with a typed period selection:

```text
week, month, year
```

The screen includes total/average/hit/empty/weak summaries, daily progress chart, day-part grouping, container grouping, best day, and current hit run. `RippleChart` uses Compose Canvas and exposes a TalkBack summary/table equivalent so data is not available only through pixels.

### 13.4 Settings

Settings sections:

- profile and preferred unit;
- manual/calculated goal and suggested goal;
- containers and default container;
- reminder schedule and permission;
- Health Connect availability/permissions;
- haptic preference;
- sync/backup status;
- export data;
- onboarding reset.

All mutations call use cases. Settings never writes Room directly.

## 14. Android system surfaces

### 14.1 Glance widgets

Provide responsive Android widgets for small/medium/large phone surfaces. Each widget reads a current `TodaySnapshot` from Room and displays:

- goal/consumed/remaining;
- a static water-level visual or focused ring;
- a default quick-log action;
- a deep link to Today.

Glance is a separate Compose-like runtime. Do not share ordinary Compose UI composables directly into Glance. Keep widgets stateless and static:

- no Core Motion;
- no tilt;
- no pour stream;
- no surface reaction;
- no Health Connect access from widget code;
- no direct Room mutation from widget code.

The widget action obtains the application container, resolves the default amount, calls `LogIntake(source = WIDGET)`, and requests a widget refresh after commit.

### 14.2 Quick Settings Tile

Provide one default quick-log Tile. A tap logs the configured default amount through `LogIntake(source = CONTROL)`. If a custom amount is needed, the Tile launches a small Activity/dialog and does not attempt to render a full Compose Today screen inside Quick Settings.

The Tile must handle locked device, unavailable application process, missing default container, and duplicate taps without duplicate rows.

### 14.3 Notifications and reminders

Create a reminder notification channel with localized name/description and a default amount action. The action receiver calls `LogIntake(source = NOTIFICATION)` and returns a refreshed notification/status.

`ReminderScheduler`:

- respects notification authorization;
- respects enabled state, wake time, sleep time, interval, and after-last-intake setting;
- schedules only the next actionable reminder;
- replaces/cancels the previous request before scheduling a new one;
- survives reboot through a boot receiver or rescheduling worker;
- uses AlarmManager for reminder timing and WorkManager for durable recovery/reconciliation;
- never schedules outside the configured local window;
- does not create reminders when permission is denied.

Request `POST_NOTIFICATIONS` on supported Android versions at the user-controlled onboarding/settings step. Do not repeatedly prompt after denial.

### 14.4 Launcher shortcuts and Assistant

Provide stable static launcher shortcuts for:

- Log default amount;
- Open Today;
- Open History;
- Open Stats.

Use stable deep links and explicit intent parameters. The fulfillment layer resolves amount/container/date and then calls a use case. It must not insert an `IntakeEntity` itself.

Where an appropriate built-in intent exists, declare an App Action in `shortcuts.xml`. For unsupported semantics, use a custom intent only where the supported locale/parameter limitations are acceptable. Assistant is an optional surface and must never be the only way to access a capability.

### 14.5 Export

`ExportData` produces a complete, versioned UTF-8 JSON payload containing profile, goals, containers, reminders, and intake rows including soft-deleted state where required for reconciliation. The Android adapter uses `ACTION_CREATE_DOCUMENT` and the system share sheet. Export does not expose Room files or internal database schema as the public contract.

## 15. Wear OS architecture and behavior

### 15.1 Wear application

Use Compose for Wear OS and Wear Material components. The watch app must work offline for core logging and recent history.

Use Wear-native patterns:

- `SwipeDismissableNavHost` for nested navigation;
- `TransformingLazyColumn`/`ScalingLazyColumn` for lists;
- `Chip`/`CompactChip` for actions;
- rotary input for custom amount selection;
- `TimeText` and watch-safe content margins;
- power-conscious recomposition and no continuous idle animation.

Do not reproduce Apple Watch page indicators, crown controls, or swipe navigation. Use Android Wear conventions while preserving the capability set.

### 15.2 Wear screens

Today:

- full water-level field;
- predefined amounts;
- rotary-first custom amount entry;
- local log confirmation;
- offline behavior;
- source `.WATCH`.

History:

- seven elapsed local days;
- one compact day row per day;
- nested Day Detail;
- individual entry delete and restore;
- no month calendar.

Stats:

- current ISO-week summary;
- one compact chart;
- no period picker;
- no month/year chart navigation.

### 15.3 Wear Data Layer protocol

Use versioned paths and small immutable payloads:

```text
/ripple/v1/snapshot/request
/ripple/v1/snapshot/response
/ripple/v1/mutations/outgoing
/ripple/v1/mutations/ack
/ripple/v1/status
```

Each mutation includes:

```text
schemaVersion
mutationId
entityId
entityType
operation(insert/update/delete/restore)
payload
updatedAt
originDeviceId
```

Rules:

- Data Layer transfers only Android phone/watch data; it is not a general network API.
- The watch writes locally before sending.
- The phone applies incoming mutations through the same domain boundary and acknowledges only after Room commit.
- The watch removes an outbox row only after acknowledgement.
- Replayed mutation IDs are no-ops.
- Tombstones are retained until a confirmed snapshot/ack makes removal safe.
- Conflict ordering is `updatedAt`, then `originDeviceId`; deletes win ties.
- The phone sends accepted changes/snapshots back to the watch.
- A disconnected watch remains useful and shows a stale/sync status when appropriate.
- No Health Connect write happens on Wear; the phone projection worker handles it after the intake reaches the phone.

## 16. Health, notification, and system permission behavior

Permissions are capability gates, not data gates:

- denied Health Connect never blocks logging;
- denied notifications never blocks logging;
- missing sensors never blocks Today;
- disconnected Wear never blocks phone use;
- failed projection never removes a Room intake;
- unavailable backup never blocks export.

Every permission-dependent adapter returns an explicit state:

```text
unavailable
notDetermined
denied
partiallyGranted
granted
temporarilyFailed
```

ViewModels render these states with a user action to retry/open system settings. System adapters do not show arbitrary dialogs from background workers.

## 17. Localization and accessibility

### 17.1 Locales

Support DE and EN in `res/values/strings.xml` and `res/values-de/strings.xml`. Use Android plurals and quantity formatting. Do not concatenate English fragments in Kotlin. Voice/Assistant phrases must use supported Android/Assistant localization rules; all core app UI remains fully localized.

### 17.2 TalkBack

Every interactive element exposes:

- action name;
- amount in the user's selected unit;
- current/target goal where relevant;
- percentage/remaining amount;
- source for intake rows;
- selected/disabled/future-day state;
- chart summary and accessible data values.

The hero has one concise aggregate content description and does not force TalkBack through each decorative water path.

### 17.3 Large text and touch

- Support Android font scale through at least 2.0 without clipped numbers.
- Use minimum 48dp touch targets.
- Avoid hardcoded pixel sizes; use dp/sp and adaptive constraints.
- Test landscape, split screen, fold posture, and large display sizes.
- Respect system dark mode and high-contrast behavior where available.

## 18. Testing strategy

### 18.1 `core:domain` unit tests

At least one test per use case, plus boundary/property cases for:

- Log and duplicate UUID handling;
- undo last own non-deleted intake;
- edit/delete/restore identity preservation;
- goal formula/manual fallback/minimum/rounding;
- unit conversion and localized volume formatting;
- history empty/future/over-goal days;
- Stats week/month/year and ISO-week boundaries;
- day-part/container grouping;
- pacing across wake/sleep boundaries;
- source attribution;
- export completeness.

### 18.2 `core:storage` tests

- Room schema creation and migrations;
- transaction atomicity;
- soft-delete and restore;
- duplicate/replayed mutation idempotency;
- deterministic conflict ordering;
- local-day/time-zone queries;
- projection/outbox retry state;
- default seeding idempotency;
- backup exclusion configuration review.

### 18.3 Phone/UI tests

- Compose semantics tests for all primary actions;
- Today quick add and snackbar undo;
- History future-day disabling and Day Detail actions;
- Stats period selection and chart semantics;
- Settings and onboarding permission states;
- deep-link/shortcut fulfillment;
- notification action receiver;
- Glance widget rendering/action callback;
- Quick Settings Tile duplicate tap behavior;
- light/dark/large-font/reduced-motion states.

### 18.4 Health Connect tests

Use a fake client for unit tests and a real provider/emulator/device matrix for integration tests:

- provider unavailable;
- permission denied, partially granted, granted, and revoked after grant;
- hydration write success;
- write retry/backoff;
- delete/rewrite after undo/edit;
- weight/workout read omitted when unauthorized;
- no Room rollback on any Health Connect failure.

### 18.5 Wear tests

- local logging while disconnected;
- mutation outbox persistence;
- replayed mutation is a no-op;
- acknowledgement removes the outbox row only after Room commit;
- delete/restore tombstones transfer;
- phone reconnect/snapshot recovery;
- rotary amount selection;
- seven-day local history;
- ISO-week Stats;
- complication/Tile empty/loading/stale states;
- watch battery-conscious rendering with no idle animation.

### 18.6 Manual acceptance matrix

Verify on:

- compact phone portrait/landscape;
- large phone and tablet;
- foldable open/closed posture;
- Wear OS emulator and at least one physical watch;
- dark/light themes;
- font scale 1.0, 1.3, 2.0;
- TalkBack;
- Android reduced-animation setting;
- sensor-present, sensor-absent, face-up, and emulator devices;
- no network and process restart;
- reboot with reminders enabled;
- midnight, time-zone, and daylight-saving transitions;
- Health Connect unavailable/denied/revoked;
- notification permission denied;
- phone/watch disconnected and reconnected;
- widget refresh after app, widget, notification, and watch writes.

## 19. Implementation order

Each stage must build and test independently before the next stage begins.

### Stage 1 — project and module foundation

- Create the `Android/` Gradle build, version catalog, phone module, Wear module, and core/feature module structure.
- Configure Kotlin, current stable SDKs, `minSdk`, resource namespaces, DE/EN resources, debug/release variants, and basic lint/test tasks.
- Add only the approved AndroidX/Google dependencies.
- Produce a phone APK and Wear APK with minimal native Compose roots.

Acceptance: clean Gradle sync, phone debug build, Wear debug build, unit-test task, and no dependency version outside the catalog.

### Stage 2 — pure domain

- Implement domain values, sources, ports, use cases, goal formula, unit conversion, history aggregation, stats aggregation, pacing, and export payload.
- Add fakes and unit tests before adapters.

Acceptance: domain module compiles without Android imports and all use-case/formula tests pass.

### Stage 3 — Room and local source of truth

- Implement entities, DAOs, mappings, database, migrations, repository transactions, default seeding, projection queue, and Wear outbox.
- Implement phone and watch database factories with the same schema but separate database files.
- Add idempotency/conflict/time-zone tests.

Acceptance: local logging, undo, delete, restore, edit, history, Stats, and settings data survive process death and migration tests.

### Stage 4 — Android phone UI

- Implement `RippleTheme`, adaptive navigation, Android-native Today, History, Stats, Settings, and onboarding.
- Implement Canvas hero/charts, reduced motion, sensor adapter, TalkBack semantics, large text, and dark mode.
- Connect only through ViewModels/use cases.

Acceptance: phone/tablet capability matrix passes without direct storage/system imports in feature modules.

### Stage 5 — Health, reminders, and system surfaces

- Implement Health Connect permissions/projection queue and workers.
- Implement notification channels/actions, reminder scheduling, reboot rescheduling, export document flow, Glance widgets, Quick Settings Tile, launcher shortcuts, and App Actions/deep links.

Acceptance: every system surface reaches the same write path and projection failures never remove local data.

### Stage 6 — Wear OS

- Implement Wear-native Today, History, Stats, complications, Tiles, rotary input, local database, and offline outbox.
- Implement versioned Data Layer transport, acknowledgements, snapshots, tombstones, retries, and stale-state UI.

Acceptance: watch remains useful offline, logs reach phone exactly once after reconnect, and delete/restore behavior is consistent on both devices.

### Stage 7 — release hardening

- Complete DE/EN translations, TalkBack audit, large-font audit, reduced-motion audit, battery/background audit, backup rules, manifest/exported-component audit, and privacy review.
- Run the complete unit, Room, Compose, widget, Health Connect, Wear, and manual acceptance matrix.
- Update `Android/README.md` with build/test commands and record final SDK/dependency versions.

Acceptance: all parity requirements pass, no temporary behavior remains, no cross-platform data path exists, and release builds are reproducible.

## 20. Agent working rules

- Read this document and the linked iOS specs before writing Android code.
- Preserve domain behavior, not iOS presentation code.
- Put new business behavior in `core:domain` use cases and tests.
- Put Room, Health Connect, WorkManager, AlarmManager, Data Layer, and Android permission code behind adapters.
- Keep feature modules unaware of concrete persistence/system frameworks.
- Route every intake through `LogIntake`.
- Do not make Health Connect, widgets, or Wear the source of truth.
- Do not add iOS/Android sync, a cloud backend, or account login without a new approved specification and ADR.
- Do not copy iOS glass, SF Symbols, SwiftUI navigation, or Apple Watch workflows.
- Use Android-native Material/Wear patterns and system behavior.
- Test empty, loading, error, denied-permission, offline, stale-sync, large-text, dark-mode, and reduced-motion states.
- Do not use `print`/Logcat for user data or production telemetry.
- Do not use force unwraps or unchecked casts on production paths.
- Keep all generated files and caches out of source control.

## 21. Completion checklist

An agent may call the Android port complete only when every item is true:

- [ ] Phone/tablet Today, History, Stats, Settings, and onboarding work.
- [ ] Android UI uses Material/adaptive conventions and is not an iOS visual/workflow copy.
- [ ] Every intake source reaches one `LogIntake` implementation.
- [ ] Room is the only Android domain source of truth.
- [ ] Undo, edit, delete, restore, export, and soft-delete semantics work.
- [ ] Goal, unit, pacing, history, and Stats calculations match the product contract.
- [ ] Health Connect hydration projection, optional reads, permissions, retries, and failure isolation work.
- [ ] Notifications/reminders and notification logging action work.
- [ ] Glance widgets and Quick Settings logging work without direct writes.
- [ ] Launcher shortcuts and supported Assistant/App Actions reach use cases.
- [ ] Wear OS works offline, supports rotary logging, seven-day History, ISO-week Stats, complications/Tiles, and phone replication.
- [ ] Phone/watch transfer is idempotent and tombstone-safe.
- [ ] DE/EN, TalkBack, large font, dark mode, and reduced motion are verified.
- [ ] No iOS/Android data sharing or unapproved backend exists.
- [ ] All unit, integration, Compose, widget, Health Connect, Wear, and manual acceptance tests pass.
- [ ] Final dependency/SDK versions and build instructions are recorded.

## 22. Related documents

- [Shared iOS architecture](../ARCHITECTURE.md)
- [Ripple PRD](../../Ripple_Handoff/Ripple_PRD.md)
- [Hero motion contract](../../Ripple_Handoff/Ripple_Hero_Motion.md)
- [History and Stats contract](../../Ripple_Handoff/Ripple_History_Stats.md)
- [ADR-000: Architecture](../ADR/ADR-000-architecture.md)
- [ADR-001: Persistence](../ADR/ADR-001-persistence.md)
- [ADR-002: HealthKit](../ADR/ADR-002-healthkit.md)
- [Android UI specification](ANDROID_UI_SPEC.md)

## 23. Documentation maintenance

This document and [Ripple Architecture](../ARCHITECTURE.md) are maintained as a pair. Android has a separate data boundary and native UI, but it must stay aligned with shared Ripple capabilities, domain semantics, and product specifications.

### Source-of-truth precedence

When sources disagree, use this order:

1. `AGENTS.md` for repository process, shared architecture constraints, design tokens, and explicit bans.
2. The authoritative product specifications: [Ripple PRD](../../Ripple_Handoff/Ripple_PRD.md), [Ripple Hero Motion](../../Ripple_Handoff/Ripple_Hero_Motion.md), and [Ripple History and Stats](../../Ripple_Handoff/Ripple_History_Stats.md).
3. An approved ADR or Android decision record for a deliberate platform-specific choice.
4. This Android document for Android module boundaries, platform mapping, and Android-native workflows.
5. Android source and tests, which reveal current behavior and must be brought back into agreement when they drift.

The Android document must never be used to introduce iOS/Android data sharing or to override a shared product invariant without an approved specification change.

### Changes that require a documentation review

Review this document and its iOS companion whenever a change affects:

- domain entities, value types, goal formulas, units, use cases, ports, or source attribution;
- Room tables, migrations, local backup, Wear outbox, mutation ordering, or export;
- Health Connect projection/permissions, reminders, notification actions, WorkManager, or AlarmManager;
- Glance widgets, Quick Settings, launcher shortcuts, Assistant/App Actions, or Wear complications/Tiles;
- Android modules, Gradle dependencies, SDK/minimum versions, manifests, exported components, or concurrency;
- Android-native navigation, Material/Wear design, Today hero behavior, motion, reduced motion, History, Stats, accessibility, or localization;
- Android-only privacy, security, backup, device-transfer, or release requirements;
- the explicit no-cross-platform-data boundary.

Review the iOS document even for an Android-only change. If the shared contract is unchanged, record that the change is Android-only in this document's timeline and leave the iOS document's version unchanged.

### Required update workflow

1. Read both architecture documents and the affected source specification before editing Android code or build configuration.
2. Classify the change as shared, Android-only, iOS-only, or a product-contract change.
3. Update this document in the same change as Android implementation or an Android ADR.
4. Update `Document version` and the date metadata in every document that changed.
5. Append one immutable row to this document's timeline. New rows go at the bottom; historical rows are not rewritten or deleted.
6. If shared domain behavior or a product contract changed, update both documents and add corresponding timeline rows with the same release/change reference.
7. Verify Markdown links, Gradle/module examples, permissions, and relevant tests/builds. A documentation-only correction still runs whitespace/link checks.
8. Commit the documentation with the implementation/ADR, or as a separate documentation commit when no code changed.

### Documentation versioning

Use semantic document versions independently from the app version:

- **MAJOR**: incompatible Android architecture, scope, data, sync, or public system-entry contract change.
- **MINOR**: new Android capability, system surface, module boundary, or normative requirement that remains compatible.
- **PATCH**: factual correction, wording clarification, link correction, formatting, or example update with no contract change.

The timeline is the audit trail. Each row records the document version, date, change, and impact. Do not combine unrelated changes into an unexplained version bump.

### Synchronized-document checklist

Before merging an architecture-affecting change, confirm:

- [ ] The source specification or ADR is updated when required.
- [ ] The iOS document reflects the current Swift implementation.
- [ ] This Android document reflects the current Android contract or explicitly records that Android is unaffected.
- [ ] Shared use cases, units, sources, permissions, and feature names mean the same thing in both documents.
- [ ] Android UI/workflow differences are intentional Android-native choices, not accidental parity gaps.
- [ ] The no-cross-platform-data boundary remains explicit and intact.
- [ ] The new timeline entry is present and the version/date metadata is current.

## 24. Timeline

Newest entries are appended at the bottom. Historical entries are immutable.

| Version | Date | Change | Impact |
| --- | --- | --- | --- |
| 1.0.0 | 2026-09-07 | Initial Android architecture and implementation guide created. | Establishes the separate Android data boundary, native Android UI, phone/tablet/Wear capabilities, system surfaces, and delivery requirements. |
| 1.1.0 | 2026-09-07 | Added the paired-document maintenance contract, semantic document versioning, synchronized-document checklist, and immutable timeline. | Android architecture changes now require an explicit documentation review and versioned audit entry. |
| 1.2.0 | 2026-09-07 | Added the Android UI specification companion and linked it as the normative screen/state contract. | Android UI implementation now has explicit wireframes, responsive behavior, state coverage, interaction flows, and screenshot acceptance criteria. |
| 1.3.0 | 2026-09-08 | Synchronized the Android capability matrix, Today hierarchy, six-page onboarding, History/Day Detail flow, separate Stats contract, full Settings surface, Wear detail behavior, and linked v2 Android UI specification. | Android architecture now preserves the current iOS product screens and flows while keeping Material, adaptive navigation, native permission, and Wear-native presentation. |
| 1.3.1 | 2026-09-08 | Consolidated the Android architecture, UI specification, and reference pack under `Docs/Android/`; updated companion links without changing the architecture contract. | Android documentation now has one discoverable product-docs root under `Docs/`. |
