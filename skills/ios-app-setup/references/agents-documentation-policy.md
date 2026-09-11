# AGENTS documentation-synchronization policy

Use this reference when creating or updating the repository's root
`AGENTS.md`. It is a policy checklist, not a second product specification.
Preserve existing instructions and adapt document paths, versioning rules,
platforms, and architecture names to the repository.

## Required policy

Add one clear section that says:

1. The maintained product contract is the source of truth for product scope,
   user outcomes, flows, domain behavior, and motion.
2. Every screen, sheet, wearable surface, widget, control, notification,
   shortcut, export/share entry, or other documented system entry has exactly
   one canonical, platform-independent description file.
3. A user-visible behavior, layout, state, copy, accessibility, or motion
   change requires a documentation review in the same change.
4. Update the affected documents by change type:

   | Change | Required documentation review |
   |---|---|
   | Product behavior/outcome/flow | Product contract and affected surface/platform handoffs |
   | Screen/sheet layout, state, accessibility, or motion | That surface's canonical file, design contract when tokens/elements change, and platform handoffs |
   | Reusable visual element or token | DesignSystem contract and owning shared implementation |
   | Entity, unit, identity, invariant, persistence, sync, projection, or use case | Data-model contract and affected surface/platform handoffs |
   | Platform-only expression | Platform architecture/UI document, linked to the unchanged shared surface contract |

5. Platform-specific implementation maps to shared semantics; it must not
   create a second product contract. Native platform controls are allowed
   when they preserve the documented outcome and accessibility.
6. Update document versions, `Last verified`, immutable timeline entries,
   stable-ID/file coverage, links, and reference-pack revisions when the
   repository uses those conventions.
7. Do not claim runtime, accessibility, performance, or cross-platform
   verification that was not actually performed.

## Placement and maintenance

- Put the section at the existing documentation/process-policy location, or
  append it under a clearly named heading when no such location exists.
- Keep `AGENTS.md` about process and authority. Put detailed product behavior
  in the product/surface documents, not in this file.
- Link to the actual product contract, surface index, DesignSystem contract,
  data-model contract, and platform handoffs using repository-relative paths.
- If an existing rule conflicts with this checklist, follow the repository's
  stated precedence and report the conflict rather than silently weakening a
  stronger rule.
