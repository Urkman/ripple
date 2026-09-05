# Ripple App Store Release Assets

Date: 2026-09-05  
Status: Design approved in conversation; written spec awaiting review

## Problem

The current App Store captures are technically valid but visually sparse. The
release material needs a repeatable way to populate a simulator with believable
data, capture meaningful app states, and turn those captures into App Store
advertisements. The attached reference is a visual direction only: its
language-learning copy, purple palette, and product details do not belong in
Ripple.

The existing release files remain grouped under `release/`, with metadata in
`release/metadata/` and native simulator captures in
`release/screenshots/raw/`. New composed assets will live alongside them.

## Goals

- Add a deterministic demo-data function for screenshot runs.
- Keep demo data out of production behavior and out of normal simulator runs.
- Preserve Ripple's domain boundaries: every intake is written through
  `LogIntake`, and persistence writes remain behind the existing model actor.
- Make repeated flagged runs idempotent without deleting user data.
- Produce polished, standalone App Store advertisements from real app screens.
- Support the existing English and German release locales.
- Export exact iPhone 6.9-inch and iPad 12.9-inch asset sizes, validate them,
  and upload the reviewed sets to the existing App Store Connect version.
- Leave all release inputs and outputs in one recoverable `release/` folder.
- Create a reusable personal Codex skill for future apps and releases.

## Non-goals

- No visible demo-data control in the shipped app.
- No demo-data reset or destructive cleanup command.
- No changes to Ripple's product UI, hero motion, History/Stats behavior, or
  production data model beyond the small optional fixture identity needed for
  idempotent logging.
- No purple, orange, custom fonts, photorealistic water, or copied text from the
  reference image.
- No new widget, Watch, or extension capture set unless a real capture is
  available; the first pass targets the existing iPhone and iPad release
  surfaces.
- No replacement of the existing App Store metadata unless validation exposes
  a specific metadata issue.

## Chosen approach

Use a `DEBUG`-only launch flag plus a reusable, manifest-driven asset
compositor. The flag is detected in the iOS composition root, a small debug
gate prepares the store before `RootView` is rendered, and a data-layer fixture
seeder fills the store through public domain use cases. The asset skill consumes
the resulting native captures and a project manifest, then produces opaque,
exact-size marketing images and an upload-ready directory.

This keeps the app's runtime architecture small while making the release
workflow repeatable. A one-off shell script would not provide reliable
idempotence, while a full screenshot editor inside Ripple would add a second
application surface and unnecessary maintenance for this release.

## Architecture

### Launch and preparation

`Apps/RippleiOS/RippleiOSApp.swift` will recognize the exact argument
`-ripple-demo-data` only in a `DEBUG` compilation path. A normal launch keeps
the current bootstrap and renders `RootView` directly.

When the flag is present:

1. The app creates the normal `RippleContainer` through
   `RippleBootstrap.start()`.
2. `Apps/RippleiOS/DemoDataGateView.swift` runs before `RootView` is shown.
3. The gate waits for default settings/container initialization, then invokes
   `DemoDataSeeder` with the current calendar, locale, and one captured `now`.
4. Only after seeding succeeds does it render the regular `RootView`.

The gate prevents onboarding from appearing briefly while the asynchronous
store preparation is in flight. It is a debug-only composition concern and
does not move fixture logic into `RippleFeatures` or a view model. A failure is
reported with `Logger` and leaves the debug gate in a retryable failure state;
it never silently presents an empty capture surface.

### Demo data

Add a focused fixture implementation under `Packages/RippleData`:

- `Packages/RippleData/Sources/RippleData/Demo/DemoDataScenario.swift`:
  pure, deterministic scenario definitions.
- `Packages/RippleData/Sources/RippleData/Demo/DemoDataSeeder.swift`:
  asynchronous orchestration through `UseCases`.

The seeder will:

- call `settingsRepository.seedDefaultsIfNeeded(locale:)` before reading
  containers;
- preserve existing containers and use the localized seeded defaults on a
  clean simulator;
