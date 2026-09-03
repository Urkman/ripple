# Ripple onboarding, HealthKit, and notification authorization

## Status

Approved in conversation on 2026-09-03. This design is the implementation
boundary for the onboarding revision; it does not expand the product beyond
the existing five-page onboarding, HealthKit Dietary Water projection, and
optional workout goal boost.

## Goals

- Make onboarding feel like Ripple: calm, tactile, glass-led, and legible in
  light mode, dark mode, Dynamic Type through XXXL, and Reduce Motion.
- Ask for the minimum HealthKit access needed to personalize the daily goal.
- Use the latest available Apple Health body-mass sample as the onboarding
  weight when the user opts in.
- Request notification permission at a clear, user-initiated point and never
  prompt as a side effect of saving settings or logging water.
- Preserve the existing manual goal fallback and optional Dietary Water write.
- Keep HealthKit and UserNotifications behind RippleDomain ports and
  RippleData adapters. RippleFeatures must not import either framework.

## User flow

The onboarding remains five pages:

1. **Welcome** — Ripple’s glass-and-water metaphor and a concise explanation
   of logging from the app and system surfaces.
2. **Units** — milliliters or fluid ounces, with the locale default selected.
3. **Health and goal** — an explanation of using Apple Health weight, an
   explicit `Use Apple Health weight` action, a manual weight fallback, and a
   live calculated-goal preview. The Health read request is made only from the
   explicit action. If no weight is returned, the UI says that no weight was
   available and leaves the manual field usable; it does not claim that the
   user denied read access.
4. **Containers** — explains the seeded quick-add containers without adding
   another permission prompt.
5. **Reminders and Health write** — explains reminders, provides an explicit
   `Allow reminders` action, and provides a separate optional action to allow
   Ripple to write logged water to Dietary Water in Health.

Every page except Units remains skippable. Skipping the permission actions
keeps the app fully usable. When onboarding finishes, reminders are enabled
only when the user has authorized them; Health water writing remains off
unless its explicit action succeeded.

## Visual design

`OnboardingArtwork` will be a reusable RippleUI component. It renders a
stylized `GlassShape` with a flat `WaterFill` level that changes per page. It
does not use `drop.fill`, a circular progress indicator, an idle wave, or a
TimelineView. The page content is presented in a scrollable layout with
RippleUI spacing, `GlassCard` surfaces, Ripple colors, a compact progress
indicator, and a bottom action area that respects the safe area.

Page changes use a short opacity/translation transition and the existing
snappy motion token. Reduce Motion removes the translation and cross-fades
the artwork/content over the reduced duration. Permission actions use a
snappy control animation and expose loading/complete states without making
the system permission sheet look like an app-owned modal.

The feature view will be split into dedicated `View` types for the page
content, footer, progress indicator, and page-specific sections. Each child
receives only the values it renders. User-facing copy will be added to the
existing DE/EN string catalog; no English literals will be used as the DE
fallback.

## HealthKit data flow

The existing `Profile.bodyMassKg` remains the local snapshot used by
`CalculateGoal`; SwiftData remains the source of truth for Ripple’s settings.
The new flow is:

1. The Health page invokes a domain authorization use case.
2. The RippleData HealthKit adapter requests read access for
   `HKQuantityTypeIdentifier.bodyMass` only.
3. After the request, the adapter queries the newest body-mass sample,
   converts it to kilograms, and returns a positive finite value when one is
   available.
4. The onboarding model places that value in its weight field and profile
   snapshot. The preview uses `CalculateGoal`; final persistence goes through
   the existing `UpdateProfile` and `UpdateGoal` use cases.

Workout read access remains a separate opt-in in Settings. It is not silently
added to the onboarding request. Dietary Water write remains a separate,
explicit permission action.

Because HealthKit intentionally does not expose whether read access was
denied, an empty query result is treated only as “no weight available.” The
app will never use `authorizationStatus(for:)` to infer body-mass read
permission; that API is for sharing/write authorization.

### Domain changes

- Extend `HealthAuthorizing` with body-mass read authorization and latest body
  mass access.
- Add small domain authorization use cases for Health read, Health water
  write, and notification authorization so onboarding coordinates system
  access through `UseCases` rather than importing framework APIs.
- Add `NotificationAuthorizationStatus` and `NotificationAuthorizing` with
  `notDetermined`, `denied`, `authorized`, `provisional`, and `ephemeral`
  states. The allowed states are exposed through a small `isAllowed` helper.
- Add no new persisted fields or second settings store.

### Data changes

- `HealthKitClient` requests body-mass read access and queries the latest
  `HKQuantitySample` using a descending end-date sort.
- `HealthAuthorizer` maps the new port methods and retains existing water
  write/workout behavior.
- Add `NotificationAuthorizer` backed by
  `UNUserNotificationCenter.notificationSettings()` and
  `requestAuthorization(options:)`. It must return existing authorization
  state without prompting when the state is no longer `.notDetermined`.
- Add the HealthKit capability to the iOS and watchOS entitlements and update
  the Health share usage text to mention weight as well as workouts. Local
  notification permission does not require a new push entitlement.

## Notification flow

`RippleBootstrap` continues to register the notification category before the
app presents onboarding. The onboarding explanation precedes the explicit
button that calls the notification authorization use case. If the user
denies access, the page shows that it can be changed in system Settings and
does not retry the system prompt. If access is authorized or provisional,
the onboarding saves an enabled reminder rule and calls the existing
`RescheduleReminders` path after persistence.

`ReminderScheduler.reschedule` will remove pending requests, inspect current
notification settings, and return without scheduling when notifications are
not authorized. It will no longer call `requestAuthorization`. This prevents
profile saves, logs, undo, and onboarding completion from generating an
unexpected permission sheet.

## Failure handling

- HealthKit unavailable, request failure, no body-mass sample, or a nonfinite
  value leaves the app on the manual/default goal path.
- A HealthKit read denial is not surfaced as a definitive denial because
  HealthKit does not disclose that state for reads.
- Health water write failure leaves the Ripple log and onboarding completion
  intact; only the local write-enabled state remains false.
- Notification denial leaves reminders disabled and does not block onboarding.
- A failed settings save keeps the existing app behavior of best-effort
  completion, but the onboarding UI remains guarded by an `isFinishing` state
  so the completion action cannot be submitted repeatedly.

## Verification

- Add domain tests for authorization use cases using no-op/recording ports.
- Add onboarding view-model tests for manual fallback, Health weight goal
  preview, unavailable Health data, notification denial, and successful
  notification authorization.
- Keep and extend goal formula tests to prove the Health weight snapshot uses
  the existing `kg * 33`, rounded-to-50-ml behavior.
- Add a notification scheduler test double or focused test seam proving
  rescheduling never invokes a permission request.
- Run `swift test` for RippleDomain, RippleData, RippleFeatures, and RippleUI.
- Build the iOS target with Xcode and inspect onboarding in light/dark mode,
  Dynamic Type XXXL, Reduce Motion, and a HealthKit-capable signed device or
  simulator configuration.

## Files in scope

- `Ripple_Handoff/Ripple_PRD.md`
- `AGENTS.md` authorization use-case inventory
- `Packages/RippleDomain` authorization ports, status entity, use cases, and
  fakes/tests
- `Packages/RippleData` HealthKit and notification adapters, bootstrap, and
  tests
- `Packages/RippleFeatures/Sources/RippleFeatures/Onboarding` and its string
  catalog/tests
- `Packages/RippleUI` onboarding artwork/tokens/previews
- iOS/watchOS entitlements and HealthKit usage descriptions in the Xcode
  project
