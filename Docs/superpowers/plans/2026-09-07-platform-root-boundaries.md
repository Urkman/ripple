# Platform Root Boundaries Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move every Apple platform's root SwiftUI shell from `RippleFeatures` into its executable app target so platform-specific navigation and APIs are compiled only by the platform that owns them.

**Architecture:** `Apps/RippleiOS`, `Apps/RipplewatchOS`, `Apps/RipplemacOS`, `Apps/RippletvOS`, and `Apps/RipplevisionOS` will own `RootView`, `WatchRootView`, `MacRootView`, `TVRootView`, and `VisionRootView`. `RippleFeatures` will continue to own reusable feature screens and `@Observable` view models; `RippleUI` will continue to own reusable design-system components and platform adapters.

**Tech Stack:** Swift 6, SwiftUI, Swift Package Manager, Xcode project targets, `@Observable` view models, SwiftData-backed `UseCases` injection.

**Spec:** `AGENTS.md`, `Docs/ARCHITECTURE.md`, `Docs/ANDROID_ARCHITECTURE.md`

## Global Constraints

- Swift and SwiftUI only; no UIKit layout, SpriteKit, Metal, Lottie, or video UI.
- Apps remain composition roots and may wire dependencies and compose platform-local roots, but must not add business logic or a second persistence path.
- Every log continues through `LogIntake.run(amount:source:date:)` via the existing view models and use cases.
- Shared feature screens, view models, tokens, and motion remain in their existing packages.
- Platform conditionals remain only where a multiplatform package genuinely contains a platform adapter or shared platform-specific feature surface; they are removed from the relocated app roots.
- Preserve German/English localization, accessibility, Dynamic Type, Reduce Motion, and existing platform behavior.
- Update `Docs/ARCHITECTURE.md` for the module-boundary change, increment its semantic version, refresh `Last verified`, and append an immutable timeline row; record that the Android companion remains unaffected.

---

### Task 1: Move the iOS root shell into the iOS app target

**Files:**
- Create: `Apps/RippleiOS/RootView.swift`
- Delete: `Packages/RippleFeatures/Sources/RippleFeatures/Shared/RootView.swift`
- Modify: `Ripple.xcodeproj/project.pbxproj`

**Interfaces:**
- Consumes: Existing public `TodayView`, `HistoryCalendarView`, `StatsView`, `SettingsView`, `OnboardingView`, view models, `UseCases`, and `RippleUI` tokens.
- Produces: An app-local `RootView(useCases: UseCases)` used by `RippleiOSApp`.

- [x] Move the existing iOS root source into `Apps/RippleiOS/RootView.swift`.
- [x] Remove the `#if os(iOS)` branches now that the file is compiled only by the iOS target, preserving the four-tab and iPad layout behavior exactly.
- [x] Add the new file reference and source-build entry to the iOS group and iOS sources phase in `Ripple.xcodeproj/project.pbxproj`.
- [x] Verify `RippleiOSApp.swift` still resolves the app-local `RootView` without changing dependency injection.

### Task 2: Move the watchOS root shell into the watchOS app target

**Files:**
- Create: `Apps/RipplewatchOS/WatchRootView.swift`
- Delete: `Packages/RippleFeatures/Sources/RippleFeatures/Watch/WatchRootView.swift`
- Modify: `Ripple.xcodeproj/project.pbxproj`

**Interfaces:**
- Consumes: Existing public Watch feature views/view models, `UseCases`, and `RippleUI` watch components.
- Produces: An app-local `WatchRootView(useCases:initialPage:)` used by `RippleWatchApp`.

- [x] Move the existing watch root source into `Apps/RipplewatchOS/WatchRootView.swift`.
- [x] Remove its `#if os(watchOS)` wrapper without changing page selection, refresh, or demo-page behavior.
- [x] Add the new file reference and source-build entry to the watchOS group and watchOS sources phase.
- [x] Verify `RippleWatchApp.swift` still selects the app-local root in Debug and Release builds.

### Task 3: Move the macOS root shell and commands into the macOS app target

**Files:**
- Create: `Apps/RipplemacOS/MacRootView.swift`
- Delete: `Packages/RippleFeatures/Sources/RippleFeatures/Mac/MacRootView.swift`
- Modify: `Ripple.xcodeproj/project.pbxproj`

