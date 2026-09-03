# Ripple Onboarding, HealthKit, and Notification Authorization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Ripple onboarding visually polished, use an explicitly authorized Apple Health weight for the calculated water goal, and request notification permission through a clear user action without implicit prompts.

**Architecture:** Keep framework access in RippleData adapters behind RippleDomain ports. Add focused domain authorization use cases and inject them through `UseCases`; the onboarding view model coordinates those use cases, persists the existing `Profile.bodyMassKg` snapshot through `UpdateProfile`, and recalculates the existing goal through `UpdateGoal`. Replace the scheduler’s implicit notification request with an injected authorization-status check.

**Tech Stack:** Swift 6.2 language mode, SwiftUI, `@Observable`/`@MainActor`, SwiftData, HealthKit, UserNotifications, Swift Testing, and existing RippleUI glass/motion tokens.

**Spec:** `Docs/superpowers/specs/2026-09-03-onboarding-health-notifications-design.md`

## Global Constraints

- Minimum OS is iOS/watchOS/macOS/tvOS/visionOS 26.0; do not add an older deployment fallback.
- Use Swift and SwiftUI only; no UIKit layout, SpriteKit, Metal, Lottie, video UI, `ObservableObject`, or Combine view state.
- Use Swift 6 strict concurrency; package targets remain Swift language mode v6 and RippleFeatures remains default-isolated to `MainActor`.
- HealthKit is a projection/input adapter, never Ripple’s source of truth; SwiftData remains the persisted source of truth.
- RippleFeatures may not import HealthKit or UserNotifications and must not contain `#if os()` business rules.
- All user-facing copy must be localized in the existing DE/EN string catalog; no English hardcodes in the DE locale.
- Use existing RippleUI colors, typography, spacing, radii, and motion tokens; no magic colors, custom fonts, heavy shadows, or extra accents.
- Onboarding remains five pages and every page except Units is skippable.
- HealthKit read denial and an empty read result must not be conflated; the app must never infer read authorization from `authorizationStatus(for:)`.
- Notification authorization is requested only after explanatory UI and an explicit user action; scheduling must never request permission.
- Every new domain behavior gets a Swift Testing test, and all four package test suites plus the iOS build must pass before handoff.

---

## File map

### Domain

- Create `Packages/RippleDomain/Sources/RippleDomain/Entities/NotificationAuthorizationStatus.swift` for the Sendable system-status value and its `isAllowed` projection.
- Create `Packages/RippleDomain/Sources/RippleDomain/Ports/NotificationAuthorizing.swift` for notification permission/status access.
- Modify `Packages/RippleDomain/Sources/RippleDomain/Ports/HealthAuthorizing.swift` to expose body-mass read authorization and latest body mass.
- Create `Packages/RippleDomain/Sources/RippleDomain/UseCases/RequestHealthReadAccess.swift`, `RequestHealthWaterWrite.swift`, and `RequestNotificationAuthorization.swift` for feature-facing authorization operations.
- Modify `Packages/RippleDomain/Sources/RippleDomain/UseCases/UseCases.swift` to expose the three authorization use cases while preserving default construction for existing tests.
- Modify `Packages/RippleDomain/Sources/RippleDomain/Fakes/NoOpAdapters.swift` and create `Packages/RippleDomain/Tests/RippleDomainTests/AuthorizationUseCaseTests.swift` for deterministic tests.
- Keep `CalculateGoal.swift` and `UpdateGoal.swift` as the only goal formula/persistence path; no duplicate onboarding formula.

### Data

- Modify `Packages/RippleData/Sources/RippleData/Health/HealthKitClient.swift` and `HealthProjector.swift` for body-mass reads.
- Create `Packages/RippleData/Sources/RippleData/Notifications/NotificationAuthorizer.swift` for `UNUserNotificationCenter` status/request mapping.
- Modify `Packages/RippleData/Sources/RippleData/Notifications/ReminderScheduler.swift` to accept a `NotificationAuthorizing` dependency and never call `requestAuthorization`.
- Modify `Packages/RippleData/Sources/RippleData/RippleBootstrap.swift` to share one notification authorizer between use cases and the scheduler.
- Modify `Packages/RippleData/Tests/RippleDataTests/SwiftDataStoreTests.swift` with an authorization-injection test.
- Modify `Apps/RippleiOS/RippleiOS.entitlements`, `Apps/RipplewatchOS/RipplewatchOS.entitlements`, and the Health usage-description entries in `Ripple.xcodeproj/project.pbxproj`.

