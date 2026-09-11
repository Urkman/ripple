# Project-local Codex skills

This directory contains the reusable skills maintained with the project. The
repository copies are canonical: update them here first, then reinstall them
for local use.

## Included skills

- [`cross-platform-product-documentation`](cross-platform-product-documentation/SKILL.md)
  creates the project-neutral product, surface, design-system, data-model, and
  platform handoff contracts.
- [`android-app-from-documentation`](android-app-from-documentation/SKILL.md)
  builds or extends the Android project from those contracts.
- [`ios-app-setup`](ios-app-setup/SKILL.md) prepares a blank or existing iOS
  project with shared foundations, a DesignSystem, and documentation-sync
  rules. It does not implement product screens from documentation.

Each package is self-contained and follows the skill bundle layout:
`SKILL.md`, optional `agents/openai.yaml`, and task-specific `references/`.

## Install for local Codex use

From the repository root, copy the packages into the local Codex skills
directory:

```sh
mkdir -p ~/.codex/skills
cp -R skills/cross-platform-product-documentation ~/.codex/skills/
cp -R skills/android-app-from-documentation ~/.codex/skills/
cp -R skills/ios-app-setup ~/.codex/skills/
```

If Codex uses a custom skills directory, replace `~/.codex/skills` with that
directory. Restart or reload the Codex session if the skills do not appear
immediately.

When updating the project-local packages, reinstall the changed package so the
local copy remains identical to the repository version. Validate each package
with the bundled skill validator before committing.