- set a manual 2,000 ml goal with `UpdateGoal`;
- set `Profile.onboardingCompleted` to `true` and use milliliters for stable
  cross-locale marketing output, through `UpdateProfile`;
- create 36 consecutive local calendar days (today plus the preceding 35
  days), with two to five water entries per day;
- keep every generated date at or before the captured `now`;
- make today's total about 1,750 ml so the hero has a clearly active but not
  completed level;
- vary previous daily totals across below-goal, near-goal, and above-goal days
  so History rings and Stats charts have visible contrast;
- reference available containers cyclically and use a small mix of valid
  sources (`app`, `widget`, `intent`, `watch`, and `control`) so source labels
  and detail screens are meaningful;
- avoid fixture notes or visible “demo” copy.

To make reruns idempotent, add an optional `id: UUID? = nil` parameter at the
end of `LogIntake.run(...)`. Existing callers continue to receive generated
IDs. The fixture passes IDs derived from a fixed namespace, local day offset,
and entry ordinal; `RippleStore.saveIntake` already upserts by ID. The seeder
therefore updates its own rows on a second run, does not duplicate them, and
does not delete or rewrite unrelated rows. The fixture does not call a model
actor directly and does not introduce a second intake write path.

The scenario is deterministic in shape but relative in time: the same seed
works on any capture date, while today's entries remain plausible and never
land in the future. All amounts remain integer milliliters.

### Data flow

```text
-ripple-demo-data
        |
        v
RippleiOS composition root -> DemoDataGate
        |
        v
DemoDataSeeder -> UseCases (LogIntake, UpdateGoal, UpdateProfile)
        |
        v
existing repositories -> RippleStore @ModelActor -> SwiftData / CloudKit store
        |
        v
RootView -> Today / History / Stats / Settings
```

The existing `LogIntake` projection behavior remains intact. HealthKit and
widget effects may be no-ops in the simulator; a projection failure cannot
roll back a persisted fixture intake.

## Marketing asset design

### Output structure

Keep native source captures and marketing exports together:

```text
release/
├── metadata/
└── screenshots/
    ├── raw/
    │   ├── en-US/...
    │   └── de-DE/...
    ├── marketing/
    │   ├── en-US/iphone-69/01-*.jpg ...
    │   ├── en-US/ipad-129/01-*.jpg ...
    │   ├── de-DE/iphone-69/01-*.jpg ...
    │   └── de-DE/ipad-129/01-*.jpg ...
    └── marketing-manifest.json
```

The manifest is the source of truth for slide order, locale-specific copy,
raw-screen mapping, layout, and the approved Ripple palette. It contains no
credentials. The skill's generic compositor accepts the same manifest shape
for future apps; Ripple-specific configuration stays in this release folder.

### Narrative and slide set

The iPhone deck contains five standalone advertisements:

1. Today hero — “Make water visible.” / “Wasser sichtbar machen.”
2. Quick logging — “Log in one tap.” / “Mit einem Tipp loggen.”
3. History — “See every day.” / “Jeden Tag sehen.”
4. Stats — “Find your rhythm.” / “Deinen Rhythmus finden.”
5. Feature mosaic — “Your flow, your setup.” / “Dein Flow, dein Setup.”

Supporting lines are localized in the manifest and kept short. The copy states
observable product outcomes, contains one idea per slide, and avoids health
claims. German line breaks are tuned independently instead of being a literal
English layout copy.

The iPad deck contains four slides using Today, History, Stats, and Settings.
The fourth slide communicates configurable goals, reminders, and units without
inventing capabilities.

### Visual system

Each export is a complete advertisement, not a raw simulator screenshot or a
cropped strip. The composition system will:

- place the real native screenshot inside a restrained rounded device frame;
- vary framing across the deck (centered, offset, slightly tilted, and mosaic)
  without repeating an identical layout twice in a row;
- reserve roughly the upper third for a large, short headline and optional
  supporting line;
- use generous negative space around a dense, believable in-device screen;
- add one or two subtle geometric Ripple accents per slide, such as aqua arcs,
  glass-like circles, or line motifs;
