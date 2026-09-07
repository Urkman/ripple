# Ripple Architecture

Ripple is a Swift 6, SwiftUI-first hydration app built as a feature-first Clean MVVM system. The same domain write API serves the main apps, widgets, Siri/App Intents, notification actions, and watch surfaces. SwiftData is the source of truth; CloudKit synchronizes the shared private store when the platform is configured for it, and HealthKit is an optional projection.

This document describes the repository's architecture and current implementation. Product behavior remains defined by the [PRD](../Ripple_Handoff/Ripple_PRD.md), [hero motion specification](../Ripple_Handoff/Ripple_Hero_Motion.md), and [History/Stats specification](../Ripple_Handoff/Ripple_History_Stats.md).

**Document version:** 1.1.0

**Last verified:** 2026-09-07

**Companion document:** [Ripple Android Architecture](ANDROID_ARCHITECTURE.md)

## 1. Architectural goals and invariants

Ripple is organized around a small set of invariants:

- Every intake is created by `LogIntake.run(amount:source:date:)`.
- All persisted amounts are integer milliliters. Unit conversion is a presentation concern.
- SwiftData writes happen through the `@ModelActor`-isolated store. Views never mutate models directly.
- SwiftData is the source of truth. HealthKit, widgets, reminders, and UI snapshots are projections or consumers.
- Deletion is a soft delete using `isDeleted`; restore and undo are explicit use cases.
- Undo means `UndoLastIntake` for the last own, non-deleted intake. There is no distributed undo stack.
- View models orchestrate domain use cases but do not contain persistence, CloudKit, HealthKit, or notification code.
- Navigation is platform-local. There is no app-wide router.
- Business rules are shared across platforms. Platform conditionals belong in apps, UI adapters, or composition code.
- The UI uses the tokens and reusable components from `RippleUI`; features do not define parallel colors, typography, or motion systems.

## 2. System at a glance

The repository is split into package layers. Apps and extensions are composition roots: they assemble dependencies and provide scenes, but do not own business logic.

```text
 Apps + Extensions
 composition roots, scenes, platform adapters
        |
        +--------------------+----------------------+------------------+
        |                    |                      |
 RippleFeatures       RippleIntentsCore       RippleData
 views + @Observable   App Intents and        SwiftData, CloudKit,
 view models            system contracts       HealthKit, reminders
        |                    |                      |
        +----------+---------+----------------------+
                   |
             RippleDomain
        entities, ports, use cases

 RippleUI is shared by app features, intents-facing surfaces, widgets,
 and watch UI. It owns tokens, reusable components, and motion primitives.
```

### Package dependency graph

| Package | Depends on | Responsibility |
| --- | --- | --- |
| `RippleDomain` | None | Sendable entities, value types, ports, use cases, calculations, formatters |
| `RippleData` | `RippleDomain` | SwiftData models/store, CloudKit-compatible configuration, HealthKit projection, notifications, widget reloads |
| `RippleIntentsCore` | `RippleDomain` | App Intents, entities, shortcuts, and system-entry adapters |
| `RippleUI` | None; Core Motion on supported platforms | Design tokens, reusable controls, hero water geometry, motion, widgets, watch components |
| `RippleFeatures` | `RippleDomain`, `RippleUI` | Screen views, platform-local navigation, and `@Observable` view models |

The apps link the packages together. `RippleFeatures` intentionally does not depend on `RippleData`; the composition root injects the domain use cases into the feature layer.

## 3. Repository layout

```text
Apps/
  RippleiOS/        iPhone and iPad composition root
  RipplewatchOS/    Watch composition root
  RipplemacOS/      Mac sidebar and command composition root
  RippletvOS/       tvOS ambient/minimal composition root
  RipplevisionOS/   visionOS window and ornament composition root

Extensions/
  RippleWidgets/    iOS widgets, Lock Screen widgets, Control Center control
  RippleWatchWidgets/

Packages/
  RippleDomain/
  RippleData/
  RippleIntentsCore/
  RippleUI/
  RippleFeatures/

Tests/              repository-level test/support area
Docs/
  ADR/              architecture decision records
  ARCHITECTURE.md   this document
```

Xcode project generation is defined in [`project.yml`](../project.yml). Package manifests and application targets use Swift 6 and the current OS SDK deployment targets configured by the project.

## 4. Composition roots and dependency injection

### Startup sequence

Each executable starts the shared data bootstrap before presenting its root view:

