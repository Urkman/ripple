# Android conversion readiness checklist

Use this checklist after the static audit. It is a review aid, not a second
product contract. Follow the repository's authority order when a check exposes
a conflict.

## Gate matrix

| Gate | Required evidence | Block when | Warning/deferred when |
|---|---|---|---|
| Authority | `AGENTS.md`, PRD, surface catalog, design system, data model, iOS architecture, Android architecture/UI contracts | A required authority is missing, contradictory, or silently duplicated | The Android implementation repository is maintained elsewhere but its handoff contract exists |
| Surface inventory | Every stable ID maps to exactly one canonical Markdown file | An ID is missing, duplicated, or has no canonical description | A surface is explicitly out of the current implementation scope and recorded as such |
| Visual inventory | Reference identity, state, viewport, crop, classification, chrome exclusions, and product-owned elements | A current reference has unaccounted product-owned content or a wireframe drops/recomposes it | A capture is cropped, stale, or platform-specific and the difference is explicitly classified |
| Wireframe assets | Real PNG and same-stem editable SVG for every visual surface; decodable assets | An image/source is missing, malformed, or not linked from the canonical file | A documented non-visual system entry is explicitly marked not applicable |
| Design tokens | Named colors, typography, spacing, size, radius, motion, shadows, components, and Android mappings | Feature/component/extension production UI defines a local token or raw style value | Demo, preview, test, geometry algorithm, or documented platform adapter needs review |
| Data boundaries | Internal units, IDs, dates, persistence, sync, projections, named use cases | Android would write through UI, use health/widget state as truth, duplicate logging logic, or lack a required use case | External Android project must implement the mapped boundary later |
| Localization/accessibility | DE/EN copy policy, units, labels, values, focus/traversal, large text, reduced motion | Product copy or required semantics are missing or framework-hardcoded in shared docs | Runtime TalkBack/font-scale proof is pending but acceptance cases are specified |
| Adaptive behavior | Compact/regular/expanded, resize/fold, Wear, system-surface rules and state retention | A platform mapping drops a required region/action or invents a new behavior | No Android runtime capture exists yet and the gap is recorded |
| Acceptance | Build/test commands, representative state matrix, emulator/device capture plan | No way to verify a critical boundary or the definition of done omits a required surface | The Android app is not present locally but the external acceptance plan is explicit |

## Manual token review

Review production UI after the script reports token findings:

1. Start at the design-system contract and list the named role/component the
   value should consume.
2. Classify the raw value as a missing token, documented geometry algorithm,
   platform adapter, or accidental feature-local styling.
3. For a missing token, update the design-system contract and both platform
   mappings before changing consumers.
4. For an allowed geometry/platform value, document its scope and keep it out
   of the shared token namespace.
5. Re-run the audit and retain the original finding in the report if it is
   intentionally deferred.

Do not treat `Color.secondary`/`Color.tertiary`, native control defaults, or
system status/navigation chrome as Ripple product tokens without checking the
design-system policy. Do not infer Android equivalents by copying SwiftUI
values; map semantic roles to Android resources, Material/Wear roles, and
native controls.

## Surface coverage review

For each surface under review, compare the canonical inventory and Android
mapping in this order:

1. header/context and dependent date/range rows;
2. primary readout/hero and units;
3. ordered actions, selectors, and dismissal/confirmation affordances;
4. repeated rows/cards/marks and their counts;
5. state feedback, empty/error/retry/undo behavior;
6. responsive reflow, continuation, clipping, and wearable density;
7. accessibility names, values, actions, and large-text fallback.

Mark a product-owned element as covered only when a native Android expression
preserves its meaning, order/grouping, state, and accessibility. A component
name or a screenshot alone is not coverage evidence.

## Evidence language

Use precise status language:

- **Verified:** observed in the repository or a real runtime capture;
- **Documented:** specified by an authority but not runtime-verified;
- **Inferred:** never acceptable as a completion claim; resolve or label it;
- **Deferred:** intentionally assigned to the external Android project or a
  later acceptance step with an owner.

Screenshots support visible composition only. They cannot prove source-of-truth
boundaries, persistence, synchronization, accessibility, motion timing, or
Android runtime behavior.
