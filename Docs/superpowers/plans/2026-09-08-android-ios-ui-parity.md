# Ripple Android/iOS UI parity contract repair Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Repair the Android UI and related product Markdown contracts so an Android agent can build the same Ripple screens and flows as the current iOS app using native Android presentation, with no application-code changes in this work.

**Architecture:** Treat the current iOS implementation and verified captures as the product hierarchy reference, `Ripple_Hero_Motion.md` and `Ripple_History_Stats.md` as the detailed behavior contracts, and the Android documents as the native Android mapping. Use existing iOS captures for evidence, add lightweight SVG wireframes for Android layout contracts, and keep all platform choices explicit without copying iOS Liquid Glass or tab-bar chrome.

**Tech Stack:** Markdown documentation, existing PNG reference captures, hand-authored SVG wireframes, shell-based link/consistency checks, and Git. No Swift, Kotlin, Gradle, Xcode project, or Android source changes.

**Spec:** [Android/iOS UI parity contract design](../specs/2026-09-08-android-ios-ui-parity-design.md)

## Global Constraints

- Documentation-only change: do not modify Swift, Kotlin, Gradle, Xcode project files, package manifests, tests, or runtime assets.
- Android preserves iOS product hierarchy and capabilities but uses Material 3, Compose, Window Size Classes, Android back behavior, Compose for Wear, and native Android permission/system surfaces.
- Android has four top-level destinations: Today, History, Stats, and Settings.
- Today uses a contained glass-shaped water hero, saved-container quick adds, and custom amount; it has no Recent list or dashboard.
- History is a swipable month calendar with one ring per day; Day Detail is required; add is available only for today.
- Stats remains separate from History and includes Week/Month/Year, summaries, four chart families, and highlights.
- Onboarding has six pages: welcome, units, Health/Health Connect, goal, containers, and reminders.
- Wear has Today, seven-day History with Day Detail, and current ISO-week Stats; it has no month calendar or period picker.
- Existing Hero Motion and History/Stats specifications remain authoritative for their detailed behavior.
- Every changed architecture/UI Markdown document receives the required semantic version, `Last verified` metadata, and immutable Timeline entry.
- Every task ends with a documentation validation command and a focused commit.

## File Map

| File | Responsibility in this plan |
| --- | --- |
| `AGENTS.md` | Remove the obsolete PRD §14 stale-text exception after the PRD is corrected; retain Hero Motion precedence. |
| `Ripple_Handoff/Ripple_PRD.md` | Correct stale iPhone, iPad, Today, and onboarding product statements. |
| `Ripple_Handoff/Ripple_Hero_Motion.md` | Read-only authority check; no content change unless the audit finds a factual mismatch. |
| `Ripple_Handoff/Ripple_History_Stats.md` | Read-only authority check; no content change unless the audit finds a factual mismatch. |
| `Docs/ANDROID_UI_SPEC.md` | Normative Android screen, flow, state, accessibility, reference, and acceptance contract. |
| `Docs/ANDROID_ARCHITECTURE.md` | Android capability/module/UI alignment and maintenance timeline. |
| `Docs/ARCHITECTURE.md` | Shared architecture metadata and synchronized-contract timeline entry. |
| `Docs/AndroidUI/README.md` | Explains the visual reference pack and evidence-versus-contract distinction. |
| `Docs/AndroidUI/*.svg` | Lightweight annotated Android phone, tablet, onboarding, and Wear wireframes. |

---

### Task 1: Correct stale shared product statements

**Files:**
- Modify: `Ripple_Handoff/Ripple_PRD.md:12.1 iPhone, 12.2 iPad, 14 Today, 15 Onboarding`
- Modify: `AGENTS.md:1-18`
- Read for authority: `Ripple_Handoff/Ripple_Hero_Motion.md`, `Ripple_Handoff/Ripple_History_Stats.md`

**Interfaces:**
- Consumes: current iOS source in `Apps/RippleiOS/RootView.swift`, `Packages/RippleFeatures/Sources/RippleFeatures/Today/TodayView.swift`, `HistoryCalendarView.swift`, `SettingsView.swift`, and `OnboardingPages.swift`.
- Produces: shared Markdown product statements that agree with the current four-tab iOS shell, current hero contract, current six-page onboarding, and current History/Stats contract.