```text
 App or extension starts
          |
          v
 RippleBootstrap.start(inMemory: ...)
          |
          +--> register notification categories
          +--> create SharedContainer / ModelContainer
          +--> create RippleStore (@ModelActor)
          +--> create repository adapters and system adapters
          +--> UseCases.assemble(...)
          +--> install process-local RippleRuntime bridge
          +--> seed default settings asynchronously
          |
          v
 Inject UseCases into SwiftUI environment or system adapter
```

`RippleContainer` is the composition object. It holds the shared model container, `RippleStore`, sync status store, and assembled `UseCases` value. `UseCases.assemble(...)` is the domain-level factory that wires repository and port implementations without exposing concrete data types to features.

SwiftUI screens receive use cases through the `rippleUseCases` environment key. A view model retains the injected `UseCases` value and calls it asynchronously. Widgets, notification actions, and App Intents do not have a SwiftUI environment, so `RippleRuntime` provides a process-local bridge to the already assembled use cases. It is an entry-point bridge, not a second persistence layer or second business implementation.

Previews and package tests use the same domain interfaces with in-memory repositories and no-op system adapters. The debug demo scenario also goes through use cases; it does not insert records directly.

## 5. Domain layer

`RippleDomain` is framework-independent. It does not import SwiftUI, SwiftData, CloudKit, HealthKit, WidgetKit, or platform UI frameworks.

### Domain entities and value types

The main domain values include:

- `Intake`: UUID, local date, integer `amountMl`, beverage, source, optional container, note, timestamps, and soft-delete state.
- `Container`: reusable amount/name/symbol/default/sort information.
- `Profile`: preferred unit, body mass, activity level, wake/sleep schedule, reminder and health preferences, haptics, and onboarding state.
- `GoalSettings`: manual or calculated goal mode.
- `TodaySnapshot`, `DaySummary`, `HistorySnapshot`, and `StatsSnapshot`: read models shaped for feature screens.
- `IntakeSource`: app, widget, watch, Siri, control, notification, and other system entry points.
- `SyncStatus`, authorization statuses, reminder rules, export payloads, units, clock times, and period/range types.

These values are small, Sendable types. IDs are stable UUIDs so records, HealthKit projections, intents, and CloudKit merges can refer to the same logical object.

### Ports

The domain depends on protocols rather than data frameworks:

- `IntakeRepository` reads and writes intake data and derived range/stat queries.
- `SettingsRepository` reads and writes profile, goals, containers, reminder rules, and sync state.
- `HealthProjecting`, `HealthAuthorizing`, and `WorkoutReading` describe HealthKit capabilities.
- `ReminderScheduling` and `NotificationAuthorizing` describe notification behavior.
- `WidgetReloading` tells system surfaces to refresh after a write.

This keeps use cases testable and makes the same rules usable by the iOS app, watch app, widgets, and intents.

### Use cases

Write use cases are the only supported write API for features and system surfaces:

`LogIntake`, `UndoLastIntake`, `EditIntake`, `DeleteIntake`, `RestoreIntake`, `UpdateGoal`, `UpdateProfile`, `UpsertContainer`, `DeleteContainer`, `RescheduleReminders`, and the authorization requests.

Read use cases provide feature-shaped observations:

`ObserveToday`, `ObserveHistory`, `ObserveMonth`, `ObserveStats`, and `CalculateGoal`.

`ExportData` is the explicit export path for user data. The export boundary is important because the store uses soft deletion and does not provide a hard-wipe shortcut.

### Goal calculation and aggregation

Goal calculation is centralized in `CalculateGoal`. The current calculation uses manual goals when selected; otherwise it derives a weight-based baseline, applies the configured activity/workout adjustment, and enforces the domain minimum. Historical days use a stable fallback goal rather than silently changing old summaries when today's settings change.

History aggregation creates a day summary for every day in the requested range, including empty days, excludes soft-deleted intakes, caps visual progress at 1.0, and marks whether the goal was reached. Stats aggregation derives period totals, averages, hit/empty/weak days, day-part and container breakdowns, best day, and current hit run.

## 6. The single intake write path

Every intake-producing surface eventually follows the same path:

```text
 Button / widget / Watch / Siri / Control / notification
                         |
                         v
                  source-specific adapter
                         |
                         v
              LogIntake.run(amount:source:date:)
                         |
                         +--> validate and normalize integer ml
                         +--> create Intake UUID
                         +--> repository.save(intake)
                         +--> best-effort HealthKit projection
                         +--> widget timeline reload
                         +--> reminder rescheduling
                         |
                         v
                   updated SwiftData store
```

