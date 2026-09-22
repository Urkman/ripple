# Documentation-to-code map

Use this template when the Android project needs an explicit traceability
record. Store it where the repository's architecture documentation expects it;
do not create a competing product contract.

| Stable surface ID | Canonical description | Android entry point/module | State owner | Domain operations | Documented UI coverage | Design elements | Verification |
|---|---|---|---|---|---|---|---|
| `[id]` | `[path]` | `[route/module/entry]` | `[ViewModel/presenter]` | `[operations]` | `[all regions/elements and state/viewport variants accounted for]` | `[tokens/components/native controls]` | `[tests/flows]` |

## Completion rules

- Every in-scope ID appears exactly once.
- The canonical description path exists and is the one documented semantic
  source for that surface.
- The Android entry point is a real or explicitly planned implementation path;
  do not label an unimplemented path as complete.
- State ownership is explicit and UI callbacks do not bypass the domain/data
  boundary.
- Every product-owned region and visible element in the canonical description's
  inventory has an Android implementation owner or an explicit documented
  platform exclusion. Record repeated-element counts, order, and state/viewport
  variants where they affect coverage.
- A surface is not complete when a documented selector/context row, chart/list
  structure, indicator, helper/footer, or wearable continuation cue is missing,
  merged, reordered, or replaced by an undocumented alternative.
- System and wearable clients name their source identifier and shared domain
  operation.
- Verification names the actual test or emulator flow, not an assumed result.

## Recommended feature boundary

Use the project’s documented architecture. Where no architecture exists, keep
these concerns separate:

```text
app/composition root
  feature surface + lifecycle state owner
    domain models/use cases/ports
      data persistence/sync/projection adapters
  shared design system
  system and wearable adapters
```

The diagram is a responsibility guide, not a mandatory directory layout.
Navigation and source-file organization remain native Android implementation
decisions.