### Features and UI

- Create `Packages/RippleFeatures/Sources/RippleFeatures/Onboarding/OnboardingViewModel.swift` by moving the model out of the current view file and adding Health/notification state.
- Replace `Packages/RippleFeatures/Sources/RippleFeatures/Onboarding/OnboardingView.swift` with a thin composition view containing the footer/progress layout.
- Create `Packages/RippleFeatures/Sources/RippleFeatures/Onboarding/OnboardingPages.swift` for the five page-specific view types.
- Modify `Packages/RippleFeatures/Sources/RippleFeatures/Shared/L10n.swift` and `Packages/RippleFeatures/Sources/RippleFeatures/Resources/Localizable.xcstrings` for all new DE/EN copy.
- Create `Packages/RippleUI/Sources/RippleUI/Components/OnboardingArtwork.swift` and add named onboarding artwork dimensions to `Packages/RippleUI/Sources/RippleUI/Tokens/RippleLayout.swift`.
- Create `Packages/RippleFeatures/Tests/RippleFeaturesTests/OnboardingViewModelTests.swift` for Health, fallback, and notification state behavior.

---

### Task 1: Add domain authorization contracts and use cases

**Files:**
- Create: `Packages/RippleDomain/Sources/RippleDomain/Entities/NotificationAuthorizationStatus.swift`
- Create: `Packages/RippleDomain/Sources/RippleDomain/Ports/NotificationAuthorizing.swift`
- Modify: `Packages/RippleDomain/Sources/RippleDomain/Ports/HealthAuthorizing.swift`
- Create: `Packages/RippleDomain/Sources/RippleDomain/UseCases/RequestHealthReadAccess.swift`
- Create: `Packages/RippleDomain/Sources/RippleDomain/UseCases/RequestHealthWaterWrite.swift`
- Create: `Packages/RippleDomain/Sources/RippleDomain/UseCases/RequestNotificationAuthorization.swift`
- Modify: `Packages/RippleDomain/Sources/RippleDomain/UseCases/UseCases.swift`
- Modify: `Packages/RippleDomain/Sources/RippleDomain/Fakes/NoOpAdapters.swift`
- Test: `Packages/RippleDomain/Tests/RippleDomainTests/AuthorizationUseCaseTests.swift`

**Interfaces:**
- `HealthAuthorizing` produces `requestBodyMassRead() async -> Bool`, `latestBodyMassKg() async -> Double?`, `requestWaterWrite() async -> Bool`, and the existing workout/status methods.
- `NotificationAuthorizationStatus` has cases `.notDetermined`, `.denied`, `.authorized`, `.provisional`, and `.ephemeral`; only the last three have `isAllowed == true`.
- `NotificationAuthorizing` produces `status() async -> NotificationAuthorizationStatus` and `requestAuthorization() async -> NotificationAuthorizationStatus`.
- `RequestHealthReadAccess.run() async -> Double?` validates that the adapter result is finite and greater than zero.
- `RequestHealthWaterWrite.run() async -> Bool` delegates exactly once.
- `RequestNotificationAuthorization.status() async -> NotificationAuthorizationStatus` reads without prompting; `.run() async -> NotificationAuthorizationStatus` performs the explicit request operation.
- `UseCases.assemble` gains `notificationAuthorizing: any NotificationAuthorizing = NoOpNotificationAuthorizing()` so existing package tests remain source-compatible.

- [ ] **Step 1: Add the failing domain tests.**