**Interfaces:**
- Consumes: Existing public Today, History, Stats, Settings views and view models, `UseCases`, and `RippleUI` tokens.
- Produces: App-local `MacRootView`, `RippleMacCommands`, and `MacMenuBarExtra` used by `RippleMacApp`.

- [x] Move the existing macOS root source into `Apps/RipplemacOS/MacRootView.swift`.
- [x] Remove its `#if os(macOS)` wrapper while preserving sidebar selection, menu-bar logging, ⌘N, and ⌘Z behavior.
- [x] Add the new file reference and source-build entry to the macOS group and macOS sources phase.
- [x] Verify `RippleMacApp.swift` still owns the command and menu-bar composition without adding business logic.

### Task 4: Move the tvOS root shell into the tvOS app target

**Files:**
- Create: `Apps/RippletvOS/TVRootView.swift`
- Delete: `Packages/RippleFeatures/Sources/RippleFeatures/TV/TVRootView.swift`
- Modify: `Ripple.xcodeproj/project.pbxproj`

**Interfaces:**
- Consumes: Existing `TodayViewModel`, `RippleHeroView`, `RippleUI` tokens, and `UseCases`.
- Produces: An app-local `TVRootView(useCases: UseCases)` used by `RippleTVApp`.

- [x] Move the existing tvOS root source into `Apps/RippletvOS/TVRootView.swift`.
- [x] Remove its `#if os(tvOS)` wrapper without changing the minimal hero or predefined logging actions.
- [x] Add the new file reference and source-build entry to the tvOS group and tvOS sources phase.
- [x] Verify `RippleTVApp.swift` still presents the app-local root.

### Task 5: Move the visionOS root shell into the visionOS app target

**Files:**
- Create: `Apps/RipplevisionOS/VisionRootView.swift`
- Delete: `Packages/RippleFeatures/Sources/RippleFeatures/Vision/VisionRootView.swift`
- Modify: `Packages/RippleFeatures/Sources/RippleFeatures/Shared/L10n.swift`
- Modify: `Packages/RippleFeatures/Sources/RippleFeatures/Today/CustomAmountSheet.swift`
- Modify: `Ripple.xcodeproj/project.pbxproj`

**Interfaces:**
- Consumes: Existing shared feature views/view models, `VisionNavigationOrnament`, `VisionLogOrnament`, `UseCases`, and `RippleUI` tokens.
- Produces: An app-local `VisionRootView(useCases: UseCases)` used by `RippleVisionApp`.

- [x] Move the existing visionOS root source into `Apps/RipplevisionOS/VisionRootView.swift`.
- [x] Remove its `#if os(visionOS)` wrapper without changing ornaments, window sizing, scene-phase refresh, custom amount sheet, or shared feature navigation.
- [x] Expose only the localization entry point and reusable custom amount sheet API needed by the app-local root; keep their implementations and resource bundle in `RippleFeatures`.
- [x] Add the new file reference and source-build entry to the visionOS group and visionOS sources phase.
- [x] Verify `RippleVisionApp.swift` still presents the app-local root.

### Task 6: Align architecture documentation and verify the refactor

**Files:**
- Modify: `Docs/ARCHITECTURE.md`
- Modify: `Docs/superpowers/plans/2026-09-07-platform-root-boundaries.md`

**Interfaces:**
- Consumes: The final source layout and the unchanged Android architecture contract.
- Produces: Documentation stating that app targets own platform root shells and packages own reusable feature surfaces.

- [x] Update the package responsibility, repository layout, feature-layer, and platform-architecture sections to distinguish app-local roots from package-owned screens/view models.
- [x] Increment `Docs/ARCHITECTURE.md` from version `1.1.0` to `1.2.0`, keep `Last verified` at `2026-09-07`, and append one immutable timeline row stating that this is an Apple-platform-only boundary refactor and Android is unaffected.
- [x] Run `rg` to confirm the five root files no longer exist under `Packages/RippleFeatures` and no app-local root contains `#if os(...)`.
- [x] Run `swift test --package-path Packages/RippleDomain`, `swift test --package-path Packages/RippleData`, `swift test --package-path Packages/RippleIntentsCore`, `swift test --package-path Packages/RippleUI`, and `swift test --package-path Packages/RippleFeatures`; record the unrelated `RippleData` SwiftPM test-host crash.
- [x] Run Xcode build verification for the five application schemes using the available SDK destinations; record the existing tvOS `SettingsView` availability failure.