- [ ] **Step 1: Read the authoritative source ranges and record the exact stale statements**

  Inspect the current source and product sections with:

  ```bash
  sed -n '470,690p' Ripple_Handoff/Ripple_PRD.md
  sed -n '1,90p' Ripple_Handoff/Ripple_Hero_Motion.md
  sed -n '1,180p' Ripple_Handoff/Ripple_History_Stats.md
  sed -n '1,260p' Apps/RippleiOS/RootView.swift
  sed -n '1,260p' Packages/RippleFeatures/Sources/RippleFeatures/Onboarding/OnboardingPages.swift
  ```

  Confirm that the PRD is the stale source and that Hero Motion and History/Stats already describe the current detailed behavior.

- [ ] **Step 2: Correct the iPhone and iPad product shell in the PRD**

  Replace the three-tab iPhone statement with Today, History, Stats, and Settings. Describe History as a month calendar with one ring per day and a Day Detail, Stats as its own period/chart screen, and Settings as the complete settings surface. Replace the shrunk/incorrect iPad description with the current adaptive split behavior: calendar/detail for History, full Stats feature screen, and Today’s portrait/landscape compositions as specified by Hero Motion. Update the PRD version from `1.4` to `1.5` and add `Last verified: 2026-09-08` beside its version metadata.

- [ ] **Step 3: Make the PRD defer to the current Hero Motion contract**

  Replace the old §14 `WaveFill`/`TimelineView`/idle sine loop/drop/ring/level-overshoot instructions with a concise reference to `Ripple_Hero_Motion.md`. Retain the product-level glass hero, water level, readout, container actions, custom amount, and Android-independent logging hierarchy. Do not duplicate obsolete motion algorithms in the PRD.

- [ ] **Step 4: Correct onboarding to six pages**

  Replace the five-page list with the current sequence: Welcome, Units, Apple Health/Health access, Goal setup, Containers, and Notifications/Reminders. Preserve the optional/recoverable permission behavior described by the current onboarding implementation and design record.

- [ ] **Step 5: Update the binding AGENTS note**

  Remove the statement that PRD §14 is stale once the PRD points to Hero Motion as the active contract. Keep the explicit precedence rule that Hero Motion governs the hero if a future product text conflict occurs.

- [ ] **Step 6: Validate the correction and commit it**

  Run:

  ```bash
  ! rg -n 'Tabs: \*\*Heute \| Verlauf \| Einstellungen\*\*|5 Seiten|TimelineView|RippleRings|DropShape|idle.*6,0 s' Ripple_Handoff/Ripple_PRD.md
  rg -n 'Heute.*Verlauf.*Stats.*Einstellungen|Welcome|Units|Health|Goal|Containers|Notifications|Hero_Motion' Ripple_Handoff/Ripple_PRD.md AGENTS.md
  git diff --check -- AGENTS.md Ripple_Handoff/Ripple_PRD.md
  ```

  Expected result: no obsolete PRD shell/onboarding/hero matches, current four-tab/six-page/delegation statements present, and no whitespace errors. Commit:

  ```bash
  git add AGENTS.md Ripple_Handoff/Ripple_PRD.md
  git commit -m "docs: align product contract with current iOS UI"
  ```

---

### Task 2: Create the visual reference pack

**Files:**
- Create: `Docs/AndroidUI/README.md`
- Create: `Docs/AndroidUI/phone-today.svg`
- Create: `Docs/AndroidUI/phone-history.svg`
- Create: `Docs/AndroidUI/phone-day-detail.svg`
- Create: `Docs/AndroidUI/phone-stats.svg`
- Create: `Docs/AndroidUI/phone-settings.svg`
- Create: `Docs/AndroidUI/phone-onboarding.svg`
- Create: `Docs/AndroidUI/tablet-history-split.svg`
- Create: `Docs/AndroidUI/tablet-stats.svg`
- Create: `Docs/AndroidUI/wear-today.svg`
- Create: `Docs/AndroidUI/wear-history.svg`
- Create: `Docs/AndroidUI/wear-day-detail.svg`
- Create: `Docs/AndroidUI/wear-stats.svg`