```swift
@Suite("Authorization use cases")
struct AuthorizationUseCaseTests {
    @Test("Health read returns a valid body mass")
    func healthReadReturnsBodyMass() async {
        let health = NoOpHealthAuthorizing(bodyMassKg: 70)
        let sut = RequestHealthReadAccess(healthAuthorizing: health)

        #expect(await sut.run() == 70)
    }

    @Test("Health read rejects missing and invalid body mass")
    func healthReadRejectsInvalidValues() async {
        let missing = RequestHealthReadAccess(
            healthAuthorizing: NoOpHealthAuthorizing(bodyMassKg: nil)
        )
        let invalid = RequestHealthReadAccess(
            healthAuthorizing: NoOpHealthAuthorizing(bodyMassKg: .infinity)
        )

        #expect(await missing.run() == nil)
        #expect(await invalid.run() == nil)
    }

    @Test("Notification status reads without prompting")
    func notificationStatusDoesNotPrompt() async {
        let sut = RequestNotificationAuthorization(
            authorizing: NoOpNotificationAuthorizing(current: .denied)
        )

        #expect(await sut.status() == .denied)
    }
}
```

- [ ] **Step 2: Run the focused tests and verify they fail because the contracts/types do not exist.**

Run: `swift test --package-path Packages/RippleDomain --filter AuthorizationUseCaseTests`

Expected: FAIL with missing type/protocol or initializer diagnostics.

- [ ] **Step 3: Implement the contracts and use cases.**

```swift
public enum NotificationAuthorizationStatus: String, Sendable, Hashable, Codable, CaseIterable {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral

    public var isAllowed: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral:
            true
        case .notDetermined, .denied:
            false
        }
    }
}

public protocol NotificationAuthorizing: Sendable {
    func status() async -> NotificationAuthorizationStatus
    func requestAuthorization() async -> NotificationAuthorizationStatus
}
```

Extend `HealthAuthorizing` with:

```swift
func requestBodyMassRead() async -> Bool
func latestBodyMassKg() async -> Double?
```

Implement `RequestHealthReadAccess` so it calls `requestBodyMassRead`, then
reads and validates `latestBodyMassKg`; do not add formula logic there. Add
the three use-case properties to `UseCases`, instantiate them in `assemble`,
and add `NoOpNotificationAuthorizing` plus body-mass properties to the
existing no-op Health authorizer.

- [ ] **Step 4: Run the focused tests and verify they pass.**

Run: `swift test --package-path Packages/RippleDomain --filter AuthorizationUseCaseTests`

Expected: PASS with all authorization tests green.

- [ ] **Step 5: Commit the domain boundary.**

```bash
git add Packages/RippleDomain
git commit -m "feat: add authorization use cases"
```

---

### Task 2: Implement the HealthKit body-mass adapter

**Files:**
- Modify: `Packages/RippleData/Sources/RippleData/Health/HealthKitClient.swift`
- Modify: `Packages/RippleData/Sources/RippleData/Health/HealthProjector.swift`
- Test: the conditional HealthKit branch is verified by the iOS build in Task 8; domain behavior is covered by `AuthorizationUseCaseTests.swift`.

**Interfaces:**
- `HealthKitClient.requestBodyMassRead() async -> Bool` requests read access for only the body-mass quantity type.
- `HealthKitClient.latestBodyMassKg() async -> Double?` executes a descending end-date `HKSampleQuery`, converts the first `HKQuantitySample` with `HKUnit.gramUnit(with: .kilo)`, and returns nil on unavailable HealthKit, query error, missing sample, or invalid value.
- `HealthAuthorizer` forwards both methods under its existing iOS/watchOS conditional; non-HealthKit platforms return false/nil.

- [ ] **Step 1: Add the adapter implementation.**

In `HealthKitClient`, add:

```swift
private var bodyMassType: HKQuantityType? {
    HKQuantityType.quantityType(forIdentifier: .bodyMass)
}

func requestBodyMassRead() async -> Bool {
    guard HKHealthStore.isHealthDataAvailable(), let bodyMassType else {
        return false
    }

    do {
        try await store.requestAuthorization(toShare: [], read: [bodyMassType])
        return true
    } catch {
        return false
    }
}
```

Use a checked continuation for the sample query, sort by
`HKSampleSortIdentifierEndDate` descending, limit to one sample, and return:

```swift
let kilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
return kilograms.isFinite && kilograms > 0 ? kilograms : nil
```

Forward the methods from `HealthAuthorizer`; leave existing Dietary Water
projection and workout behavior unchanged.

- [ ] **Step 2: Run RippleData tests and compile the HealthKit adapter.**

Run: `swift test --package-path Packages/RippleData`

Expected: package tests PASS on the host; the package target compiles its
conditional HealthKit branch for the configured Apple SDK during the later
iOS build.