`LogIntake` saves the domain intake before attempting projections. A HealthKit or notification failure does not roll back the saved intake. Widget-originated writes avoid an unnecessary self-reload while still using the same use case and store.

The app's rapid taps are coalesced only at the presentation/motion level: each tap remains a separate store row, while `TodayViewModel` presents one continuous pour series. This preserves data fidelity without creating a second batch-write path.

Undo, edit, delete, and restore are separate use cases. They update the same record identity and coordinate the corresponding HealthKit projection/retraction, widget reload, and reminder refresh. Deletion never removes the SwiftData object physically.

## 7. Persistence and synchronization

### SwiftData schema

`RippleData` defines a CloudKit-compatible schema consisting of:

- `IntakeRecord`
- `ContainerRecord`
- `GoalSettingsRecord`
- `ProfileRecord`
- `ReminderRuleRecord`

Records store primitive values and raw enum strings. The schema avoids relationships and uniqueness constraints that complicate CloudKit-backed SwiftData stores. Domain-to-record conversion is isolated in `RecordMapping.swift`.

### Store actor boundary

`RippleStore` is a `@ModelActor` actor. It owns the `ModelContext`, performs fetches and saves, maps records to domain values, and applies soft-delete/update rules. Repositories delegate persistence work to this actor; features never receive a model context.

Reads made by extensions use a fresh read facade over the same shared model container. This allows a widget or intent process to observe data written by another process instead of relying on an in-memory snapshot.

### Shared container and fallback behavior

`SharedContainer` resolves storage in this order:

1. App Group container with automatic CloudKit configuration when the shared group is available.
2. App Group local storage without CloudKit.
3. App-local disk storage without CloudKit.
4. In-memory storage as a final fallback.

The configured identifiers are `group.de.stefansturm.ripple` and `iCloud.de.stefansturm.ripple`, with Info.plist overrides supported. The migration path can adopt a legacy local store into the App Group store and merges records by UUID and update time.

CloudKit synchronization is therefore an implementation of the shared store, not a separate domain source of truth. The app can report unavailable/degraded sync status while continuing to log locally.

### Conflict and deletion rules

- Intake identity is the UUID; append-only intake creation is safe to merge.
- Soft-deleted intakes remain available for sync, restore, export, and projection reconciliation.
- Settings records use update timestamps for last-writer handling.
- No view writes through `@Query`; queries are read-only UI observations where used.
- UserDefaults is not used as a second intake or settings database. Ephemeral widget state is not authoritative.

The persistence decisions are recorded in [ADR-001](ADR/ADR-001-persistence.md) and the overall layering in [ADR-000](ADR/ADR-000-architecture.md).

## 8. HealthKit and other projections

HealthKit is optional and never authoritative. When authorized, a successful intake is projected to Dietary Water in liters with the intake UUID and source stored as metadata. The projection layer deduplicates by UUID, and delete/undo retracts the projected sample when possible.

Health authorization is split by purpose:

- onboarding/write access for dietary water;
- read access for body mass;
- optional workout reads used by goal calculation.

Projection errors are logged/contained at the adapter boundary. The SwiftData intake remains valid if HealthKit is unavailable, denied, or temporarily fails. This behavior is defined in [ADR-002](ADR/ADR-002-healthkit.md).

Notifications are also adapters. `NotificationAuthorizer` translates system authorization status, while `ReminderScheduler` owns categories, pending-request replacement, wake/sleep bounds, interval calculation, and the default log action. The notification action invokes the same `LogIntake` use case rather than creating a notification-specific write path.

## 9. Feature layer and MVVM

`RippleFeatures` is a UI orchestration layer. Each view model is `@MainActor @Observable`, stores the injected use cases as an ignored observation dependency, and exposes plain state for views:

- `TodayViewModel`: observes today's snapshot, logs app intakes, coalesces rapid additions for hero motion, and invokes undo.
- `HistoryViewModel`: loads month summaries, computes calendar slots, prevents future-day selection, and drives day-detail navigation.
- `DayDetailViewModel`: observes a selected day and manages edit/delete/restore plus today's add affordance.
- `StatsViewModel`: selects week/month/year periods, loads chart data, groups day parts/containers, and formats summary values.
- `SettingsViewModel`: edits profile, goals, containers, reminders, sync/health authorization, and export.
- `OnboardingViewModel`: coordinates the staged profile, health, notification, and goal setup flow.
- Watch-specific models: `WatchTodayViewModel`, `WatchHistoryViewModel`, `WatchDayDetailViewModel`, and `WatchStatsViewModel` adapt the same use cases to the Watch interaction model.