- use only `color.water.deep`, `color.water.lagoon`, `color.water.aqua`, and
  `color.water.foam`, plus their opacity variants;
- use San Francisco/system typography, 4-point-aligned spacing, 20/28-point
  card/hero radii, and restrained shadows;
- include the Ripple wordmark or icon only where it helps recognition, without
  adding unsupported badges, ratings, or claims;
- keep all critical text and UI inside a single export boundary.

The reference image informs the panel rhythm, oversized copy, device framing,
and decorative energy. It does not determine Ripple's palette, wording, or
feature claims.

### Export and QA

The compositor will produce fully opaque, high-quality JPEGs at:

- iPhone 6.9-inch: 1,320 × 2,868.
- iPad 12.9-inch: 2,064 × 2,752.

The pipeline will fail if a source is missing, an output has an alpha channel,
dimensions are wrong, text/device content is clipped, or filenames do not sort
with zero-padded indices. It will also generate small thumbnail proofs for the
one-second readability check. Final inspection will use the rendered assets,
not only metadata or file dimensions.

## Reusable Codex skill

Create a discoverable personal skill at
`/Users/urkman/.codex/skills/app-store-release-assets/` with:

- a concise `SKILL.md` describing discovery, manifest preparation, composition,
  thumbnail QA, and optional App Store Connect handoff;
- a focused manifest reference documenting locale/device/slide fields;
- deterministic scripts for composition and validation;
- no app-specific source paths or credentials embedded in the skill.

The skill will accept existing native captures when available and will describe
the iOS simulator capture step as an adapter/configuration point. It will not
assume every future app has SwiftData or Ripple's architecture. Its default
behavior is to prepare local assets and stop before remote mutation unless the
user explicitly requests upload. For this release, the user has already
requested App Store Connect upload, so the final workflow will use the existing
ASC IDs and the approved `asc` commands after local visual QA.

## App Store Connect handoff

Before upload:

1. Validate `release/metadata` and the marketing screenshot directories with
   the repository's `asc` guidance.
2. Resolve and verify the existing app/version/localization/screenshot-set IDs;
   do not infer IDs from filenames.
3. Review the complete local image set for both locales and devices.
4. Replace only the targeted iPhone/iPad screenshot sets for version 1.0,
   preserving metadata and unrelated remote assets.
5. Use explicit confirmation for any remote delete/replace operation required
   by the CLI.
6. Re-list the remote sets and verify every uploaded asset reaches its
   completed state and matches the local count/order.

Existing App Store submission blockers unrelated to screenshots remain outside
this design and will be reported separately.

## Testing

Add tests in `Packages/RippleData/Tests/RippleDataTests` for:

- scenario shape: 36 local days, no future timestamps, expected today total,
  varied daily totals, and valid source/container references;
- deterministic fixture IDs and stable generated plans for the same anchor;
- idempotence: seed the same in-memory use cases twice and assert the intake
  count is unchanged while the fixture rows remain addressable by ID;
- settings preparation: onboarding is complete, the goal is 2,000 ml, and the
  preferred unit is milliliters;
- unrelated data safety: a pre-existing non-fixture intake remains present and
  unchanged after seeding.

Retain and run the existing domain tests, SwiftData tests, and relevant iOS
build/test checks. The marketing script receives focused validation with a
small fixture manifest before it is used for the full release set.

## Acceptance criteria

- Without `-ripple-demo-data`, the app behaves as it did before this change.
- With the flag on a clean simulator, onboarding is skipped only after the
  fixture has completed and Today/History/Stats contain useful content.
- Running the flagged app again does not add duplicate fixture entries.
- No view writes SwiftData and no code path bypasses `LogIntake` for intakes.
- English and German captures contain localized app UI and marketing copy.
- The final iPhone and iPad exports are opaque, exact-size, readable at
  thumbnail scale, and visually distinct from raw captures.
- All final assets are under `release/`, metadata remains under
  `release/metadata/`, and the reviewed screenshot sets are uploaded and
  verified in App Store Connect.