- [ ] **Step 3: Commit the HealthKit adapter.**

```bash
git add Packages/RippleData/Sources/RippleData/Health Packages/RippleData/Tests/RippleDataTests/SwiftDataStoreTests.swift
git commit -m "feat: read latest HealthKit body mass"
```

---

### Task 3: Make notification authorization explicit and scheduler-safe

**Files:**
- Create: `Packages/RippleData/Sources/RippleData/Notifications/NotificationAuthorizer.swift`
- Modify: `Packages/RippleData/Sources/RippleData/Notifications/ReminderScheduler.swift`
- Modify: `Packages/RippleData/Sources/RippleData/RippleBootstrap.swift`
- Modify: `Packages/RippleData/Tests/RippleDataTests/SwiftDataStoreTests.swift`

**Interfaces:**
- `NotificationAuthorizer` maps `UNAuthorizationStatus` to the domain enum and only calls `UNUserNotificationCenter.requestAuthorization(options: [.alert, .sound, .badge])` when the current status is `.notDetermined`.
- `ReminderScheduler.init(notificationAuthorizing: any NotificationAuthorizing = NotificationAuthorizer())` stores the dependency.
- `ReminderScheduler.reschedule` removes the existing identifier, checks `await notificationAuthorizing.status()`, and returns for any status where `isAllowed` is false. It must not call a request method.
- `RippleBootstrap.make` constructs one `NotificationAuthorizer`, injects it into `ReminderScheduler`, and passes it into `UseCases.assemble`.

- [ ] **Step 1: Add a test double proving scheduler rescheduling never prompts.**

```swift
actor RecordingNotificationAuthorizer: NotificationAuthorizing {
    let current: NotificationAuthorizationStatus
    private(set) var requestCount = 0

    init(current: NotificationAuthorizationStatus) {
        self.current = current
    }

    func status() async -> NotificationAuthorizationStatus { current }

    func requestAuthorization() async -> NotificationAuthorizationStatus {
        requestCount += 1
        return current
    }
}

@Test("Reminder rescheduling never requests notification authorization")
func schedulerDoesNotPrompt() async {
    let authorizer = RecordingNotificationAuthorizer(current: .notDetermined)
    let scheduler = ReminderScheduler(notificationAuthorizing: authorizer)

    await scheduler.reschedule(rule: .default, lastSip: nil)

    #expect(await authorizer.requestCount == 0)
}
```

- [ ] **Step 2: Run the new test and verify it fails because the scheduler has no injected authorizer.**

Run: `swift test --package-path Packages/RippleData --filter schedulerDoesNotPrompt`

Expected: FAIL with the missing initializer/dependency seam.

- [ ] **Step 3: Implement the authorizer and remove the implicit prompt.**

Map `.authorized`, `.provisional`, and `.ephemeral` to allowed domain
states; map `.notDetermined` and `.denied` directly. `requestAuthorization`
must first read `notificationSettings()`, return the current mapped state for
anything other than `.notDetermined`, then request and read settings again.

Replace the current block in `ReminderScheduler.reschedule` that requests
authorization with:

```swift
let authorization = await notificationAuthorizing.status()
guard authorization.isAllowed else { return }
```

Keep category registration in `RippleBootstrap.start()` before the app shows
onboarding. Do not add an app-owned permission alert or an UIApplication
settings URL to the feature package.

- [ ] **Step 4: Run Data tests and verify the no-prompt behavior passes.**

Run: `swift test --package-path Packages/RippleData --filter schedulerDoesNotPrompt`

Expected: PASS; the existing reminder-window tests remain PASS.

- [ ] **Step 5: Commit the notification boundary.**

```bash
git add Packages/RippleData/Sources/RippleData/Notifications Packages/RippleData/Sources/RippleData/RippleBootstrap.swift Packages/RippleData/Tests/RippleDataTests/SwiftDataStoreTests.swift
git commit -m "feat: make notification authorization explicit"
```

---

### Task 4: Add onboarding authorization state and Health-derived goal behavior