The environment provides use cases and a small amount of layout configuration. It does not provide a global navigation router or a data store.

### Screen structure

On iPhone and iPad, `RootView` provides four tabs:

1. Today
2. History
3. Stats
4. Settings

History and Stats are deliberately separate products. History is a month activity calendar with one ring per day and a day detail. Stats is a period summary with Swift Charts. iPad uses split layouts where appropriate instead of shrinking the iPhone hierarchy.

Platform roots are local to each app:

- iOS: tab navigation and local navigation stacks/splits.
- watchOS: horizontal Today, History, and Stats pages.
- macOS: `NavigationSplitView` sidebar with keyboard commands.
- tvOS: minimal Today surface and predefined logging actions.
- visionOS: windowed navigation with ornaments and shared feature screens.

## 10. UI system and motion

`RippleUI` owns the visual language used by all features:

- water deep, lagoon, aqua, foam, success, and danger color tokens;
- San Francisco text styles and monospaced digits;
- 4-point spacing, 12-point control radius, 20-point card radius, and 28-point hero radius;
- glass cards, controls, day rings, intake rows, empty states, remaining labels, and sync status;
- Liquid Glass-compatible control styling with platform-appropriate fallbacks;
- widget and Watch-specific metrics and components.

Features compose these components; they do not copy token values or create local design systems.

### Today hero

The hero is a stylized 2D glass field, not a circular progress view. `RippleHeroView` receives a snapshot and a motion phase, while `WaterFill`, `PourStreamShape`, and the surface geometry remain presentation-only.

The implementation follows the authoritative motion specification:

- idle water is flat and has no sine loop or `TimelineView` animation;
- level zero contains no fill and no bottom shimmer;
- one active stream represents a coalesced add series;
- stream width and duration are derived from the series amount;
- the stream starts above the glass, establishes to the water surface, and fades from the shared pour clock;
- the level rises linearly and reaches its target exactly when the stream disappears;
- the contact response is a central depression, an outward pair, a weaker reflection, and a settle to flat water;
- screen-aligned Core Motion tilt drives damped, area-preserving slosh on physical iOS only;
- Simulator, Mac, Watch, widgets, face-up states, and Reduce Motion use zero tilt;
- Reduce Motion removes the stream and surface reaction and uses the specified cross-fade.

The geometry keeps water contained even under full rotation. It is a bounded 2D shape calculation, not a particle, SPH, Metal, SpriteKit, Lottie, or video simulation.

## 11. Platform and extension architecture

| Target | Composition root | Shared behavior | Platform-specific behavior |
| --- | --- | --- | --- |
| iOS/iPadOS | `Apps/RippleiOS` | Full Today, History, Stats, Settings, onboarding, intents, HealthKit | Tabs on iPhone; split layouts on iPad; Core Motion hero tilt on physical iOS |
| watchOS | `Apps/RipplewatchOS` | Same domain/store/use cases | Watch-native pages, Crown amount entry, recent seven-day history, current ISO-week stats, OLED presentation |
| iOS widgets | `Extensions/RippleWidgets` | Shared store/read models and `LogWidgetWaterIntent` | Static focused surfaces; no pour stream, surface response, or tilt |
| Watch widgets | `Extensions/RippleWatchWidgets` | Shared store/read models and widget intent | Circular, rectangular, and inline complication families |
| macOS | `Apps/RipplemacOS` | Shared Today/History/Stats/Settings features | Sidebar, ⌘N logging, ⌘Z undo, menu bar entry point |
| tvOS | `Apps/RippletvOS` | Shared Today snapshot and logging use cases | Ambient/minimal hero with large predefined buttons |
| visionOS | `Apps/RipplevisionOS` | Shared features and use cases | Windowed layout, navigation and logging ornaments, no immersive router |

All app and widget targets use the configured App Group and CloudKit identifiers where their entitlements support them. The current macOS entitlements file is empty, so Mac storage falls back according to `SharedContainer` until the Mac target is granted the same shared capabilities; cross-process/cross-device Mac sync must not be assumed from the target alone.

## 12. App Intents and system entry points

`RippleIntentsCore` contains the system contract, not a second domain implementation. The current intents include:

