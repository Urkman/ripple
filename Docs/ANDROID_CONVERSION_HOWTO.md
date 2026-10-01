# Android App Conversion How-to

This project-independent guide describes how to assess and convert a documented
product into a native Android implementation. It applies whether the source
product currently runs on iOS, another platform, or multiple platforms.

This is process guidance, not a product or architecture contract. Product
behavior must come from the authoritative documentation handoff in
`Docs/shared/`. The Android target repository's own `AGENTS.md` and established
conventions govern Android implementation. Do not copy one project's agent
instructions into an unrelated Android repository.

For this workflow, start in the current working directory and build the
Android app there from the complete documentation handoff in `Docs/shared/`.
The source application and its implementation repository are not required
inputs. Do not inspect or import source-platform application code when the
shared documentation is available.

## Prerequisites

Treat these as readiness gates before broad product implementation. A gate can
be marked not applicable only with a documented reason and owner.

### 1. Product scope and authority are clear

- The conversion has an agreed scope: full product or named features/surfaces,
  target device classes, supported platforms, and explicit exclusions.
- There is one authoritative product source for outcomes, behavior, flows,
  terminology, and release scope, with a stated precedence order for companion
  documents.
- Conflicts between requirements, existing behavior, and visual references are
  resolved by the product owner or recorded as blockers. They are not settled
  by guessing during implementation.
- The current working directory is the Android target working tree, and
  `Docs/shared/` is the complete product and implementation handoff. Source
  application code and source-platform repository instructions are not needed
  inputs for the Android build.

### 2. Product behavior and surfaces are documented

- Every in-scope screen, sheet, onboarding step, wearable surface, widget,
  notification, shortcut, control, or other system entry point has a stable
  identity and a canonical description, or is explicitly marked not applicable.
- Each description covers the user outcome, entry/exit, ordered layout,
  required data, actions/domain operations, states, validation, accessibility,
  responsive behavior, and forbidden behavior.
- Shared flows, navigation, platform-specific behavior, and out-of-scope
  features are clear. For a complete conversion, the inventory covers the
  complete product; a partial conversion names the deferred surfaces.
- The surface index and detailed descriptions agree, and every index entry
  resolves to exactly one canonical description.

### 3. Visual evidence and element coverage are usable

- Current references are distinguished from examples, exploration, stale
  images, and runtime captures. Each reference identifies its relevant state,
  viewport, crop, and platform-owned chrome.
- Product-owned visible content is inventoried: headings, values and units,
  controls, context rows, repeated items, status feedback, chart structure,
  reading order, and continuation/clipping behavior.
- Wireframes or equivalent visual references exist for intended states and
  viewports where visual evidence is available, with editable sources where
  maintained. If no image exists, the written layout contract is detailed
  enough to implement and the missing visual evidence is explicit. Images
  support the written contract; they do not override it or prove Android
  runtime behavior.
- No required element or relationship is silently omitted, merged, reordered,
  or replaced with a simpler layout.

### 4. The design system is owned and used consistently

- Shared color, typography, spacing, size, shape, motion, elevation, and
  reusable-component roles have named definitions and owners.
- The Android implementation will consume the named design-system
  tokens/components; each raw value must be migrated or classified as an
  allowed geometry calculation, platform adapter, or other documented
  exception.
- Source application UI code is outside this workflow. Verify token ownership
  and usage against `Docs/shared/` and the Android implementation as it is
  built; do not block the Android build on an unavailable source UI audit.
- Missing roles are resolved in the design-system contract before they are
  independently invented by the Android implementation. Android mappings
  preserve semantic roles while using native resources, components, and system
  controls where appropriate.
- Contrast, state communication, focus, touch targets, large text, and reduced
  motion have acceptance criteria.

Unclassified token violations or an incomplete design-system contract are a
blocker for product UI work, not a polish item to defer until the end.

### 5. Domain and data boundaries are defined

- Entities, IDs, units, date/time-zone meaning, defaults, ordering, validation,
  deletion/restore, and conflict behavior are specified where relevant.
- The source of truth is explicit. Persistence, synchronization, imports and
  exports, permissions, notifications, health integrations, and other
  projections have clear owners and failure behavior.