**Files:**
- Create: `Packages/RippleFeatures/Sources/RippleFeatures/Onboarding/OnboardingViewModel.swift`
- Modify: `Packages/RippleFeatures/Sources/RippleFeatures/Onboarding/OnboardingView.swift` to remove the model definition and retain only view composition during the UI task.
- Create: `Packages/RippleFeatures/Tests/RippleFeaturesTests/OnboardingViewModelTests.swift`

**Interfaces:**
- `HealthWeightState` is `Sendable, Equatable` with `.idle`, `.loading`, `.found`, and `.unavailable`.
- `OnboardingViewModel` exposes `page`, `pageCount` (5), `profile`, `weightText`, `healthWeightKg`, `healthWeightState`, `healthWrite`, `notificationStatus`, `isRequestingHealthWeight`, `isRequestingWaterWrite`, `isRequestingNotifications`, `isFinishing`, and `calculatedGoalMl`.
- `requestHealthWeight() async` calls `useCases.requestHealthReadAccess.run()`, stores a valid result in `profile.bodyMassKg`, formats it into the editable weight field, and otherwise sets `.unavailable` without asserting denial.
- `requestWaterWrite() async` calls `useCases.requestHealthWaterWrite.run()` and sets `healthWrite` to the returned value.
- `refreshNotificationStatus() async` calls `useCases.requestNotificationAuthorization.status()` without prompting.
- `requestNotifications() async` calls `.run()` and stores the returned status.
- `finish() async` is idempotent while `isFinishing` is true, saves profile/goal/reminder state through existing use cases/repositories, and never requests HealthKit or notification permission implicitly.

- [ ] **Step 1: Add failing onboarding model tests.**

```swift
@Suite("Onboarding")
@MainActor
struct OnboardingViewModelTests {
    @Test("Health weight populates the profile and calculated goal")
    func healthWeightCalculatesGoal() async {
        let model = OnboardingViewModel(useCases: makeUseCases(bodyMassKg: 70))

        await model.requestHealthWeight()

        #expect(model.healthWeightState == .found)
        #expect(model.profile.bodyMassKg == 70)
        #expect(model.calculatedGoalMl == 2300)
    }

    @Test("Missing Health weight keeps the manual fallback available")
    func missingHealthWeightUsesFallback() async {
        let model = OnboardingViewModel(useCases: makeUseCases(bodyMassKg: nil))

        await model.requestHealthWeight()

        #expect(model.healthWeightState == .unavailable)
        #expect(model.profile.bodyMassKg == nil)
        #expect(model.calculatedGoalMl == 2000)
    }

    @Test("Denied notifications do not block onboarding")
    func deniedNotificationsDoNotBlockFinish() async throws {
        let settings = InMemorySettingsRepository()
        let model = OnboardingViewModel(
            useCases: makeUseCases(
                bodyMassKg: nil,
                notificationStatus: .denied,
                settings: settings
            )
        )

        await model.requestNotifications()
        await model.finish()
        let profile = try await settings.profile()
        let rule = try await settings.reminderRule()

        #expect(model.notificationStatus == .denied)
        #expect(profile.onboardingCompleted)
        #expect(!profile.remindersEnabled)
        #expect(!rule.enabled)
    }

    private func makeUseCases(
        bodyMassKg: Double?,
        notificationStatus: NotificationAuthorizationStatus = .notDetermined,
        settings: InMemorySettingsRepository = InMemorySettingsRepository()
    ) -> UseCases {
        UseCases.assemble(
            intakeRepository: InMemoryIntakeRepository(),
            settingsRepository: settings,
            widgetReloading: NoOpWidgetReloading(),
            health: FakeHealthProjector(),
            reminders: NoOpReminderScheduling(),
            workouts: NoOpWorkoutReading(),
            healthAuthorizing: NoOpHealthAuthorizing(bodyMassKg: bodyMassKg),
            notificationAuthorizing: NoOpNotificationAuthorizing(current: notificationStatus)
        )
    }
}
```

- [ ] **Step 2: Run the focused tests and verify they fail because the new model API is absent.**

Run: `swift test --package-path Packages/RippleFeatures --filter OnboardingViewModelTests`

Expected: FAIL with missing `OnboardingViewModel` state/method diagnostics.

- [ ] **Step 3: Implement the model and persistence flow.**

Keep the model `@MainActor @Observable`, with `useCases` marked
`@ObservationIgnored`. Compute the preview from a candidate profile so the
manual text field updates the goal before finish:

