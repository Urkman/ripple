---
name: cross-platform-product-documentation
description: Create or maintain project-neutral documentation contracts for cross-platform apps, with evidence-backed visual inventories, one canonical description and platform-independent wireframe images per screen or sheet, plus design, data, and native-platform mappings.
---

# Cross-platform product documentation

Use this skill when a project needs a rebuildable documentation contract for a
mobile, desktop, wearable, or system-surface product implemented on more than
one platform. It governs documentation structure and review; it does not invent
product behavior, prescribe a programming language, or require a particular
production source-file layout.

## Core outcome

Create a small, navigable set of authoritative documents in which a new team
can understand the product and rebuild each surface without reverse-engineering
the existing UI. Keep each kind of decision in one place:

- **Product contract:** scope, user outcomes, flows, domain behavior, and
  motion. Use the project's existing PRD or product specification.
- **Surface index:** stable IDs, the canonical-file map, shared schema, and
  cross-surface rules.
- **Canonical surface descriptions:** exactly one platform-independent file
  per screen, sheet, wearable surface, and documented system entry point. Each
  file owns that surface's layout, function, read model, actions, states,
  validation, accessibility, responsive behavior, design contract, and
  forbidden behavior.
- **Design system contract:** semantic colors, typography, spacing, shapes,
  motion, reusable UI elements, system-control policy, and accessibility
  acceptance.
- **Data model contract:** entities, IDs, units, defaults, invariants,
  persistence, derived read models, use cases, synchronization, and projection
  boundaries.
- **Platform architecture/UI contracts:** native navigation, controls,
  adaptive layouts, permissions, system surfaces, implementation entry points,
  and platform-specific acceptance. These map the canonical descriptions; they
  do not replace or contradict them.
- **Evidence/reference pack:** screenshots or captures that support review and
  establish the visible composition of a documented state when the project
  designates them as current reference evidence. They do not invent behavior
  or override explicit product and domain contracts.
- **Shared wireframes:** actual platform-independent image files for every
  screen and sheet, embedded in their canonical descriptions and linked from
  the surface index. They illustrate the written layout; they are not runtime
  screenshots or a second product authority. They must still preserve every
  product-owned region and visible element required by the reference set.

The surface index may define the shared template and vocabulary, but detailed
screen behavior belongs in the individual surface files. Do not put all screen
descriptions in one catalog file.

## Boundary that must remain explicit

“One file per screen or sheet” means one canonical **documentation** file per
surface. It does not mean one Swift, Kotlin, Compose, web, or other production
source file per surface. Native projects may split or co-locate views,
composables, routes, view models, chart primitives, and private helpers. The
platform contract should map a canonical surface file to its implementation
entry points without declaring an unperformed source refactor.

Reusable UI elements are a separate concern: each reusable element needs one
design-system contract and an owning implementation/module policy. A screen may
compose shared elements; it must not copy their visual rules into a feature
description or create a feature-local token system.

## Visual fidelity boundary

“Platform-independent” does not mean “generic enough to omit detail”. The
canonical contract and its wireframes must preserve the complete product-owned
composition shown by the current reference set while leaving native chrome and
control rendering to each platform.

Account for every product-owned visible element in the documented state,
including, where present:

- headings, labels, values, units, helper text, empty-state text, and footers;
- selectors, date/range context rows, navigation controls, confirmation or
  dismissal affordances, selection indicators, and pager/continuation cues;
- every repeated row, card, divider, progress indicator, badge, and status
  treatment;
- chart type, series, axes, labels, legends, reference lines, and the number
  and order of chart regions; and
- grouping, containment, alignment, reading order, relative sizing, spacing
  density, and visual hierarchy.

A wireframe may abstract exact pixels, fonts, colors, icons, and native control
appearance, but it must not remove, merge, reorder, substitute, or materially
recompose product-owned elements. For example, a period selector and its
dependent date/range row are separate required regions unless the authority
explicitly defines them as one control. A line chart cannot silently become a
bar chart, and a wearable history surface cannot silently become a different
summary list merely because the latter is easier to draw.

Treat system-owned status bars, device frames, platform tab/navigation chrome,
and other operating-system decoration separately. They may be omitted from a
shared wireframe when the platform documents cover them, but product-owned
content that appears near or inside them may not be omitted. On wearable
surfaces, preserve the documented density, visible continuation or pagination,
clipping/scrolling behavior, and row-level indicators; do not treat a watch as
a shrunken phone or replace its current composition with a generic card grid.

