---
name: android-conversion-readiness
description: Audit whether a repository is ready for conversion to Android by checking authoritative documentation, canonical surface coverage, visual evidence, design-system token usage, data boundaries, native mappings, and acceptance prerequisites. Use before Android implementation; do not use it to build the Android app or invent missing product decisions.
---

# Android Conversion Readiness

Use this skill before starting or handing off Android implementation. It is a
readiness audit, not an implementation workflow and not a substitute for the
repository's `AGENTS.md`, product contract, surface contracts, design system,
data model, or Android UI/architecture documents.

## Core outcome

Produce an evidence-backed readiness report with one of these outcomes:

- **READY:** no blocking prerequisite is open;
- **READY WITH WARNINGS:** implementation can begin, but known warnings or
  unverified areas must be tracked; or
- **BLOCKED:** at least one prerequisite is missing, contradictory, or
  violates an explicit repository rule.

The report must identify the exact file, line or check, severity, and the next
authority/action needed. Never turn a missing decision into an assumption.

### Source-platform routing is not shared architecture

Treat `RippleNavigationCoordinator` in the iOS architecture reference as
iOS-only composition-root context. Readiness passes only when the Android
architecture/UI contracts define Android-native root and nested navigation;
they must not require Swift route types, `RootView`, or an Android port of the
iOS coordinator. Shared contracts describe screen meaning and flows, not the
source platform's router implementation.

## Scope and boundaries

Use this skill when the user asks whether an iOS/shared product repository is
ready to be converted, handed off, or implemented on Android. It checks:

1. authoritative product, surface, visual, design, data, iOS, and Android
   documentation;
2. one-to-one stable-surface and canonical-description coverage;
3. real PNG plus same-stem editable SVG wireframe coverage and visual
   inventory completeness;
4. design-system ownership and use of named tokens/components in production
   Swift UI code;
5. source-of-truth, use-case, projection, localization, accessibility,
   responsive, wearable, and system-surface prerequisites;
6. Android-native mappings, acceptance states, and runtime-evidence readiness.

Do not use it to implement Android code, rewrite Swift, change the product
contract, repair token violations silently, create missing screenshots, or
declare runtime acceptance from documentation alone. Those are separate
tasks. If the audit discovers a product or authority conflict, report it and
route the change through the documented authority order.

## Authority and repository discovery

Read the binding `AGENTS.md` first. Then resolve the repository's authority
chain before judging readiness. In Ripple, the minimum set is:

- `Docs/shared/Ripple_PRD.md` for product behavior, scope, flows, domain, and
  motion;
- `Docs/shared/Ripple_SCREEN_CATALOG.md` plus exactly one file under
  `Docs/shared/screens/` for every stable surface;
- `Docs/shared/Ripple_VISUAL_REFERENCE_INVENTORY.md` and
  `Docs/shared/wireframes/` for reference classification and neutral visual
  coverage;
- `Docs/shared/Ripple_DESIGN_SYSTEM.md` for tokens, reusable elements,
  native-control policy, and motion/accessibility acceptance;
- `Docs/shared/Ripple_DATA_MODEL.md` for entities, invariants, persistence,
  projections, and use cases;
- `Docs/shared/IOS_ARCHITECTURE.md` for iOS boundaries;
- `Docs/shared/Android/ANDROID_ARCHITECTURE.md`,
  `Docs/shared/Android/ANDROID_UI_SPEC.md`, and
  `Docs/shared/Android/UI/README.md` for Android mappings and evidence.

If the Android project is intentionally maintained elsewhere, record that as
**implementation repository not present locally**, not as a fabricated failure.
The shared handoff can still be blocked by missing Android mapping documents.

## Audit workflow

### 1. Establish the audit scope

Record the requested target: documentation handoff, Android implementation
start, a specific surface, or the full product. Do not claim that a partial
surface audit covers all 22 Ripple surfaces. Preserve unrelated user changes
and inspect the current working tree before interpreting failures.

### 2. Run the deterministic audit

From the repository root, run:

```sh
python3 skills/android-conversion-readiness/scripts/audit_android_readiness.py .
```

Use `--format json` when another tool needs machine-readable findings. The
script checks required contracts, stable IDs, canonical sections, visual
asset decodability, Android mapping mentions, and common production Swift
token violations. A non-zero exit code means blockers were found; warnings do
not make the script fail unless `--strict` is requested.

The script is a triage instrument, not a proof of semantic correctness. Read
the relevant documents and inspect each reported finding before changing
anything.

### 3. Verify documentation readiness

Every canonical surface must have:

- exactly one stable ID and one canonical Markdown file;
- purpose, entry/exit, ordered layout, read model, actions/use cases, states,
  validation, accessibility, responsive behavior, design contract, forbidden
  behavior, and related contracts;
- a reference-evidence/visible-element inventory with state, viewport, crop,
  classification, system-owned chrome exclusions, and product-owned content;