- Privacy/security expectations, data retention, and any migration or
  compatibility behavior are defined where applicable.
- Each mutation routes through a named domain operation or an equivalent
  documented boundary. System surfaces and alternate clients do not create
  parallel business logic or an undocumented second store.
- Required domain invariants have a test strategy independent of UI.

### 6. Android expression and acceptance are mapped

- Each in-scope surface has an Android-native entry point or an explicit,
  assigned implementation target.
- Navigation, adaptive layouts, system bars/insets, permissions, platform
  controls, widgets, notifications, wearable behavior, and share/export flows
  are mapped where applicable.
- Android may use native presentation rather than copy another platform's
  chrome, but it preserves documented outcomes, product-owned elements,
  hierarchy, states, and accessibility semantics.
- Acceptance criteria cover the relevant locales, light/dark appearance, large
  text, accessibility, reduced motion, compact/expanded/resized layouts, and
  empty, success, error, offline, permission, and recovery states.
- Build, lint, unit, UI/instrumentation, and emulator/device checks are
  identified. Runtime evidence is planned separately from documentation and
  wireframe review.

### 7. The Android implementation environment is understood

- The current working directory is selected as the Android target, and its
  existing changes are understood before files are replaced or generated.
- It has Android-specific binding instructions. If they are missing, create
  them in the current target; the [project-neutral Android AGENTS template](ANDROID_AGENTS_TEMPLATE.md)
  can be copied and merged with target-repository rules.
- For an existing app in the current folder, its Gradle root, modules, package
  IDs, SDK/toolchain, architecture, localization, test commands, and available
  devices are known. For a new app, choices that the contracts leave open are
  recorded before they shape the product code.
- Required credentials, permissions, external services, hardware, and build
  infrastructure are available or have an explicit setup owner.

If the current folder does not contain an Android project yet, create the
Android project there as part of the requested implementation. Do not switch
to or inspect a separate source application to fill that setup gap.

## Readiness outcomes

Use evidence, not an overall impression, to classify the handoff:

- **READY** — required product, design, data, and Android mapping decisions are
  documented and consistent. Remaining target-repository setup is either done
  or explicitly planned.
- **READY WITH WARNINGS** — no product-semantic blocker remains, but specified
  runtime, device, integration, or accessibility evidence is still pending and
  has an owner or acceptance step.
- **BLOCKED** — a required decision or contract is missing or contradictory;
  a surface or product-owned element is unaccounted for; token ownership/use is
  unresolved; data boundaries are unclear; or the Android mapping would need
  to invent or remove product behavior.

When blocked, stop before broad product implementation. Report the exact
document and issue, the authority that must resolve it, and the smallest next
action.
Do not silently repair a product decision inside Android code. An absent target
Android project in the current folder is a setup task, not a reason to inspect
the source application.

## Conversion workflow

1. **Start in the current folder and establish authority.** Use the current
   working directory as the Android target. Name the requested surfaces, target
   devices, exclusions, and owners. Read the current folder's Android-specific
   instructions independently from the complete `Docs/shared/` handoff. Do not
   inspect or request a source application repository.
2. **Use the complete shared handoff in place.** Read the authoritative product
   and domain contracts, surface index and descriptions, design system, Android
   architecture/UI mapping, visual inventory, and all linked references/assets
   under `Docs/shared/`. Preserve directory structure, relative links, and
   version context. Do not replace the documentation handoff with source-app
   code or screenshots.
3. **Run a documentation-first readiness review.** Inspect `Docs/shared/` and
   the current Android project only. Check surface coverage, visual inventories,
   named-token use, domain/data boundaries, Android mappings, and acceptance
   criteria against the prerequisites above. Keep findings evidence-backed and
   classify each as blocker, warning, pass, or deferred.
4. **Resolve blockers at their source.** Update the document that owns the
   decision, synchronize affected companion/platform documents, and repeat the
   relevant readiness checks. Do not introduce a new product decision merely
   to make the audit pass.
5. **Inspect the current Android target and create a traceability map.**
   Preserve existing work. For every in-scope stable surface ID, map its
   canonical description to Android entry points, state/data owners, domain
   operations, design tokens/components, system adapters, and verification
   coverage. A surface need not correspond to one source file.