**Interfaces:**
- Consumes: existing iOS captures in `release/screenshots/raw/`, the approved parity design, and corrected product statements from Task 1.
- Produces: stable vector references linked by `Docs/ANDROID_UI_SPEC.md`; each wireframe labels product content and Android-native component choices without prescribing iOS pixels.

- [ ] **Step 1: Create the reference-pack README**

  Write `Docs/AndroidUI/README.md` with three explicit rules: existing iOS PNGs are evidence, SVGs are Android layout contracts, and real Android captures are final acceptance artifacts. Link the existing iOS Today, History, Stats, Settings, and Watch captures with repository-relative Markdown paths. State that the pack contains no app source and does not authorize copying Liquid Glass or iOS tab-bar chrome.

- [ ] **Step 2: Draw the compact phone wireframes**

  Create `phone-today.svg`, `phone-history.svg`, `phone-day-detail.svg`, `phone-stats.svg`, `phone-settings.svg`, and `phone-onboarding.svg` as readable 360×780-style vector frames. Use labels and arrows rather than exact pixel measurements. The frames must show, respectively: the glass hero and container actions without Recent rows; the month pager/ring grid; nested Day Detail rows/actions; period selector, summaries, four chart regions, and highlights; all Settings sections; and all six onboarding steps with native permission handoffs.

- [ ] **Step 3: Draw expanded and Wear wireframes**

  Create `tablet-history-split.svg` and `tablet-stats.svg` with navigation rail/persistent navigation and responsive content panes. Create the four Wear SVGs with full-canvas Today, seven-day History, entry Day Detail, and current ISO-week Stats. Label Material/Wear components such as NavigationBar, NavigationRail, TopAppBar, ListItem, Switch, Chip, rotary input, and standard dialogs where they replace iOS controls.

- [ ] **Step 4: Validate SVG structure and repository links**

  Run:

  ```bash
  xmllint --noout Docs/AndroidUI/*.svg
  test -f release/screenshots/raw/en-US/iphone-69/01-today.png
  test -f release/screenshots/raw/en-US/iphone-69/02-history.png
  test -f release/screenshots/raw/en-US/iphone-69/03-stats.png
  test -f release/screenshots/raw/en-US/ipad-129/04-settings.png
  test -f release/screenshots/raw/en-US/watch-46/01-today.png
  test -f release/screenshots/raw/en-US/watch-46/02-history.png
  git diff --check -- Docs/AndroidUI
  ```

  Expected result: every SVG parses, every referenced evidence capture exists, and no whitespace errors occur. Commit:

  ```bash
  git add Docs/AndroidUI
  git commit -m "docs: add Android UI reference wireframes"
  ```

---

### Task 3: Rewrite the Android UI specification around iOS parity

**Files:**
- Modify: `Docs/ANDROID_UI_SPEC.md`
- Consume: `Docs/AndroidUI/README.md`, all SVGs from Task 2, and existing iOS captures

**Interfaces:**
- Consumes: corrected product contract from Task 1 and the Android-native component vocabulary in `Docs/ANDROID_ARCHITECTURE.md`.
- Produces: a single normative Android screen/flow/state/accessibility contract that an Android agent can implement without inferring missing iOS behavior.

- [ ] **Step 1: Update metadata and source-of-truth wording**

  Set the document version to `2.0.0`, set `Last verified` to `2026-09-08`, link the reference pack, and state that iOS screenshots are evidence while the Android wireframes/state tables are normative. Keep Android-native presentation as a hard requirement.

- [ ] **Step 2: Replace the top-level navigation and phone/tablet contracts**

  Rewrite the navigation section and phone/tablet wireframes to describe four roots, compact/medium/expanded navigation, standard nested top app bars, and predictive back. Remove the old Today Recent rows. Add the full Today hierarchy, contained hero requirement, no circular progress rule, saved-container actions, custom amount action, and all required visual/error/reduced-motion states.

- [ ] **Step 3: Make History, Day Detail, Stats, Settings, and onboarding complete**

  Replace the current simplified sections with the approved contracts: swipable month pages and Day Detail; edit/delete/restore semantics; complete Stats periods and chart families; complete Settings section order and Android control substitutions; and the six-page onboarding with recoverable Health Connect/notification permissions.