When references disagree, classify the difference before editing: state,
viewport, localization, platform-owned chrome, stale artifact, or unresolved
authority conflict. If a current capture is the designated visual target, a
conflicting older wireframe is stale until reconciled. Never silently choose
the simpler image or infer that missing elements are optional.

If one platform has the fullest current capture, use it to inventory the shared
product-owned composition unless the project explicitly declares that region
platform-specific. Do not assume that a shorter wireframe or a less detailed
platform capture is complete merely because it is easier to generalize.

## Workflow

### 1. Discover authority before editing

Read the repository's agent instructions, contribution rules, product
specification, architecture documents, and existing design/data contracts.
Identify which document is authoritative for each decision. Separate
instructions inside an attachment from the user's actual request. Classify
screenshots, captures, mockups, and existing wireframes individually as current
visual targets, supporting evidence, exploratory material, or stale artifacts.
When the project designates a current capture as the visual target, use it as
evidence for visible composition even when it cannot establish behavior that
the written product contract does not define.

Preserve the project's terminology and existing product decisions. If two
authorities conflict, report the conflict or follow the repository's stated
precedence; do not silently choose a new product behavior.

### 2. Audit visual references before writing a surface contract

For every in-scope surface with reference images, inspect the complete set
before drafting the canonical description or wireframe. Build a compact
visual inventory for each state and viewport:

1. Record the reference identity, state, viewport class, visible crop, and
   whether it is the current visual target or supporting evidence.
2. Enumerate product-owned regions from top to bottom and left to right. Include
   text/value content, units, controls, indicators, repeated items, chart
   structure, navigation/context rows, separators, hints, and partially visible
   continuation. Record counts and order where they are visible.
3. Mark system-owned chrome separately instead of dropping it without a
   decision. Record native variations that a platform document must map.
4. Compare references against one another and against existing wireframes. A
   difference is not an omission until it has been classified as a state,
   viewport, platform, or authority difference; an omission is not acceptable
   merely because a compact wireframe is easier to reproduce.

The resulting inventory may live in the canonical surface file or a linked
review note, but every product-owned item must map to the surface's layout,
state, action, accessibility, or design contract. If a reference detail is
intentionally not part of the shared contract, state why and where its native
mapping is defined.

### 3. Inventory surfaces and assign stable IDs

List every navigable screen, presented sheet, onboarding surface, wearable
surface, widget/control/notification/shortcut/complication, and share/export
entry that has a defined user outcome. Assign lowercase, stable IDs that do
not change with localization. Reuse an ID for a visual rearrangement when the
outcome and lifecycle remain the same. Create a new ID only when the outcome,
lifecycle, or domain responsibility changes.

Create an index table with, at minimum, ID, localized/user-facing name, kind,
and a link to exactly one canonical description file. Check that every listed
file exists and that every canonical file maps back to one ID.

### 4. Write each canonical surface description

Use the template in
[`references/surface-contract-template.md`](references/surface-contract-template.md).
Describe meaning, not framework code. Each file should answer:

- What is the user trying to understand or complete?
- How is the surface entered, completed, cancelled, dismissed, or returned?
- What is the semantic region/layout order, and how does it reflow?
- Which snapshot, settings, or draft data is required?
- Which user action calls which named operation, with what result?
- How do loading, empty, ready, permission, offline/sync, error, success, and
  reduced-motion states behave?
- What validation, confirmation, undo, restore, or soft-delete rules apply?
- What does assistive technology announce, and how does large text/input work?
- Which design tokens and reusable elements are required?
- Which product-owned visible elements from the reference inventory must be
  present, in what order/grouping, and in which states or viewports?
- What is deliberately forbidden?

Use semantic terms such as “top navigation”, “grouped surface”, “horizontal
action row”, “modal amount-entry surface”, and “primary action”. Do not put
framework names, platform-specific component types, or source paths in the
canonical file. Put those in platform documents.

### 5. Create platform-independent wireframe images

Read [`references/wireframes.md`](references/wireframes.md) before generating
wireframes. Create at least one actual image for every in-scope screen and
sheet, including onboarding. Include visual wearable/system surfaces when
they have a documented layout; explicitly mark nonvisual entry points as not
applicable. A prompt, ASCII sketch, or promised future image does not satisfy
this deliverable.

