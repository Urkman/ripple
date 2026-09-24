# Ripple shared product documentation

This directory is the portable product and implementation handoff for Ripple.
It is the shared source set consumed by the iOS repository and the independent
Android repository; it does not contain or govern Android implementation code.

## Read in this order

1. [`Ripple_PRD.md`](Ripple_PRD.md) — product scope, outcomes, flows, domain
   behavior, and motion. This is the single versioned product contract.
2. [`Ripple_SCREEN_CATALOG.md`](Ripple_SCREEN_CATALOG.md) — stable surface IDs,
   canonical-file map, shared schema, and cross-surface rules.
3. [`screens/`](screens/) — exactly one platform-independent contract per
   screen, sheet, wearable surface, or system entry point. Start from the
   catalog; each file links its primary wireframe and review inventory.
4. [`Ripple_DESIGN_SYSTEM.md`](Ripple_DESIGN_SYSTEM.md) — named visual tokens,
   reusable UI contracts, native-control policy, and accessibility acceptance.
5. [`Ripple_DATA_MODEL.md`](Ripple_DATA_MODEL.md) — domain values, invariants,
   persistence, read models, use cases, sync, and projection boundaries.
6. Platform mappings — [`IOS_ARCHITECTURE.md`](IOS_ARCHITECTURE.md),
   [`Android/ANDROID_ARCHITECTURE.md`](Android/ANDROID_ARCHITECTURE.md), and
   [`Android/ANDROID_UI_SPEC.md`](Android/ANDROID_UI_SPEC.md). These explain
   native implementation and acceptance; they do not replace shared meaning.
7. Visual handoff — [`Ripple_VISUAL_REFERENCE_INVENTORY.md`](Ripple_VISUAL_REFERENCE_INVENTORY.md)
   classifies captures and audits visible content;
   [`wireframes/README.md`](wireframes/README.md) indexes neutral, editable
   screen illustrations; [`Android/UI/README.md`](Android/UI/README.md) indexes
   Android-specific layout illustrations and their evidence limits.

## Authority and change flow

Repository process and architecture boundaries are in the root
[`AGENTS.md`](../../AGENTS.md). The PRD owns product behavior. The screen
catalog and its individual descriptions own the shared surface index/schema
and each surface's layout and interaction contract. The design and data
documents own their respective shared contracts. Platform documents map those
decisions to native navigation, controls, storage, permissions, and source
modules.

When a product or surface changes, update the PRD first, then the affected
canonical surface description, its wireframe source and PNG, the visual
inventory, and each affected platform handoff in the same change. For a
platform-only mapping change, leave shared semantics untouched and update only
the relevant platform documents. Every changed versioned document must update
`Last verified` and append a new immutable timeline entry.

Each in-scope visual surface has one canonical Markdown file and a shared PNG
wireframe with a same-stem editable SVG. Wireframes are illustrations, not
runtime proof. The iOS images under `screens/ios/` are implementation evidence;
the Android images under `Android/UI/` are layout illustrations unless an entry
explicitly identifies a real runtime capture. Android build/device acceptance
belongs to the separate Android repository and must not be inferred from this
handoff pack.

## Validation

Review the [surface catalog](Ripple_SCREEN_CATALOG.md), [visual inventory](Ripple_VISUAL_REFERENCE_INVENTORY.md),
and [wireframe guide](wireframes/README.md) together. Check relative links,
stable-ID coverage, image/SVG pairs, version metadata, and the final diff.
Documentation validation does not claim that either app was built or exercised
on a device.