- logging a specified or default amount;
- logging from a widget with source `.widget`;
- undoing the last intake;
- reading today's progress;
- setting the daily goal;
- opening Today or History through the pending-route bridge;
- stable `ContainerEntity` lookup and App Shortcuts.

Amount resolution is centralized in the intent adapter and ends at `LogIntake`. Container entities use stable UUIDs and query the settings repository. Shortcut phrases and localized strings are declared with the app name so Siri and Shortcuts remain stable across locales.

`RippleNavigation` is a narrow pending-route handoff for system requests. It is consumed by the relevant app composition root; it is not a general-purpose navigation coordinator.

## 13. Concurrency model

The project uses Swift 6 and complete strict concurrency checking.

- Domain entities, snapshots, ports, and use-case values are Sendable where they cross boundaries.
- SwiftData access is isolated to `RippleStore`, a `@ModelActor` actor.
- View models are Main Actor isolated because they own observable UI state.
- HealthKit and sync helpers use actors where system access or mutable projection state requires serialization.
- Asynchronous tasks are launched from view models for refreshes, debounced/coalesced motion, and authorization flows; cancellation and stale-series guards prevent old work from updating current UI state.
- The shared `UseCases` value is assembled once per process and passed explicitly to consumers.

This separation prevents a model context, a SwiftUI observation object, or a platform framework client from leaking through the domain API.

## 14. Localization, accessibility, and presentation rules

Ripple v1 supports German and English. Feature copy is localized through the package resource bundle and `String(localized:)`; English strings are not hard-coded as a substitute for German localization.

The presentation layer must preserve:

- Dynamic Type through XXXL;
- complete VoiceOver labels containing amount, goal, percentage, and source where relevant;
- monospaced digits for changing numeric readouts;
- readable Deep-on-Foam contrast in light mode and cool anthracite surfaces in dark mode;
- reduced-motion behavior for all active hero and control motion;
- platform-native navigation semantics and no back button on tab roots.

## 15. Testing and verification

Tests are kept close to the package that owns the rule:

- `RippleDomain`: logging/undo, goal formula, units, authorization use cases, history/stats, and pacing.
- `RippleData`: SwiftData store behavior and deterministic demo seeding.
- `RippleIntentsCore`: intent parameters, source attribution, and shared write-path behavior.
- `RippleFeatures`: Today, History, onboarding, Watch amount selection, Watch history, and Watch stats.
- `RippleUI`: hero timing/geometry, water dynamics, and Watch components.

The most important invariants to preserve in new tests are:

- one store row per user log;
- every log source reaches `LogIntake`;
- HealthKit failure does not remove a saved intake;
- undo/delete are soft deletes and restore the same identity;
- zero level is visually empty;
- active pours have no level overshoot;
- Reduce Motion removes stream/surface reaction and tilt;
- future history days cannot be selected;
- chart data remains correct for empty, partial, over-goal, and multi-period states.

Package tests can be run with the repository's documented commands, for example:

```sh
swift test --package-path Packages/RippleDomain
swift test --package-path Packages/RippleData
swift test --package-path Packages/RippleIntentsCore
```

Application and widget targets are verified with Xcode builds/tests for their platform destinations.

## 16. Adding a feature without breaking the architecture

For a new behavior, follow this sequence:

1. Decide whether it changes product behavior. If it changes hero, History, or Stats behavior, update the matching authoritative specification first.
2. Add or extend a domain entity/value type and use case. Keep amounts in integer milliliters.
3. Add the smallest required port method rather than importing a framework into the domain.
4. Implement persistence or system access in `RippleData` behind the port and keep SwiftData access in `RippleStore`.
5. Add a Main Actor `@Observable` view model operation that calls the use case.
6. Build or extend a reusable token/component in `RippleUI` instead of defining feature-local styling.
7. Route Siri, widget, Watch, notification, or Control behavior through the existing use case.
8. Add unit tests for the use case and representative UI/platform tests for the new state.
9. Verify light/dark mode, Dynamic Type XXXL, Reduce Motion, empty/loading/error states, and localization.

Do not add a direct `ModelContext` to a view, a second intake writer, a UserDefaults source of truth, a global router, or a platform-specific copy of a domain rule.

## 17. Related specifications and decisions

