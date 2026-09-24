# Android Repository Agent Instructions

This is a reusable, product-neutral baseline for an independent Android
implementation repository. Copy it to that repository's root as `AGENTS.md`,
then merge it with any existing repository instructions. Do not copy a source
platform's root `AGENTS.md` over the Android repository's instructions.

This file governs implementation process and general Android engineering
boundaries. It does not define a product, invent requirements, or replace the
repository's product and platform contracts.

## 1. Instruction and product authority

- Follow applicable system, developer, and user instructions, plus the target
  repository's contribution and security rules.
- This `AGENTS.md` governs general implementation workflow and engineering
  boundaries. More-specific target-repository instructions may refine it but
  must not silently contradict higher-priority instructions.
- Use the product specification (PRD or equivalent) as the authority for
  product scope, outcomes, flows, and domain behavior, following the precedence
  declared by the project.
- Use the surface index and each canonical screen/sheet/system-surface
  description for documented layout, actions, states, and accessibility.
- Use the design-system and data-model contracts for their respective roles,
  tokens, entities, invariants, and operations.
- Use the Android architecture/UI contract for Android-native mappings,
  navigation, system integrations, adaptive behavior, and acceptance criteria.
- Source-platform code, screenshots, and architecture are evidence or context;
  they are not automatically Android implementation instructions and do not
  override written product behavior.
- If a requirement is missing, contradictory, or insufficient to determine
  behavior, record the exact gap and ask the responsible owner. Do not invent a
  plausible product decision or hide a conflict in code.

## 2. Protect the target repository

- Before editing, inspect the current working tree and read the applicable
  repository instructions. Preserve existing user changes and established
  module, naming, dependency, and test conventions.
- Identify the Gradle root and wrapper, application/library modules, build
  variants, package IDs, SDK and language/toolchain versions, architecture,
  localization/resources, test and lint tasks, and available emulator/device
  targets. Discover actual tasks instead of assuming task names.
- Do not replace a functioning architecture or upgrade the toolchain merely to
  match a preferred example. Propose necessary structural changes with evidence
  and keep them within the requested scope.
- Avoid destructive operations, unrelated refactors, and unrequested external
  changes. Do not commit, push, publish, or modify remote services unless
  explicitly requested.
- Do not add a dependency without checking the existing stack and documenting
  why the dependency is needed and how it will be tested.

## 3. Check implementation readiness before broad UI work

Review the applicable product and Android documentation before implementation.
For the requested scope, confirm:

- product scope, source-of-truth authority, flows, and exclusions are clear;
- every in-scope surface and system entry point has an adequate contract, or is
  explicitly deferred/not applicable;
- states, visible product-owned elements, references, and adaptive behavior
  are accounted for;
- design tokens and reusable components have named owners, existing production
  UI has been checked for unclassified feature-local styles, and Android has a
  native mapping for the required roles;
- domain data, persistence, mutations, synchronization/projections, and failure
  behavior have clear owners and testable invariants;
- localization, accessibility, privacy/security, and acceptance expectations
  are documented where applicable; and
- the target repository and verification environment are available, or their
  setup and limitations are explicitly recorded.

Classify findings as **blocker**, **warning**, **pass**, or **deferred** with
evidence and an owner/next action. A known, unclassified feature-level token
violation or missing product/data decision blocks the affected product UI. If
source code or a device is unavailable, mark the relevant check unknown or
deferred; never report it as passed. Resolve blockers through the document or
owner that has authority over the decision before implementing dependent
behavior.

## 4. Keep architecture boundaries explicit

Follow the architecture already established by the target repository and its
Android architecture contract. Where the project is new and the contract leaves
the choices open, prefer current supported Android APIs and Kotlin with Jetpack
Compose for app UI; record decisions in the appropriate project document.

- UI components render state and emit explicit user events. They do not own
  persistence, domain policy, or unrelated platform side effects.
- ViewModels or the repository's equivalent presentation layer coordinate
  lifecycle-aware state and domain operations; they are not a second data
  store.
- Domain rules and named operations own product invariants when the project
  defines a platform-independent domain boundary.
- Repositories and data adapters own persistence, migrations, synchronization,
  and external projections according to the data contract.
- Keep one documented source of truth. Preferences, caches, widgets, health
  services, and transport layers must not become an undocumented competing
  store.
- Alternate entry points—such as widgets, notifications, shortcuts, controls,
  and wearable clients—reuse the same documented operations as the main app.
- Keep state unidirectional and lifecycle-safe. Use stable identity for
  dynamic content and make asynchronous work cancellation-aware.

## 5. Preserve design and surface contracts

- Use named design-system tokens and reusable components for product styling.
  Do not create feature-local colors, typography, spacing, shape, elevation, or
  motion systems. Raw values are allowed only where the project documents a
  geometry algorithm or narrow platform adapter.
- Prefer native Android controls for ordinary platform behavior when they
  satisfy the documented outcome and accessibility requirements. Do not copy
  another platform's chrome just for pixel parity.
- Preserve every documented product-owned region, element, relationship,
  reading order, state, and action. Native expression may adapt presentation;
  it may not silently omit, merge, reorder, or substitute product content.
- Treat reference images as visual evidence, not a source for undocumented
  behavior or proof of Android runtime correctness.
- Keep feature implementation traceable to the canonical surface contract.
  One canonical description per surface does not require one source file per
  surface; follow the target repository's native organization.
- Provide the documented localization, accessibility semantics, large-text
  behavior, light/dark appearance, reduced motion, and compact/expanded or
  wearable behavior that applies to the requested scope.

## 6. Implement in traceable, testable slices

1. Read the product and platform contracts relevant to the requested scope,
   including all linked references and required state/viewport variants.
2. Create or update a documentation-to-code map before broad UI work. For each
   in-scope stable surface ID, map its Android entry point, state/data owners,
   domain operations, design tokens/components, platform adapters, and
   verification coverage.
3. Establish or extend domain/data boundaries and shared design-system
   foundations before building dependent surfaces.
4. Implement in small increments. After each architectural slice, run the
   narrowest relevant compile and tests before continuing.
5. Update product or platform documentation when a change alters a documented
   behavior, surface, data rule, design role, or Android mapping. Follow the
   owning project's versioning, review, and synchronization rules.
6. If an element or behavior cannot be implemented as documented, record the
   exact mismatch and resolve it through the project's authority process before
   marking the surface complete.

Use any relevant implementation, language, UI, or testing skills available in
the active agent environment. Read their instructions fully before use. Such
skills supplement this repository's instructions and contracts; they do not
override them.

## 7. Verify and report honestly

Run the checks supported by the target repository, as applicable:

- production compile/build and packaging checks;
- formatting, lint, and static analysis;
- unit tests for domain invariants and data boundaries;
- UI/instrumentation tests for documented flows and states; and
- emulator/device interaction for representative surfaces, accessibility,
  adaptive layouts, and system integrations.

For each implemented surface, compare the Android result with its written
element/state contract and applicable references. Record omissions, platform
limitations, failed checks, unavailable devices/services, flaky tests, and
unverified states. Do not claim runtime acceptance from compilation, unit
tests, wireframes, or screenshots from another platform alone.

The completion report should state:

- scope and surface IDs implemented;
- documented element/state coverage and explicit exclusions;
- build, lint, and test results;
- emulator/device flows actually exercised;
- documentation gaps, warnings, deferred work, and anything not verified; and
- dependencies, data migrations, or significant architecture changes.
