# iOS project setup inventory

Use this reference while preparing a blank or existing project. Store any
completed inventory where the repository's architecture documentation expects
it. Do not turn the inventory into a product contract or claim planned work is
implemented.

## Project and target inventory

| Target/product | Kind | Platform/runtime | Bundle/product ID | Entry point | Dependencies | Capabilities/resources | Status |
|---|---|---|---|---|---|---|---|
| `[name]` | `[app/test/package/extension]` | `[platform/runtime]` | `[id]` | `[scene/provider/test target]` | `[modules/products]` | `[actual capabilities/resources]` | `[existing/added/planned]` |

Record the source of each lasting choice: existing project setting, user
request, repository instruction, or documented platform requirement.

## Shared foundation inventory

| Responsibility | Owning path/module | Target membership | Public boundary | Existing or added | Verification |
|---|---|---|---|---|---|
| DesignSystem | `[path]` | `[targets]` | `[tokens/components]` | `[status]` | `[preview/build/test]` |
| Shared support/resources | `[path]` | `[targets]` | `[resource/helper API]` | `[status]` | `[resource/test]` |
| Domain (if present) | `[path]` | `[targets]` | `[entities/use cases/ports]` | `[status]` | `[unit tests]` |
| Data (if present) | `[path]` | `[targets]` | `[store/adapter API]` | `[status]` | `[integration/migration tests]` |

## DesignSystem checklist

- [ ] Existing token/theme/component owners were located, or a single neutral
  baseline was created.
- [ ] Light/dark appearance, Dynamic Type, reduced motion, and state variants
  have preview or test coverage appropriate to the project.
- [ ] Native controls remain the implementation for ordinary interaction.
- [ ] Feature code has no parallel token constants or magic visual values.
- [ ] The DesignSystem's resource bundle and target membership are explicit.

## Setup completion rules

- The project opens and the selected app scheme builds.
- Every added target has a real responsibility and target membership.
- The shared folder/module has at least one real consumer and no duplicated
  implementation elsewhere.
- `AGENTS.md` contains the documentation-synchronization policy.
- No product screen, behavior, or model was invented as scaffold content.
- Verification records actual results and names remaining gaps.