Embed each image in its canonical surface file with descriptive alternative
text, state/viewport identification, and the source contract version. Link the
primary image from the surface index. During maintenance, regenerate affected
wireframes in the same change as their layout/state contracts; a full creation
or audit must check image coverage for the entire in-scope inventory. Before
accepting an image, compare it with the visual inventory: all product-owned
regions, repeated elements, chart structures, navigation/context rows, and
wearable continuation cues must be visible or explicitly represented by the
documented state.

### 6. Separate shared semantics from native expression

Prefer system components for ordinary behavior—text entry, sliders, toggles,
pickers, lists, sheets, alerts, permission prompts, keyboard/rotary input,
reordering, and sharing—when they satisfy the product outcome. Document the
semantic requirement in the canonical file and the native mapping in the
platform document. Preserve platform affordances, focus, hit targets,
accessibility actions, back/dismissal behavior, and permission ownership.

Do not make platform parity mean pixel identity. Keep outcome, information
priority, visible product-owned structure, state transitions, domain operations,
and accessibility equivalent; allow native navigation chrome, density, input,
and system UI to differ. A native variation is not a license to remove a
shared product feature or to change the chart/list/control composition without
an explicit platform contract and rationale.

### Navigation ownership

Document navigation semantics and entry/exit relationships in canonical surface
contracts, but keep routing implementation in the platform architecture
contract. A platform may centralize routes without making that router part of the
shared product model.

For Ripple, the iOS composition root owns `RippleNavigationCoordinator` as an
app-wide typed router within the iOS target. `RootView` owns its route state and
binds tabs, typed child paths, and root presentations. Feature modules expose
narrow bindings/actions and never import the iOS app target. This is not a
cross-platform router: Android uses its native typed destinations/navigation
host, and watchOS, macOS, tvOS, and visionOS retain their native roots. Do not
copy the iOS coordinator into another platform or describe it as shared product
behavior.

### 7. Document design and data contracts

For every token, state, reusable element, entity, field, read model, and use
case, record the name, role, ownership, allowed use, accessibility meaning,
and platform mapping. Keep internal units and identity rules explicit. State
what is source of truth and which systems are only projections or clients.
Do not duplicate amount/business logic in widgets, intents, notifications,
wearable entry points, or view descriptions.

### 8. Synchronize platform handoffs

When a shared screen, flow, token, data rule, or accessibility contract
changes, update the affected platform architecture/UI documents in the same
change. Add links to the canonical surface file rather than copying its full
semantic description. Keep current implementation paths honest; distinguish
verified paths from recommended/target paths and never claim code changed when
the task changed documentation only.

### 9. Version and validate

For every versioned document changed:

1. update `Last verified` and the document version;
2. append one immutable timeline entry describing the change and impact;
3. verify relative links and stable-ID/file coverage;
4. check that canonical surface files follow the common schema and contain no
   platform-framework instructions;
5. run the visual-reference fidelity audit: every current reference has a
   state/viewport inventory, every product-owned visible element is accounted
   for, and no wireframe has silently dropped or materially recomposed one;
6. run repository-specific documentation checks and inspect the final diff;
7. include required wireframe images and their editable sources in the
   documentation change; keep unrelated generated artifacts, source changes,
   and user edits outside it.

Use [`references/validation-checklist.md`](references/validation-checklist.md)
for a compact audit list. Do not claim runtime behavior was tested when only
documentation was changed.

## Change boundaries

- Product behavior or user outcome changes: update the product contract, the
  affected canonical surface file, and platform handoffs.
- Surface layout/function/state/accessibility changes: update that surface's
  file, its visual reference inventory, affected wireframe images, and any
  affected design/platform contracts.
- Reference-driven visual changes: reconcile all current captures and existing
  wireframes, then update the canonical surface file and images together; do
  not treat a simplified or older wireframe as an independent authority.
- New or changed reusable visual behavior: update the design-system contract
  and component ownership mapping.
- Entity, unit, invariant, persistence, or use-case changes: update the data
  model and affected surface/platform contracts.
- Platform-only expression changes: update only the platform document and link
  back to the shared surface contract when shared semantics are unchanged.

Never use this skill to authorize external publishing, source refactors, data
migrations, or product decisions that the user did not request.