- [Ripple PRD](../Ripple_Handoff/Ripple_PRD.md)
- [Ripple Hero Motion](../Ripple_Handoff/Ripple_Hero_Motion.md)
- [Ripple History and Stats](../Ripple_Handoff/Ripple_History_Stats.md)
- [ADR-000: Architecture](ADR/ADR-000-architecture.md)
- [ADR-001: Persistence](ADR/ADR-001-persistence.md)
- [ADR-002: HealthKit](ADR/ADR-002-healthkit.md)
- [ADR-003: Live Activity](ADR/ADR-003-live-activity.md)
- [ADR-004: Focus Filter](ADR/ADR-004-focus-filter.md)

## 18. Documentation maintenance

This document and [Ripple Android Architecture](ANDROID_ARCHITECTURE.md) are maintained as a pair. They describe separate implementations, but shared product behavior and cross-platform capability changes must not silently diverge.

### Source-of-truth precedence

When sources disagree, use this order:

1. `AGENTS.md` for repository process, architecture boundaries, bans, and shared design constraints.
2. The authoritative product specifications: [Ripple PRD](../Ripple_Handoff/Ripple_PRD.md), [Ripple Hero Motion](../Ripple_Handoff/Ripple_Hero_Motion.md), and [Ripple History and Stats](../Ripple_Handoff/Ripple_History_Stats.md).
3. An approved ADR for a deliberate architectural exception or dependency decision.
4. The relevant platform architecture document.
5. The implementation and tests, which reveal current behavior and must be brought back into agreement when they drift.

If a product or architecture decision changes, update the applicable specification and both architecture documents before considering the implementation change complete.

### Changes that require a documentation review

Review the two architecture documents whenever a change affects:

- domain entities, value types, goal formulas, units, use cases, ports, or source attribution;
- persistence models, migrations, stores, sync/conflict behavior, soft deletion, export, or backup;
- HealthKit/Health Connect projection, authorization, notification scheduling, or background work;
- widgets, Watch/Wear surfaces, App Intents/App Actions, shortcuts, or notification actions;
- package/module boundaries, composition roots, dependencies, deployment targets, or concurrency rules;
- Today hero behavior, motion, reduced motion, History, Stats, navigation, accessibility, or localization;
- platform scope, release requirements, security, privacy, or testing obligations.

Platform-only changes still require checking the other document. If the shared contract is unchanged, record the platform-specific nature in the relevant timeline entry.

### Required update workflow

1. Read both architecture documents and the affected source specification before editing code or architecture.
2. Identify whether the change is shared, iOS-only, Android-only, or a change to the product contract.
3. Update the relevant architecture sections in the same change as the implementation or ADR.
4. Update `Document version` and `Last verified` in every document that changed.
5. Append one immutable row to the changed document's timeline. New rows go at the bottom; historical rows are not rewritten or deleted.
6. If the shared contract changed, update both documents and add corresponding timeline rows with the same release/change reference.
7. Verify Markdown links, headings, code examples, and relevant tests/builds. A documentation-only correction still runs whitespace/link checks.
8. Commit the documentation with the implementation/ADR, or as a separate documentation commit when no code changed.

### Documentation versioning

Use semantic document versions independently from the app version:

- **MAJOR**: incompatible architecture, scope, data, or public contract change.
- **MINOR**: new capability, platform surface, module boundary, or normative requirement that remains compatible.
- **PATCH**: factual correction, wording clarification, link correction, formatting, or example update with no contract change.

The timeline is the audit trail. Each row records the document version, date, change, and impact. Do not combine unrelated changes into an unexplained version bump.

### Synchronized-document checklist

Before merging an architecture-affecting change, confirm:

- [ ] The source specification or ADR is updated when required.
- [ ] The iOS document reflects the current Swift implementation.
- [ ] The Android document reflects the current Android contract or explicitly records that Android is unaffected.
- [ ] Shared use cases, units, sources, permissions, and feature names mean the same thing in both documents.
- [ ] Platform-specific UI/workflow differences are intentional and documented rather than treated as defects.
- [ ] The new timeline entry is present and the version/date metadata is current.

## 19. Timeline

Newest entries are appended at the bottom. Historical entries are immutable.

| Version | Date | Change | Impact |
| --- | --- | --- | --- |
| 1.0.0 | 2026-09-07 | Initial complete Swift/SwiftUI architecture document created from the repository specifications and implementation. | Establishes the iOS layering, persistence, use-case, platform, UI, motion, and testing baseline. |
| 1.1.0 | 2026-09-07 | Added the paired-document maintenance contract, semantic document versioning, synchronized-document checklist, and immutable timeline. | Architecture changes now require an explicit documentation review and versioned audit entry. |