- [ ] **Step 4: Align Wear and system surfaces**

  Rewrite Wear sections to require Today, seven-day History, Wear Day Detail, and current ISO-week Stats. Explicitly prohibit a Wear month calendar, period picker, multi-chart dashboard, pour stream, and tilt. Keep widgets, Quick Settings, notification, complications, and Tiles focused and routed through the common write boundary.

- [ ] **Step 5: Add the parity matrix, state/flow references, and acceptance captures**

  Add a matrix mapping each iOS capability and existing iOS capture to its Android screen/wireframe and acceptance capture name. Expand the state matrix and flows for no Recent rows, Day Detail, six onboarding pages, permission denial, offline Wear sync, reduced motion, large text, and TalkBack. Link each screen to its SVG and existing iOS evidence capture.

- [ ] **Step 6: Update maintenance metadata and commit**

  Append an immutable `2.0.0` Timeline row dated `2026-09-08` explaining that the document now mirrors the current iOS screen hierarchy while retaining Android-native presentation. Run:

  ```bash
  rg -n 'Today|History|Day Detail|Stats|Settings|Onboarding|Wear|Recent|NavigationBar|NavigationRail|phone-today.svg' Docs/ANDROID_UI_SPEC.md
  ! rg -n 'Recent intake rows|Recent$|short wizard|three top-level|no Day Detail' Docs/ANDROID_UI_SPEC.md
  git diff --check -- Docs/ANDROID_UI_SPEC.md
  ```

  Expected result: all required contracts are present, the removed Recent/simplified-flow language is absent, and the document has no whitespace errors. Commit:

  ```bash
  git add Docs/ANDROID_UI_SPEC.md
  git commit -m "docs: align Android UI spec with iOS product flow"
  ```

---

### Task 4: Align the Android architecture companion

**Files:**
- Modify: `Docs/ANDROID_ARCHITECTURE.md`
- Modify: `Docs/ARCHITECTURE.md`

**Interfaces:**
- Consumes: the corrected PRD, revised Android UI specification, and existing iOS architecture/source boundaries.
- Produces: architecture documents whose capability matrices, UI requirements, maintenance contracts, and version histories agree with the revised parity contract.

- [ ] **Step 1: Update Android architecture metadata and capability matrix**

  Set `Docs/ANDROID_ARCHITECTURE.md` to version `1.3.0` and `Last verified: 2026-09-08`. Remove Today’s `intake list` requirement, add the contained glass hero/no-Recent hierarchy, require the month pager and Day Detail, complete Stats chart families, require all six onboarding pages, and preserve complete Settings coverage.

- [ ] **Step 2: Align Android UI, onboarding, phone feature, and Wear sections**

  Update the Android-native UI section, onboarding section, Today/History/Stats/Settings requirements, Wear screen section, and manual acceptance matrix so they use the same four roots, six onboarding pages, Day Detail flow, and Wear restrictions as `ANDROID_UI_SPEC.md`. Keep Room, Health Connect, use-case, and no-cross-platform-data boundaries unchanged.

- [ ] **Step 3: Record the paired-document timeline entry**

  Append a `1.3.0` Timeline row dated `2026-09-08` stating that the Android architecture was aligned with the repaired iOS-parity UI contract and that no Android runtime code changed.

- [ ] **Step 4: Update the shared architecture metadata and timeline**

  Set `Docs/ARCHITECTURE.md` to version `1.3.0` and `Last verified: 2026-09-08`. Add a Timeline row recording the synchronized product-contract correction and explicitly state that the Swift architecture and source boundaries are unchanged. Do not alter package dependencies or Swift implementation guidance.

- [ ] **Step 5: Validate and commit the architecture documents**

  Run:

  ```bash
  rg -n 'Document version|Last verified|Today|History|Day Detail|Stats|Settings|Onboarding|Wear|Timeline' Docs/ANDROID_ARCHITECTURE.md Docs/ARCHITECTURE.md
  ! rg -n 'intake list|three tabs|five pages|no Day Detail' Docs/ANDROID_ARCHITECTURE.md
  git diff --check -- Docs/ANDROID_ARCHITECTURE.md Docs/ARCHITECTURE.md
  ```

  Expected result: both documents carry current metadata, synchronized capability language, and timeline entries with no whitespace errors. Commit:

  ```bash
  git add Docs/ANDROID_ARCHITECTURE.md Docs/ARCHITECTURE.md
  git commit -m "docs: synchronize Android architecture UI contract"
  ```