- a real PNG preview and a same-stem editable SVG source, both decodable;
- a current surface version, `Last verified`, and immutable timeline entry;
- no platform framework instructions in the platform-independent description.

Compare the inventory against every current reference. Do not accept a compact
wireframe that silently drops context rows, chart families, repeated rows,
continuation cues, actions, or wearable density. Classify differences as
state, viewport, crop, localization, native chrome, platform expression,
stale artifact, or authority conflict.

### 4. Audit design-system ownership and token use

Treat the design system as a prerequisite, not a visual clean-up phase:

- every shared color, type role, spacing/size, radius, motion curve, shadow or
  reusable component has one named owner in the design-system contract;
- production feature/app/extension code consumes named tokens such as
  `RippleColor`, `RippleFont`, `RippleSpace`, `RippleRadius`, `RippleLayout`,
  `RippleMotion`, or approved reusable components;
- feature-local hex colors, direct `Color(...)` values, custom fonts, raw
  semantic typography, numeric spacing/radii, ad-hoc shadows, and direct
  animation curves are findings unless they are inside a token definition,
  documented geometry algorithm, or narrowly scoped platform adapter;
- system semantic colors such as secondary/tertiary are allowed only when
  the design contract permits them; they are not a replacement for a Ripple
  product color;
- Android must have a native mapping for every shared role/component and may
  express it with resources, Material/Wear roles, or native controls without
  changing product-owned hierarchy.

Token findings are blockers for product UI readiness when they affect a
feature, reusable component, extension, or shared surface. Findings in demos,
previews, tests, or documented platform adapters are warnings until reviewed.
Do not auto-replace values: first determine whether the value is a real token,
geometry constant, or a missing design-system decision.

### 5. Audit data and boundary prerequisites

Confirm that the Android handoff identifies:

- canonical internal units, identity, date/time zone, defaults, ordering,
  deletion, and conflict rules;
- named read models and write use cases for every documented mutation;
- one logging path for app, widget, intent, notification, control, and watch;
- projection failure behavior that does not roll back an accepted local log;
- persistence, synchronization, permission, health, notification, and export
  ownership;
- tests or an explicit test plan for goal calculation, unit conversion,
  logging/undo, use-case invariants, and documented motion/layout rules.

An Android project may implement these boundaries natively, but it must not
move domain truth into Compose/Wear UI, preferences, widgets, or projections.

### 6. Audit Android mapping and acceptance prerequisites

For each stable ID, locate the Android-native entry point or an explicit
handoff target in the Android UI/architecture documents. Check that the map
preserves product-owned regions, region order/grouping, state variants,
accessibility semantics, localization, compact/regular/expanded behavior,
wearable continuation, and system-surface ownership.

Confirm that the Android handoff defines representative acceptance for:

- light/dark mode, large text/font scale, reduced motion, accessibility, and
  localization;
- empty, ready, error, offline/sync, permission, success, and destructive
  recovery states where applicable;
- phone, tablet/expanded, resize/fold, Wear, widgets, notifications,
  controls, shortcuts/intents, complications, and export/share;
- real emulator/device captures separately from shared wireframes.

An existing iOS capture is evidence of hierarchy, never proof of Android
runtime behavior. A missing Android project is a deferred implementation
state; a missing Android contract or unresolved platform mapping is a blocker.

## Finding severity

- **Blocker:** missing authority/contract, contradictory product meaning,
  missing canonical surface or visual source, unowned product UI, direct
  feature-local design tokens, missing source-of-truth/use-case boundary, or
  an Android mapping that drops/recomposes required product-owned content.
- **Warning:** incomplete runtime evidence, unverified device state, demo/test
  styling, platform-adapter raw geometry, stale-but-classified capture, or a
  test/acceptance gap that does not yet invalidate the documented handoff.
- **Pass:** evidence satisfies the check.
- **Unknown/deferred:** the repository intentionally delegates the decision to
  an external Android project or later acceptance step. It must not be
  reported as a pass.

## Required report

Report the result in this compact structure:

```text
Android conversion readiness: READY | READY WITH WARNINGS | BLOCKED
Scope: <full handoff or named surfaces>
Evidence: <script command plus documents/captures inspected>

Blockers:
- <severity> <file:line or check> — <finding>; required authority/action.

Warnings / deferred:
- <finding>; owner or acceptance step.

Passed gates:
- <coverage/token/boundary/acceptance gate>

Next actions:
1. <smallest authority-preserving action>
```

Do not say “Android-ready” when runtime acceptance, external-project work, or
unresolved findings remain unverified. Use the reference checklist for the
manual checks that static analysis cannot establish.

## Related resources

- [`references/readiness-checklist.md`](references/readiness-checklist.md) for
  the manual gate matrix and evidence expectations;
- [`scripts/audit_android_readiness.py`](scripts/audit_android_readiness.py)
  for deterministic repository checks;
- `$cross-platform-product-documentation` when the shared contracts or visual
  inventories are incomplete;
- `$android-app-from-documentation` only after this audit's blockers are
  resolved or explicitly accepted by the user.
