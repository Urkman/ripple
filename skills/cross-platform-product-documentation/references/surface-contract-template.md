# Canonical surface contract template

Copy this template into the project's canonical surface-description directory
and replace the placeholders. Keep the file platform-independent. Add or omit
subsections only when the project contract makes the omission explicit.

```markdown
# [Product] Surface — [Localized or English name]

**Stable surface ID:** `[stable-id]`
**Surface contract version:** [version]
**Last verified:** [YYYY-MM-DD]
**Kind:** [root screen | child screen | sheet | onboarding surface | system surface]
**Localized name:** [DE / EN or project locales]

This is the canonical, platform-independent description of [surface].

## Purpose and user outcome

[What the user understands or completes.]

## Entry and exit

[Entry points, back/dismissal, completion, cancellation, and mutation boundary.]

## Layout and region order

1. [Semantic region]
2. [Semantic region]
3. [Semantic region]

[Describe hierarchy, sizing intent, and responsive reflow without naming a UI framework.]

## Read model

[Snapshot, settings, entities, permissions, or draft data required to render.]

## Actions and domain operations

| User action | Operation | Result |
|---|---|---|
| [Action] | `[NamedOperation]` or none | [State change and feedback] |

## States

- **Loading:** [Stable shell and availability behavior]
- **Empty:** [Useful next action; no invented data]
- **Ready:** [Normal content and enabled actions]
- **Permission:** [Explanation, request, and denial behavior]
- **Offline/sync unavailable:** [Local/source-of-truth behavior]
- **Error:** [Explanation and retry/recovery]
- **Success:** [Updated state and feedback]
- **Reduced motion:** [Removed/replaced motion]

## Validation and destructive behavior

[Ranges, disabled states, confirmation, soft delete, undo, restore, and recovery.]

## Accessibility and large text

[Labels, values, traits, focus/reading order, input alternatives, localization,
large text, contrast, and non-color alternatives.]

## Design tokens and reusable elements

[Named design tokens, reusable components, native-control expectations, and
component states. Do not define feature-local colors, typography, or spacing.]

## Responsive/platform-independent behavior

[Compact, regular, expanded, wearable, and system-surface adaptations. Preserve
meaning and semantic order while allowing native platform expression.]

## Forbidden behavior

- [Specific implementation that violates the product contract]

## Related contracts

- [Product contract](../PRODUCT_CONTRACT.md)
- [Surface index](../SURFACE_INDEX.md)
- [Design system](../DESIGN_SYSTEM.md)
- [Data model](../DATA_MODEL.md)
- [iOS mapping](../IOS_ARCHITECTURE.md)
- [Android mapping](../Android/ANDROID_UI_SPEC.md)
```

## Writing constraints

- The file describes one surface only. Link to another surface when a flow
  opens it; do not embed its complete layout and state contract here.
- Use stable domain operation names from the project's data contract.
- Describe system-owned behavior semantically. Name a framework/API only in a
  platform mapping document.
- Every amount includes a unit; every icon-only control has an accessible name.
- State actual source-of-truth and projection behavior, especially for widgets,
  shortcuts, notifications, health integrations, and synchronization.