6. **Implement in small vertical slices.** Establish domain/data boundaries and
   shared design-system foundations before broad UI work. Then implement
   surfaces and system clients in reviewable increments, using documented
   operations and native Android controls where they meet the contract. Keep
   every visible element and state traceable to the source contract.
7. **Verify continuously and at completion.** Run targeted tests after each
   slice, then the full applicable build, lint, unit, UI/instrumentation, and
   packaging checks. Exercise real flows on representative emulators/devices;
   inspect accessibility, adaptive layouts, and relevant system integrations.
8. **Report the result honestly.** List implemented IDs and coverage, checks
   passed, runtime flows actually exercised, unresolved or deferred items,
   known warnings, and anything not verified. Do not present a compile, a
   wireframe, or another platform's screenshots as Android runtime acceptance.

## Best practices

- Keep product meaning in the authoritative shared contract and Android
  controls/navigation in the Android mapping. Do not make either document a
  competing source for the other's decisions.
- Prefer semantic equivalence and native Android affordances over pixel-copying
  another platform. Preserve all product-owned information, actions, state,
  hierarchy, and accessibility outcomes.
- Reuse the named design tokens and components. If a needed role is missing,
  resolve it through the design-system owner instead of adding a local value.
- Route writes through documented domain operations. System surfaces and
  alternate clients should reuse those operations rather than duplicate
  business rules.
- Implement and verify thin vertical slices. Keep the documentation-to-code
  map current, preserve existing repository work, and avoid unrelated
  refactors or dependencies.
- Label findings and evidence precisely as verified, documented, warning, or
  deferred. A screenshot, wireframe, or successful compilation is not proof of
  behavior that it cannot observe.

## Starter prompt

Use this prompt from the Android target's current working directory. It builds
from the shared documentation handoff in place; it does not require a source
application repository.

```text
Build the complete native Android app in the current working directory from
the documentation handoff in `Docs/shared/`.

Use `$android-app-from-documentation` as the implementation skill. Treat every
document under `Docs/shared/` as the product and Android implementation input:
read the PRD, screen catalog, every canonical surface description, design
system, data model, Android architecture/UI contracts, visual inventory,
wireframe pack, and linked Android reference material before broad UI work.

Do not inspect, import, or request the source application, its iOS/Apple source
code, or a separate source repository. Do not ask for a separate target path:
the current working directory is the Android target. Read an Android-specific
`AGENTS.md` in the current folder if present, preserve existing Android work,
and create or complete the Android project in this folder. If Android-specific
instructions are missing, establish them in the current target before broad
implementation using the applicable project rules.

Requested scope: [FULL CONVERSION OR NAMED SURFACES/FEATURES]
Target devices/platform surfaces: [PHONE, TABLET, WEARABLE, SYSTEM SURFACES, ETC.]

Before coding, perform an evidence-backed documentation readiness review using
the prerequisites in this guide. Verify authoritative product behavior,
complete surface and state coverage, visual-element inventories, design-system
token ownership, domain/data boundaries, Android-native mapping,
localization/accessibility/adaptive requirements, and an executable acceptance
plan from `Docs/shared/` and the current Android project only. Return READY,
READY WITH WARNINGS, or BLOCKED with exact file and line/check evidence,
severity, and next action. Do not invent product behavior or silently edit the
shared contract just to clear a finding; any contract change must follow its
documented authority process.

If BLOCKED, stop before product implementation and report the smallest
authority-preserving actions needed. If READY WITH WARNINGS, track each warning
and its verification owner. If the status is READY or READY WITH WARNINGS,
create or update a documentation-to-code map before broad UI work and proceed
in small, testable slices. Follow the current Android project's architecture
and the documented domain operations, use named design-system tokens, preserve
every documented product-owned element, and prefer native Android controls
where they satisfy the contract.

Run applicable build, lint, unit, UI/instrumentation, and emulator/device
checks. Finish with implemented surface coverage, checks and runtime flows
actually exercised, remaining blockers/warnings/deferred work, and anything
not verified. Do not claim runtime acceptance from compilation or static
images alone.
```
