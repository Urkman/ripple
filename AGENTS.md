# AGENTS.md — Ripple

This file is binding for every agent (Grok Build, Cursor, Codex, human).  
No “close enough.” No silent shortcuts.

Conflict order:

1. **This file** for process, architecture, bans, and design tokens
2. **`Docs/shared/Ripple_PRD.md`** for shared product scope, screens, flows, domain, sync, intents, platforms, and motion
3. **`Docs/shared/Ripple_SCREEN_CATALOG.md` plus `Docs/shared/screens/<stable-id>.md`** for the platform-independent surface index, canonical layout/function descriptions, states, and stable screen/sheet IDs
4. **`Docs/shared/Ripple_DESIGN_SYSTEM.md`** for shared visual tokens and reusable UI-element contracts
5. **`Docs/shared/Ripple_DATA_MODEL.md`** for shared domain fields, invariants, persistence, and projection semantics
6. **`Docs/shared/IOS_ARCHITECTURE.md`** for iOS implementation boundaries and repository architecture

The PRD is the sole versioned product contract. Its detailed Today, History,
Stats, and motion contracts are in Section 22. Architecture documents define
implementation boundaries and platform-native mappings, not a second product
source of truth. Android is an independent project with its own `AGENTS.md`;
this file is not the Android project's instruction set.

The maintained companion contracts are platform-independent unless their title
explicitly names a platform:

- [`Docs/shared/Ripple_SCREEN_CATALOG.md`](Docs/shared/Ripple_SCREEN_CATALOG.md)
  indexes stable screen/sheet IDs and the canonical description schema;
  [`Docs/shared/screens/`](Docs/shared/screens/) contains one detailed,
  platform-independent layout/function contract per surface.
- [`Docs/shared/Ripple_DESIGN_SYSTEM.md`](Docs/shared/Ripple_DESIGN_SYSTEM.md)
  defines tokens, reusable UI elements, native-control policy, and motion/a11y
  acceptance.
- [`Docs/shared/Ripple_DATA_MODEL.md`](Docs/shared/Ripple_DATA_MODEL.md)
  defines domain fields, invariants, storage semantics, and projections.
- [`Docs/shared/IOS_ARCHITECTURE.md`](Docs/shared/IOS_ARCHITECTURE.md) maps the
  shared contracts to Swift/SwiftUI/SwiftData and the iOS repository.
- [`Docs/shared/Android/ANDROID_ARCHITECTURE.md`](Docs/shared/Android/ANDROID_ARCHITECTURE.md)
  and [`Docs/shared/Android/ANDROID_UI_SPEC.md`](Docs/shared/Android/ANDROID_UI_SPEC.md)
  map them to Android-native implementation and UI behavior.
- [`Docs/shared/Android/UI/README.md`](Docs/shared/Android/UI/README.md) indexes
  visual evidence and reference captures; images never override the text
  contracts.

---

## 0. Mission

Ripple is an open-source reference app: Swift/SwiftUI, every Apple device, CloudKit, strict boundaries.  
Water is logged wherever the user is (widget, Siri, Watch, Control). The app is Today, History, Stats, Settings.

Name: **Ripple**. Suggested bundle: `de.stefansturm.ripple`.

---

## 1. Stack — not negotiable

- **Swift** and **SwiftUI** only. No UIKit layout as the default. No SpriteKit, Metal, Lottie, or video UI.
- Swift 6, strict concurrency.
- State: `@Observable` / `@MainActor`. **No** `ObservableObject`. No Combine for view state.
- Persistence: **SwiftData** + CloudKit private DB + App Group. One store.
- HealthKit is a **projection**, never source of truth.
- Charts: **Swift Charts**.
- Intents: AppIntents via `RippleIntentsCore`, same `LogIntake` API as the button.
- Minimum OS: current OS at build time. Do not artificially target iOS 17.

---

## 2. Architecture — feature-first clean MVVM

```
Apps + Extensions        composition root, scenes
RippleFeatures           views + @Observable view models
RippleUI                 tokens, components, motion
RippleIntentsCore        AppIntent adapters
RippleDomain             entities, use cases, ports
RippleData               SwiftData, CloudKit, HealthKit, notifications
```

### May / must not

