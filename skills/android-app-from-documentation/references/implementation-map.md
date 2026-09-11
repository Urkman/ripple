# Documentation-to-code map

Use this template when the Android project needs an explicit traceability
record. Store it where the repository's architecture documentation expects it;
do not create a competing product contract.

| Stable surface ID | Canonical description | Android entry point/module | State owner | Domain operations | Design elements | Verification |
|---|---|---|---|---|---|---|
| `[id]` | `[path]` | `[route/module/entry]` | `[ViewModel/presenter]` | `[operations]` | `[tokens/components/native controls]` | `[tests/flows]` |

## Completion rules

- Every in-scope ID appears exactly once.
- The canonical description path exists and is the one documented semantic
  source for that surface.
- The Android entry point is a real or explicitly planned implementation path;
  do not label an unimplemented path as complete.
- State ownership is explicit and UI callbacks do not bypass the domain/data
  boundary.
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