---

### Task 5: Run the complete documentation acceptance pass

**Files:**
- Verify: `AGENTS.md`
- Verify: `Ripple_Handoff/Ripple_PRD.md`
- Verify: `Ripple_Handoff/Ripple_Hero_Motion.md`
- Verify: `Ripple_Handoff/Ripple_History_Stats.md`
- Verify: `Docs/ANDROID_UI_SPEC.md`
- Verify: `Docs/ANDROID_ARCHITECTURE.md`
- Verify: `Docs/ARCHITECTURE.md`
- Verify: `Docs/AndroidUI/*`

**Interfaces:**
- Consumes: all committed documentation changes from Tasks 1–4.
- Produces: a clean, reviewable documentation-only diff with no stale hierarchy, missing reference, or code-file change.

- [ ] **Step 1: Confirm the changed-file boundary**

  Run:

  ```bash
  git status --short
  git log --oneline --name-only -8
  ```

  Confirm that the task commits contain Markdown and SVG reference artifacts only. No `.swift`, `.kt`, `.kts`, `.xml`, `.xcodeproj`, `.pbxproj`, or Gradle files may appear.

- [ ] **Step 2: Check source-of-truth consistency**

  Run:

  ```bash
  rg -n 'Today.*History.*Stats.*Settings|six pages|Welcome|Units|Health|Goal|Containers|Notifications|Day Detail|current ISO week' AGENTS.md Ripple_Handoff/Ripple_PRD.md Ripple_Handoff/Ripple_History_Stats.md Docs/ANDROID_UI_SPEC.md Docs/ANDROID_ARCHITECTURE.md
  ! rg -n 'Tabs: \*\*Heute \| Verlauf \| Einstellungen\*\*|5 Seiten|TimelineView|RippleRings|DropShape|Recent intake rows|intake list' Ripple_Handoff/Ripple_PRD.md Docs/ANDROID_UI_SPEC.md Docs/ANDROID_ARCHITECTURE.md
  ```

  Confirm that the only active hero motion description is `Ripple_Hero_Motion.md`, History/Stats remains the detailed authority, and Android adds no Recent/dashboard flow.

- [ ] **Step 3: Check links, SVGs, and whitespace**

  Run:

  ```bash
  xmllint --noout Docs/AndroidUI/*.svg
  for path in Docs/ANDROID_UI_SPEC.md Docs/ANDROID_ARCHITECTURE.md Docs/ARCHITECTURE.md Ripple_Handoff/Ripple_PRD.md Ripple_Handoff/Ripple_Hero_Motion.md Ripple_Handoff/Ripple_History_Stats.md; do test -f "$path"; done
  git diff --check HEAD
  ```

  Expected result: all contract files exist, SVGs parse, and Git reports no whitespace errors.

- [ ] **Step 4: Review the final diff for scope and readability**

  Read the complete combined diff and verify: no code changes, no unresolved placeholders, no conflicting version/timeline metadata, no Android recommendation to copy iOS chrome, no omitted Settings section, no omitted onboarding page, and no missing Day Detail/Wear restriction.

- [ ] **Step 5: Commit any validation-only correction**

  If the acceptance pass finds a documentation-only correction, apply it to the owning Markdown/SVG file, rerun the affected command above, and commit it with:

  ```bash
  git add AGENTS.md Ripple_Handoff Docs/ANDROID_UI_SPEC.md Docs/ANDROID_ARCHITECTURE.md Docs/AndroidUI
  git commit -m "docs: polish Android UI parity contract"
  ```

  If no correction is found, leave the four focused commits unchanged.

## Plan self-review

- The design’s source-of-truth precedence is covered by Tasks 1, 3, and 4.
- Phone/tablet screen contracts are covered by Task 3.
- Wear and system surfaces are covered by Tasks 2 and 3, then cross-checked by Task 5.
- Reference screenshots, SVG wireframes, parity mapping, and acceptance naming are covered by Tasks 2 and 3.
- Metadata and immutable timelines are covered by Tasks 1, 3, and 4.
- The user’s no-code constraint is repeated globally and verified by Task 5.
- No runtime APIs, Swift types, Kotlin types, or implementation interfaces are introduced because this is a documentation-only plan.