| Layer | May | Must not |
|---|---|---|
| Domain | use cases, goal formula, units | `import SwiftUI`, SwiftData, CloudKit, HealthKit, WidgetKit |
| Data | persistence, mapping, projections | view layout, Siri phrases |
| IntentsCore | system contract, phrases | its own amount logic, a second `LogIntake` |
| UI | look, motion, tokens | `@Query` writes, `HKHealthStore`, `CKRecord` |
| Features | VM orchestrates use cases | CloudKit/HealthKit directly, `#if os()` for business rules |
| Apps | wiring | if/else on source for the amount |

### Hard rules

- Every log goes through `LogIntake.run(amount:source:date:)`. Widget, Siri, Watch, Control, notification, button: **one** implementation.
- Writes only through a `@ModelActor`. Views do not write SwiftData.
- No `@Query` to create or mutate intakes.
- No second source of truth in UserDefaults (ephemeral widget placeholder only).
- A HealthKit failure must **not** roll back the log.
- Undo = `UndoLastIntake` on the last own, non-deleted entry. No distributed undo stack.
- Navigation is platform-local (tab / split / Watch page). No app-wide router.
- `#if os()` only in apps, UI adapters, composition root. Not in use cases. Not in view models for rules.
- Internally always **integer milliliters**. UI converts via `UnitConverter`.
- Soft delete (`isDeleted`). No hard wipe without an export path.

### Use cases (only write/read API features may call)

`LogIntake`, `UndoLastIntake`, `EditIntake`, `DeleteIntake`, `RestoreIntake`, `ObserveToday`, `ObserveMonth`, `ObserveStats`, `ObserveHistory`, `UpdateGoal`, `CalculateGoal`, `UpdateProfile`, `UpsertContainer`, `DeleteContainer`, `ExportData`, `RescheduleReminders`, `RequestHealthOnboardingAccess`, `RequestHealthReadAccess`, `RequestHealthWaterWrite`, `RequestNotificationAuthorization`.

New write path = new domain use case. Not “just do it in the view.”

### Composition root

One factory/container wires ports. No service-locator singletons except that factory. Extensions use the same App Group store.

---

## 3. Repo layout

```
Apps/          RippleiOS, watchOS, macOS, tvOS, visionOS
Extensions/    RippleWidgets (WidgetKit UI)
Packages/      RippleDomain, RippleData, RippleIntentsCore, RippleUI, RippleFeatures
Tests/
Docs/
  shared/                       Android port handoff and shared product contract
    Ripple_PRD.md               the single versioned product contract
    Ripple_SCREEN_CATALOG.md    platform-independent screen/sheet contract
    Ripple_DESIGN_SYSTEM.md     shared design tokens and UI-element contracts
    Ripple_DATA_MODEL.md        shared domain and persistence contract
    IOS_ARCHITECTURE.md         iOS implementation reference for the port
    Android/                    Android architecture, UI, and PNG reference pack
    screens/                    one canonical Markdown description per screen/sheet; ios/ contains evidence captures
```

No business logic in `Apps/` beyond wiring.  
New UI that needs tokens → `RippleUI`, not copy-paste inside a feature.

### Shared surface and UI ownership rules

- Every navigable screen, presented sheet, wearable surface, and documented
  system surface has exactly one canonical, platform-independent Markdown
  description under `Docs/shared/screens/<stable-id>.md`. That file owns the
  surface's layout, function, read model, actions, states, validation,
  accessibility, responsive behavior, and forbidden behavior.
- `Docs/shared/Ripple_SCREEN_CATALOG.md` is the index for stable IDs and the
  required description schema. It must link every ID to exactly one canonical
  description file. Platform architecture documents may map that description
  to native implementation files, modules, routes, and private helpers; they
  must not create a competing semantic description.
- The canonical description-file rule is about documentation, not production
  source-file organization. iOS and Android may split or co-locate private
  implementation details according to their native architecture. A platform
  implementation must preserve the one canonical surface contract even when
  its source structure differs.
- Every UI element consumes a named token or a reusable component from the
  design-system contract. Feature-local colors, fonts, spacing, radii, shadows,
  toasts, cards, and motion systems are prohibited. Raw values are allowed
  only inside token definitions, documented geometry algorithms, or narrowly
  scoped platform adapters.
- Native system controls are preferred for ordinary behavior: text entry,
  sliders, toggles, pickers, sheets, alerts, permission prompts, keyboard/
  rotary input, and sharing. Ripple styling may wrap a native control but must
  preserve its platform affordances, focus, hit target, accessibility actions,
  and dismissal behavior.
