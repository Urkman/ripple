# iOS setup acceptance

Use this reference after setup changes to verify a blank app shell or an
existing app foundation. Adapt scheme, project/workspace, device, OS, bundle
ID, and target names to the repository. Use XcodeBuildMCP and record its
actual context.

## Automated checks

Record the exact commands or tool calls for:

- the app target build and launch;
- each added package/module/test target;
- unit, integration, UI, snapshot, and accessibility tests that exist;
- lint/static analysis and localization/resource validation;
- archive/export/package checks only when requested by the repository.

Clear one category of compiler/concurrency failure before moving to the next.
A passing app build does not prove that every extension or platform target
builds.

## Simulator/device flow

1. Discover the booted simulator or explicitly selected device; record model,
   OS/runtime, scheme, configuration, project/workspace, and bundle ID.
2. Build and launch the selected target.
3. Confirm a blank app reaches only its neutral launch shell. For an existing
   app, confirm its prior launch path is still reachable.
4. Confirm shared DesignSystem types, assets, localized resources, and test
   fixtures resolve from their intended target/resource bundle.
5. Run the smallest relevant interaction or UI smoke flow using visible labels,
   accessibility identifiers, and native platform interaction; do not rely on
   guessed screenshot coordinates.
6. Check light/dark appearance, documented Dynamic Type sizes, reduced motion,
   VoiceOver labels, focus order, and hit targets for the shared components.
7. Capture screenshots or UI descriptions only as setup evidence, and retain
   paths/identifiers in the project inventory.
8. Capture relevant logs and record crashes, warnings, missing permissions,
   signing limitations, or environment failures.

For Apple platforms that are explicitly in scope, repeat the setup smoke flow
with the documented native navigation and input: iPad split behavior, Mac
keyboard/menu commands, Watch pages and Crown input, tvOS focus, or visionOS
window/spatial behavior.

## Acceptance matrix

| Target/component | Launch/entry | Setup responsibility | Existing behavior preserved | Resources/tests | Accessibility/input | Adaptive/theme/motion | Evidence |
|---|---|---|---|---|---|---|---|
| `[target or component]` | `[pass/gap]` | `[pass/gap]` | `[pass/gap]` | `[pass/gap]` | `[pass/gap]` | `[pass/gap]` | `[path/run ID]` |

## Review rules

- Compare the result to existing repository conventions and the setup contract;
  do not judge a neutral shell as a completed product UI.
- Verify that the shared folder/module is not duplicated and that target
  membership/resource bundles are correct.
- Verify light and dark appearance, documented Dynamic Type sizes, reduced
  motion, contrast, hit targets, VoiceOver labels/values/traits, focus order,
  keyboard/pointer/Crown/focus input, and adaptive layouts for shared elements.
- Verify every added target independently enough to establish its entry path
  and dependency boundary.
- Verify that `AGENTS.md` requires documentation updates for future changes.
- Record every unverified surface. Do not turn missing simulator/device access,
  signing, network, permission, or service configuration into an unqualified
  pass.