```swift
public var calculatedGoalMl: Int {
    var candidate = profile
    candidate.bodyMassKg = parsedWeightKg ?? healthWeightKg
    return useCases.calculateGoal.run(profile: candidate, workoutMinutes: 0).value
}
```

Validate manual input by replacing commas with periods, requiring a finite
positive `Double`, and prefer the parsed field value over the stored Health
value only when the user has entered a valid value. On a successful Health
read, populate the field with a locale-aware numeric format and set the
profile snapshot.

In `finish`, resolve the weight, set `profile.healthWriteEnabled`, set
`profile.remindersEnabled = notificationStatus.isAllowed`, mark onboarding
complete, run `seedDefaultsIfNeeded`, `UpdateProfile`, then `UpdateGoal` in
calculated mode when a weight exists and manual mode with 2,000 ml otherwise.
Read the existing reminder rule, set `enabled` to `notificationStatus.isAllowed`,
save it, and invoke `RescheduleReminders`. Use `defer` to clear
`isFinishing`; do not call any authorization request from this method.

- [ ] **Step 4: Run the focused tests and verify they pass.**

Run: `swift test --package-path Packages/RippleFeatures --filter OnboardingViewModelTests`

Expected: PASS for Health-derived goal, missing-data fallback, and denied
notification completion.

- [ ] **Step 5: Commit the onboarding model behavior.**

```bash
git add Packages/RippleFeatures/Sources/RippleFeatures/Onboarding/OnboardingViewModel.swift Packages/RippleFeatures/Tests/RippleFeaturesTests/OnboardingViewModelTests.swift
git commit -m "feat: personalize onboarding from Health weight"
```

---

### Task 5: Add the reusable RippleUI onboarding artwork

**Files:**
- Create: `Packages/RippleUI/Sources/RippleUI/Components/OnboardingArtwork.swift`
- Modify: `Packages/RippleUI/Sources/RippleUI/Tokens/RippleLayout.swift`

**Interfaces:**
- `OnboardingArtwork(stage: Int)` is a public SwiftUI view used by RippleFeatures.
- The artwork uses named `RippleLayout.onboardingArtworkWidth` and `onboardingArtworkHeight` values, `GlassShape`, and `WaterFill` only.
- It renders a flat water surface with stage-dependent level; it has no `TimelineView`, idle sine wave, circular progress, `drop.fill`, pour stream, or tilt.

- [ ] **Step 1: Implement the artwork with reduced-motion handling.**

Add named layout tokens in `RippleLayout` and animate the private level state
with `RippleMotion.springLiquid` when the stage changes. Use
`accessibilityReduceMotion` to assign the target directly or use
`RippleMotion.reduceMotionCrossfade`. Keep the outer artwork compact enough
for iPhone portrait and allow its parent scroll view to handle XXXL content.

The public shape should follow this interface:

```swift
public struct OnboardingArtwork: View {
    public let stage: Int

    public init(stage: Int) {
        self.stage = stage
    }

    public var body: some View {
        // Stage-specific flat WaterFill inside GlassShape.
    }
}
```

- [ ] **Step 2: Add light/dark, XXXL, and Reduce Motion previews.**

Create previews for the first, Health/goal, and final stages with both color
schemes and `.dynamicTypeSize(.xxxLarge)`. The preview must show the vessel
without an extra accent color or heavy shadow.

- [ ] **Step 3: Build RippleUI and verify the artwork compiles.**

Run: `swift test --package-path Packages/RippleUI`

Expected: PASS with the new public component compiled into the package.

- [ ] **Step 4: Commit the UI primitive.**

```bash
git add Packages/RippleUI/Sources/RippleUI/Components/OnboardingArtwork.swift Packages/RippleUI/Sources/RippleUI/Tokens/RippleLayout.swift
git commit -m "feat: add onboarding glass artwork"
```

---

### Task 6: Rebuild the onboarding page composition and localize the copy

**Files:**
- Modify: `Packages/RippleFeatures/Sources/RippleFeatures/Onboarding/OnboardingView.swift`
- Create: `Packages/RippleFeatures/Sources/RippleFeatures/Onboarding/OnboardingPages.swift`
- Modify: `Packages/RippleFeatures/Sources/RippleFeatures/Shared/L10n.swift`
- Modify: `Packages/RippleFeatures/Sources/RippleFeatures/Resources/Localizable.xcstrings`