- The shared PRD remains product authority; the screen catalog, design system,
  and data model provide detailed companion contracts; platform documents map
  those contracts and must not redefine them. Product, screen, UI, data, or
  architecture changes update the affected shared and Android handoff
  documents in the same change, including `Last verified` and an immutable
  timeline entry for every versioned document.

---

## 4. Design system — these tokens only

Colors, type, space, and motion come from `RippleUI`. No magic numbers in features except layout offsets named in the motion spec.

### Color

| Token | Light | Role |
|---|---|---|
| `color.water.deep` | `#0B3D4A` | text, icons |
| `color.water.lagoon` | `#1A7A8C` | primary, stroke |
| `color.water.aqua` | `#4FB3C6` | water, progress |
| `color.water.foam` | `#E8F4F6` | background |
| `color.success` | Lagoon | goal reached |
| `color.danger` | desaturated system red | delete |

Dark: Deep stays readable, Aqua a bit brighter, surfaces cool anthracite.  
No extra accent colors in v1 (no orange, no purple).

### Type and shape

- **San Francisco** only. No custom font.
- Numbers: `.monospacedDigit()`. No `1°500` formatting.
- Styles only via `Font.TextStyle`: display / title / body / callout / caption.
- 4-pt grid.
- Radii: 12 controls, 20 cards, 28 hero.
- No heavy drop shadows. Material: `ultraThinMaterial` sparingly.

### Motion tokens

| Token | Value | Use |
|---|---|---|
| `ripple.duration.quick` | 0.28 s | button, chip |
| `ripple.duration.hero` | pour 0.40–0.70 s | active stream |
| `ripple.spring.snappy` | 0.28 / 0.85 | controls |
| `ripple.spring.liquid` | 0.55 / 0.72 | readout and non-pour refresh |
| `ripple.level.rise` | pour duration + 0.14 s, linear | active-pour fill level |
| `ripple.undo` | 0.45 s | level reverse |

`ripple.idle.loop` is **dead**. Idle has no sine loop.

Reduce Motion: no pour stream, no surface reaction, `tilt = 0`, level cross-fade 0.20 s.

### Components (build once, reuse)

`LogButton`, `QuickAddCluster`, `AmountStepper`, `ContainerChip`, `DayHeader`, `RemainingLabel`, `IntakeRow`, `SyncStatusView`, `EmptyState`, `GlassCard`, `GlassShape`, `WaterFill`, `PourStreamShape`, `DayRing`.

Every new component: Light/Dark preview, Dynamic Type XXXL, Reduce Motion.

---

## 5. Today hero — do not improvise

Full text: `Docs/shared/Ripple_PRD.md` §22.1. Non-negotiable short list:

- Level = stylized **2D glass**. No circular progress. No `ProgressView` as the hero.
- Idle: **flat** water surface. No `TimelineView` for water.
- Tilt: screen-aligned Core Motion gravity, full rotation with no 16° cap. Damped motion-driven slosh; preserve visible water area while keeping water contained. See PRD §22.1.6. No SPH.
- `level == 0`: no fill, no bottom shimmer.
- No single drop metaphor. Use one narrow `PourStreamShape` for an active add series.
- Stream width 7…12 pt and flow duration 0.40…0.70 s follow the series amount.
- Start **above** the glass: `glass.minY - 32 pt`. Establish to the surface in 0.14 s.
- One shared, frame-sampled pour clock drives the level rise and stream fade from first contact through disappearance. The level reaches its target exactly when the stream disappears; no level spring or overshoot during a pour. Numbers remain above the stream. Remaining / last / confirm change when the pour ends.
- Surface response: central contact depression, one outward pair, one weaker reflection, flat again after 0.90 s.
- No separate hero rings or idle surface motion.
- Simulator / Mac / Watch / widget / face-up / Reduce Motion: `tilt = 0`.
- Coalesce: many taps → many store rows, **one continuous pour**, one duration-locked retargeted level animation, one final surface response.

---

## 6. History and Stats — keep them split

Full text: `Docs/shared/Ripple_PRD.md` §22.2.

- Four tabs: Today | History | Stats | Settings.
- History = Activity-style month grid, **one ring per day**, cap 1.0. Future days not tappable.
- Tap → push `DayDetail` (iPad: split). Plus only when the day is today.
- Stats = its own screen. Period week/month/year. Swift Charts as specified.
- Watch app History is a separate Watch-native recent-seven-day list with a Day Detail that allows deleting individual entries; Watch Stats is a separate current-ISO-week summary with one compact Swift Charts view.
- No combined Insights screen, no three Fitness rings, no GitHub heatmap.

---

## 7. Copy, language, a11y

- v1: **DE and EN**. Follow system language. No other locales.
- UI copy from the specs (confirm: `+{n} ml · schöner Ripple.` / EN equivalent). No marketing fluff, no medical advice.
- VoiceOver labels complete (amount, goal, percent, source).
- Dynamic Type through XXXL. Do not clip hero numbers; scale if needed.
- Deep on Foam must stay readable.

---

## 8. Platforms

- iPhone: four tabs, hero per motion spec.
- iPad: split per tab. Not a shrunk iPhone skin.
- Watch app: three horizontal Today | History | Stats pages. Today uses the full canvas as a flat water-level field with predefined and Crown-first custom logging; History shows seven elapsed local days and a Day Detail where individual entries can be deleted; Stats shows the current ISO-week summary and one compact chart. No Watch month calendar or Stats period picker.
- Watch complications and widgets: no calendar and no Stats charts; retain their focused ring/remaining surfaces.
- Mac: sidebar, keyboard ⌘N / ⌘Z.
- tvOS / visionOS: ambient/window minimum from the PRD, not feature parity.
- Widget: glass silhouette, flat surface, **no** pour stream or surface response, **no** motion tilt.

---

## 9. Quality

- Every use case: at least one unit test (Log, Undo, goal formula, UnitConverter, pourWidth, pourDuration, levelRiseDuration).
- No force-unwrap on production paths.
- No `print` as telemetry.
- Package public API as small as possible.
- New dependency only after the affected architecture document is updated and
  the dependency is explicitly justified. Default: no third-party UI libraries.

---

## 10. Explicitly banned

- `ProgressView` / circular progress as the daily level
- Photoreal water, caustics, particles, fluid solvers
- Idle sine wave, permanent surface motion
- A single drop or SF Symbol `drop.fill` as the add metaphor
- Pour stream starting inside the glass or detached from the water surface
- Level spring or level overshoot while a pour stream is active
- HealthKit as truth; rolling back a log on HK failure
- A second `LogIntake` in widget/intent
- `@Query` writes, UserDefaults as store
- Plants, social, streak product, beverage factors (v1.1)
- Heavy shadows, custom fonts, extra accent colors
- Back button on tab roots
- English hardcodes in the DE locale

---

## 11. How agents work

1. Read the spec, then write code. Do not build first and “approximate” the spec.
2. Extend existing tokens and use cases. Do not invent a parallel path.
3. UI change to the hero or History/Stats: update `Docs/shared/Ripple_PRD.md` first, then the code. In the same change, update the affected Android UI handoff under `Docs/shared/Android/` so the independent Android project never receives stale screen guidance.
4. After motion changes, re-check Reduce Motion and `level == 0`.
5. Do not inflate scope into v1.1.
6. Re-read this file at session start when unsure.
7. Treat the maintained handoff pack under `Docs/shared/` as the source set provided to the independent Android project: the PRD, iOS architecture reference, Android architecture/UI documents, and image references. The Android project has its own `AGENTS.md`, which governs Android implementation work.
8. Update the shared PRD in the same change as any product behavior, screen, flow, or motion change. Update `Docs/shared/IOS_ARCHITECTURE.md` for iOS implementation-boundary changes. Every UI change must also review and update the corresponding Android UI contract and reference pack under `Docs/shared/Android/` in the same change, including `ANDROID_UI_SPEC.md`, `UI/README.md`, and any affected image references. This Android documentation update is mandatory even when no Android implementation code changes; the Android project has its own `AGENTS.md` for implementation work.
9. `Docs/shared/Ripple_PRD.md`, `Docs/shared/IOS_ARCHITECTURE.md`, and the Android architecture/UI specifications are independently semantic-versioned and must update `Last verified` plus their final immutable Timeline entry whenever they change. When a UI change changes the Android contract, bump the Android UI specification version and append its Timeline entry; keep the reference-pack revision and image references consistent with it. Agent task plans/specs remain ignored and outside the handoff pack.

## 12. Required skills

Before designing, writing, reviewing, or debugging work in one of these areas, read and follow the applicable skill. If a task spans multiple areas, use every applicable skill. Read the skill's `SKILL.md` completely, then load only the linked references needed for the task.