**Interfaces:**
- `OnboardingView` remains the public entry point and accepts `OnboardingViewModel` plus `onDone`.
- `OnboardingPages.swift` contains separate view types for Welcome, Units, Health/goal, Containers, and Reminders/Health write; each receives only the model values/bindings it reads.
- Permission buttons call `requestHealthWeight`, `requestWaterWrite`, and `requestNotifications` through `Task` and expose disabled/progress/completed states.
- The footer owns Skip/Continue/Done; Continue advances pages and Done awaits `finish()` before `onDone()`.

- [ ] **Step 1: Add the new DE/EN catalog entries.**

Add these exact DE/EN entries to the catalog; preserve existing keys and the
existing `nice Ripple`/goal copy:

| English source key | German localization |
|---|---|
| Make Ripple yours. | Mach Ripple zu deinem. |
| Use Apple Health weight | Gewicht aus Apple Health verwenden |
| Ripple can use your latest Health weight to suggest a personal daily goal. | Ripple kann dein aktuelles Health-Gewicht für ein persönliches Tagesziel verwenden. |
| No weight found in Health. You can enter it below instead. | Kein Gewicht in Health gefunden. Du kannst es stattdessen unten eingeben. |
| Weight in kg | Gewicht in kg |
| Calculated daily goal | Berechnetes Tagesziel |
| Based on your weight | Basierend auf deinem Gewicht |
| Your goal, your way | Dein Ziel, dein Weg |
| Allow reminders | Erinnerungen erlauben |
| Reminders stay quiet outside your day. | Außerhalb deines Tages bleiben Erinnerungen ruhig. |
| You can change this later in Settings. | Du kannst das später in den Einstellungen ändern. |
| Reminders enabled | Erinnerungen aktiviert |
| Notifications are off. You can change this in Settings. | Benachrichtigungen sind aus. Du kannst das in den Einstellungen ändern. |
| Allow Ripple to write water to Health | Ripple erlauben, Wasser an Health zu schreiben |
| Water logging in Health is optional. | Wasser in Health zu protokollieren ist optional. |
| Water write enabled | Wasser-Schreiben aktiviert |
| Use Health weight | Health-Gewicht verwenden |
| Not now | Nicht jetzt |

Add an L10n helper for the
progress label using the existing `%lld of 5` catalog key rather than
hardcoding English in the view.

- [ ] **Step 2: Replace the single-file page builders with focused View types.**

Use a `ScrollView` for page content, `OnboardingArtwork(stage:)` above the
page content, `GlassCard` for Health/reminder permission surfaces, and the
existing RippleUI tokens for all spacing and typography. Keep the progress
indicator accessible as one element, and use a bottom action area that
respects the safe area.

The Health page must show the calculated goal from `model.calculatedGoalMl`
and a manual editable fallback. The Health button’s result copy must say
“no weight found” when there is no sample; it must not say “Health denied.”
The reminders page must explain the value before its explicit permission
button. When `notificationStatus == .denied`, show the Settings guidance and
do not start another request. The optional Health write button is separate
from the notification button.

Use an explicit transition on the page content:

```swift
OnboardingPageContent(model: model)
    .id(model.page)
    .transition(
        reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
    )
```

Wrap the page mutation in `withAnimation(reduceMotion ? nil : RippleMotion.springSnappy)`.
Do not use a bare `.animation` modifier that animates permission state or
text-field changes unintentionally.

- [ ] **Step 3: Add previews for representative onboarding states.**

Preview Welcome, Health with a 70 kg Health result, Health with no result,
Notifications denied, and the final page in light/dark, XXXL, and Reduce
Motion configurations. Use `RippleRuntime.preview` or an in-memory use case
container; do not create a second persistence path.

- [ ] **Step 4: Run RippleFeatures tests and verify the view package compiles.**

Run: `swift test --package-path Packages/RippleFeatures`

Expected: PASS with existing view-model tests and the new onboarding tests.

- [ ] **Step 5: Commit the onboarding UI.**