### Mobile design and SwiftUI

- [mobile-ios-design](/Users/urkman/.agents/skills/mobile-ios-design/SKILL.md): mobile design and layout, HIG, navigation, adaptive iPhone/iPad behavior, accessibility, Dynamic Type, and Dark Mode.
- [swiftui-specialist](/Users/urkman/.agents/skills/swiftui-specialist/SKILL.md): SwiftUI structure, data flow, `@Observable`, `ForEach`/`List` identity, localization, modifiers, and soft-deprecated APIs.
- [swiftui-animation](/Users/urkman/.agents/skills/swiftui-animation/SKILL.md): SwiftUI animation, transitions, choreography, content transitions, and Reduce Motion behavior.
- [swiftui-liquid-glass](/Users/urkman/.codex/skills/swiftui-liquid-glass/SKILL.md): iOS 26+ Liquid Glass, `GlassEffectContainer`, interactive glass, availability, and fallbacks.
- [swiftui-whats-new-27](/Users/urkman/.agents/skills/swiftui-whats-new-27/SKILL.md): SDK 27 SwiftUI APIs, behavior changes, deprecations, and related compiler errors. Read its specific reference before using a new SDK 27 API.

### Data, concurrency, charts, and intents

- [swiftdata-pro](/Users/urkman/.agents/skills/swiftdata-pro/SKILL.md): SwiftData models, predicates, relationships, CloudKit constraints, indexing, and modern concurrency.
- [swift-concurrency](/Users/urkman/.agents/skills/swift-concurrency/SKILL.md): Swift 6 isolation, actors, `Sendable`, async/await, tasks, cancellation, and concurrency diagnostics. Check the project language/concurrency settings before giving migration-sensitive guidance.
- [swift-charts](/Users/urkman/.agents/skills/swift-charts/SKILL.md): Swift Charts mark selection, axes, scales, accessibility, theming, and validation across representative states.
- [app-intents-specialist](/Users/urkman/.agents/skills/app-intents-specialist/SKILL.md): App Intents execution, entities, queries, parameters, dependencies, localization, donations, phrases, and stable public contracts.

### Build, run, debug, and App Store Connect

- [ios-debugger-agent](/Users/urkman/.codex/skills/ios-debugger-agent/SKILL.md): iOS build/run/debug workflows, simulator UI inspection, screenshots, and log capture. Discover the booted simulator before using XcodeBuildMCP.
- [build-ios-apps:ios-simulator-browser](/Users/urkman/.codex/plugins/cache/openai-curated-remote/build-ios-apps/0.1.2/skills/ios-simulator-browser/SKILL.md): mirroring a specific simulator in the in-app browser and SwiftUI preview hot reload. Keep `serve-sim` scoped to the selected simulator and verify a real rendered frame.
- [asc-cli-usage](/Users/urkman/.agents/skills/asc-cli-usage/SKILL.md): App Store Connect work through `asc`. Discover commands and flags with `--help`/`asc search`, inspect schemas before API-facing commands, use explicit long flags, and require `--confirm` for destructive operations.

Breaking a rule requires changing the spec — not ignoring the rule.

## 13. Project-local reusable skills

The repository ships the reusable Codex skills required for the cross-platform
workflow under [`skills/`](skills/). These project-local packages are the
canonical copies; contributors must install them locally before using the
workflow:

```sh
mkdir -p ~/.codex/skills
cp -R skills/cross-platform-product-documentation ~/.codex/skills/
cp -R skills/android-app-from-documentation ~/.codex/skills/
cp -R skills/ios-app-setup ~/.codex/skills/
```

- [`skills/cross-platform-product-documentation/SKILL.md`](skills/cross-platform-product-documentation/SKILL.md)
  defines the shared product and surface documentation contracts.
- [`skills/android-app-from-documentation/SKILL.md`](skills/android-app-from-documentation/SKILL.md)
  implements the Android project from those contracts.
- [`skills/ios-app-setup/SKILL.md`](skills/ios-app-setup/SKILL.md) prepares a
  blank or existing iOS project with shared foundations, a DesignSystem, and
  documentation-synchronization rules. It does not implement product screens
  from documentation.

When any of these skills changes, update the copy under `skills/`, validate the
changed package, and reinstall it locally. Do not make a global user skill the
only copy of project workflow rules.