```bash
git add Packages/RippleFeatures/Sources/RippleFeatures/Onboarding Packages/RippleFeatures/Sources/RippleFeatures/Shared/L10n.swift Packages/RippleFeatures/Sources/RippleFeatures/Resources/Localizable.xcstrings
git commit -m "feat: redesign onboarding permissions flow"
```

---

### Task 7: Add HealthKit capability and update permission copy

**Files:**
- Modify: `Apps/RippleiOS/RippleiOS.entitlements`
- Modify: `Apps/RipplewatchOS/RipplewatchOS.entitlements`
- Modify: `Ripple.xcodeproj/project.pbxproj`

**Interfaces:**
- iOS and watchOS entitlements contain `com.apple.developer.healthkit = true`.
- iOS Debug/Release Health share usage descriptions mention reading weight and today’s workouts only when opted in; update usage continues to describe Dietary Water writes.
- watchOS Debug/Release descriptions mention the supported Health reads and Dietary Water writes without adding unrelated Health data types.

- [ ] **Step 1: Add the entitlements and usage descriptions.**

Add this key to both Health-capable entitlement files:

```xml
<key>com.apple.developer.healthkit</key>
<true/>
```

Update the iOS share description to:

```text
Ripple reads your weight and today’s workouts only if you opt in, to calculate a personal water goal. This is not medical advice.
```

Keep `NSHealthUpdateUsageDescription` focused on saving logged drinks as
Dietary Water in Health. Apply equivalent copy to both watch configurations.

- [ ] **Step 2: Validate the project settings without changing unrelated dirty files.**

Run: `rg -n -C 2 'com.apple.developer.healthkit|NSHealthShareUsageDescription|NSHealthUpdateUsageDescription' Apps/RippleiOS/RippleiOS.entitlements Apps/RipplewatchOS/RipplewatchOS.entitlements Ripple.xcodeproj/project.pbxproj`

Expected: the capability appears in both entitlement files and the updated
share/update descriptions appear in both iOS and watchOS configurations.

- [ ] **Step 3: Commit only the permission configuration.**

```bash
git add Apps/RippleiOS/RippleiOS.entitlements Apps/RipplewatchOS/RipplewatchOS.entitlements Ripple.xcodeproj/project.pbxproj
git commit -m "chore: configure HealthKit onboarding permissions"
```

---

### Task 8: Run the complete verification pass

**Files:**
- Modify: none; verification uses the committed changes from Tasks 1–7.

**Interfaces:**
- All four Swift packages compile with the new domain/data/UI boundaries.
- The iOS app launches with onboarding and can complete without HealthKit or notification authorization.
- Permission prompts are user-initiated, and a denied notification status does not schedule a request or block completion.

- [ ] **Step 1: Run every package test suite.**

Run:

```bash
swift test --package-path Packages/RippleDomain
swift test --package-path Packages/RippleData
swift test --package-path Packages/RippleFeatures
swift test --package-path Packages/RippleUI
```

Expected: all tests PASS.

- [ ] **Step 2: Build the iOS scheme without code signing.**

Run:

```bash
xcodebuild -project Ripple.xcodeproj -scheme RippleiOS -configuration Debug -sdk iphonesimulator build CODE_SIGNING_ALLOWED=NO
```

Expected: build succeeds with no Swift 6 concurrency diagnostics, no
missing HealthKit usage-description/capability errors, and no localization
resource errors.

- [ ] **Step 3: Inspect the onboarding states.**

Use a current iOS simulator/device and verify:

- Welcome, Health, and Reminders pages have the glass artwork and no idle wave.
- Health button shows the system HealthKit sheet only after tapping it; a 70 kg sample produces a 2,300 ml preview.
- No Health sample leaves the manual field and 2,000 ml fallback available.
- Notification sheet appears only after tapping Allow reminders; a denied status shows Settings guidance and no repeat prompt.
- Finish completes without either permission and leaves reminders/Health write disabled.
- Light/dark mode, Dynamic Type XXXL, VoiceOver labels, and Reduce Motion remain legible and stable.

- [ ] **Step 4: Check the final diff and preserve unrelated work.**

Run: `git diff --check && git status --short`

Expected: no whitespace errors; only onboarding/HealthKit/notification files
from this plan are changed by the implementation, while the pre-existing
vision, history, `.gitignore`, and release changes remain untouched.
