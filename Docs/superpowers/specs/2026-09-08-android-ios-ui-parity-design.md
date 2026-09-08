# Ripple Android/iOS UI parity contract repair

## Status

Design approved in conversation on 2026-09-08. This document defines the
documentation change required before Android implementation begins. It does
not implement Android screens or change iOS behavior.

## Problem

`Docs/ANDROID_UI_SPEC.md` was created as an Android-native implementation
guide, but its screen contracts describe a product that does not match the
current iOS app. The most visible mismatches are:

- Today describes a generic water field and Recent rows instead of the
  glass-shaped hero, saved-container actions, and custom amount action.
- History does not make the current month pager and Day Detail flow explicit
  enough for an Android implementation.
- Settings is reduced to a short Android settings list instead of preserving
  the complete iOS capability surface.
- Onboarding is represented as a generic short wizard instead of the current
  six-page flow.
- Wear OS is described as a related watch surface, but its capability and
  navigation contract is not explicitly mapped to the current Apple Watch
  feature set.
- The product PRD still contains stale iOS statements: three iPhone tabs,
  the superseded idle-wave hero, and five onboarding pages.

## Goals

- Make the current iOS product hierarchy and flow the source of truth for
  Android product parity.
- Preserve Android-native navigation, controls, permission UI, typography,
  surfaces, back behavior, and responsive layouts.
- Give a future Android agent enough visual and behavioral information to
  build the same product without copying iOS Liquid Glass or tab-bar chrome.
- Correct stale shared product documentation in the same change.
- Provide a durable reference pack: screenshots for evidence, wireframes for
  layout contracts, and state/flow tables for behavior and accessibility.
- Preserve the existing domain and data boundaries; this task does not add
  cross-platform data sharing.

## Non-goals

- Implementing the Android app, Wear app, widgets, or system surfaces.
- Rebuilding the iOS UI or changing iOS behavior solely to make the Android
  documentation easier to write.
- Making Android a pixel-level copy of iOS.
- Adding a Recent list, dashboard cards, streak product, extra charts, or
  other scope not present in the iOS product.
- Replacing the Hero Motion or History/Stats contracts with a new visual
  preference.

## Source-of-truth precedence

The revised documents use this order:

1. `AGENTS.md` for repository process, boundaries, design tokens, and bans.
2. The current iOS implementation and verified iOS captures for screen
   hierarchy, content, and user flow.
3. `Ripple_Handoff/Ripple_Hero_Motion.md` for Today hero geometry and motion.
4. `Ripple_Handoff/Ripple_History_Stats.md` for History, Day Detail, Stats,
   and Watch behavior.
5. `Ripple_Handoff/Ripple_PRD.md` for shared product scope, corrected where
   it is stale.
6. `Docs/ANDROID_UI_SPEC.md` for Android-native presentation and responsive
   behavior.
7. `Docs/ANDROID_ARCHITECTURE.md` for Android module and implementation
   boundaries.

When a product document contradicts the current implementation, correct the
product document. When source code and a user-observed build contradict each
other, document the behavior as an explicit verification case rather than
silently designing Android around an unverified omission.

The current source already routes compact History day selection to
`DayDetailView` and keeps an iPad detail pane. The revised Android contract
therefore retains Day Detail and adds a required iOS verification capture;
Android must not omit the flow because a static calendar screenshot cannot
show it.

## Recommended approach

Use a paired contract and reference pack:

- real iOS release screenshots show hierarchy, content, and visual intent;
- annotated Android wireframes define responsive layout and Android-native
  substitutions;
- state matrices and flow diagrams define interaction, accessibility, and
  failure behavior;
- real Android captures remain the final acceptance artifacts.

Screenshots are evidence, not pixel targets. Product-level traits such as the
contained glass hero, water level, day rings, screen hierarchy, and logging
flow must be preserved. Platform-level traits such as navigation bars, rails,
top app bars, Material controls, Wear chips, permission UI, and predictive
back must be native to Android.

## Phone and tablet contract

### App shell

The Android app has four top-level destinations: Today, History, Stats, and
Settings. Compact windows use Material `NavigationBar`; medium windows use a
`NavigationRail`; expanded windows use a persistent navigation surface or
adaptive drawer. Nested destinations use a standard Android top app bar and
system back/predictive-back behavior. Root destinations do not show an
artificial back button.

### Today

The product hierarchy is:

```text
local day context
contained glass-shaped water hero
consumed amount + unit + percentage
remaining amount + goal
saved-container quick-add actions
custom amount action
```

There is no Recent intake list. The Android hero is a custom product drawing
of the contained 2D glass and water level; it is not a circular progress
indicator and does not simulate iOS Liquid Glass. Material buttons/chips and
a native FAB or extended FAB provide the actions around it.

Required states include zero intake, normal day, goal reached, over goal,
active coalesced pour, saved-log/projection error, and reduced motion. The
motion contract preserves one continuous pour, linear target-locked level
rise, no idle wave, and no tilt outside the supported phone/tablet context.

### History and Day Detail

History is a calendar-first screen:

- horizontally swipable month pages with chevrons controlling the same pager;
- locale-aware weekday row and seven-column day grid;
- one capped progress ring per day;
- future days visible but disabled;
- plus action only when the selected/local day is today;
- compact selection pushes a Day Detail destination;
- expanded windows keep the calendar and Day Detail panes visible together.

Day Detail contains the date, consumed/goal/percentage summary, intake rows
with time, amount, and source, plus edit/delete/restore behavior. Adding is
available only for today. Android uses standard list rows, dialogs, and
snackbar undo behavior while preserving the same use cases and record
identity.

### Stats

Stats remains independent from History. It provides Week, Month, and Year
periods; previous/next period navigation; average, goal-hit, and total
summaries; actual-vs-goal, hit-rate, time-of-day, and container charts; and
highlights. Empty periods use a localized empty state instead of synthetic
data. Android charts must provide a TalkBack-readable summary and values in
addition to the visual chart.

### Settings

The Android settings destination retains the complete capability order:

```text
Profile
Daily goal
Containers
Reminders
Health / Health Connect
Sync
Export
About
```

The visual grouping is preserved, but the implementation uses Android
`ListItem`s, switches, menus, dialogs, steppers or equivalent native controls,
and full destinations for substantial editing. It must not copy iOS glass
cards, omit sections, or reduce Settings to only goal/reminder preferences.

### Onboarding

Onboarding gates the main app on first run and has six pages matching the
current iOS flow:

1. Welcome and Ripple's logging metaphor.
2. Unit selection: milliliters or fluid ounces.
3. Health/Health Connect access explanation and permission request.
4. Goal setup with available weight, manual fallback, and calculated preview.
5. Seeded quick-add containers.
6. Reminder explanation and notification permission request.

Permission states are not failures. Returning from system UI re-reads the
current state; denied access remains recoverable, and logging remains
available without Health Connect or notification permission.

## Wear and system-surface contract

Wear OS mirrors the Apple Watch capability scope with Wear-native interaction:

- Today is a full-canvas flat water-level field with goal/readout and one
  logging action. Predefined amounts and a custom rotary-input flow are
  available; selecting an amount alone does not write.
- History shows today and the six preceding local days, newest first, keeps
  empty days visible, and opens a Wear-native Day Detail. Individual entries
  can be soft-deleted and restored; edit/add remain phone/tablet capabilities.
- Stats shows only the current ISO week: average per elapsed day, goal hits,
  total, and one compact chart. There is no period picker or month calendar.
- Complications, Tiles, widgets, Quick Settings, and notifications remain
  focused system surfaces. They do not render the full app shell, calendar,
  multi-chart dashboard, pour stream, or sensor tilt.

Compose for Wear, Wear chips, rotary scrolling, and standard Wear navigation
are expected Android-native substitutions; feature coverage and domain flow
remain equivalent.

## Reference pack

Keep existing iOS captures under `release/screenshots/` as evidence and link
them from the Android UI specification. Add lightweight, reviewable SVG
wireframes under `Docs/AndroidUI/` for:

- compact Today, History, Day Detail, Stats, Settings, and onboarding;
- expanded/tablet History split and Stats;
- Wear Today, History, Day Detail, and Stats;
- the phone onboarding/permission flow and the primary logging flow.

Each wireframe is annotated with the product content to preserve and the
Android-native component that replaces the iOS presentation. Do not encode
pixel dimensions that conflict with Window Size Classes. Do not duplicate the
large raw iOS screenshots in the reference pack.

The Android UI specification will include a parity matrix connecting each
reference image and wireframe to its screen contract, states, and acceptance
capture name.

## Documentation updates

The implementation of this design will update, in one documentation change:

- `Docs/ANDROID_UI_SPEC.md`: replace the inaccurate screen contracts,
  remove Recent rows, add the six-page onboarding, complete Settings and
  Stats, make the History pager/Day Detail flow normative, add the Wear
  mapping, reference pack, and acceptance matrix.
- `Docs/ANDROID_ARCHITECTURE.md`: align the capability matrix, Android UI
  section, onboarding requirements, screen requirements, and timeline with
  the revised UI contract.
- `Ripple_Handoff/Ripple_PRD.md`: correct the four-tab iPhone shell, current
  iPad/History/Stats scope, six-page onboarding, and stale Today hero text;
  point hero motion details to `Ripple_Hero_Motion.md`.
- `AGENTS.md`: remove or revise the obsolete note that PRD §14 is stale once
  the PRD is corrected, while keeping the Hero Motion precedence explicit.
- `Docs/ARCHITECTURE.md`: add the synchronized shared-contract timeline note
  required by the repository maintenance rules.
- `Ripple_Handoff/Ripple_History_Stats.md` and
  `Ripple_Handoff/Ripple_Hero_Motion.md`: review against the current source;
  change only where verification finds a factual mismatch, preserving their
  existing authority for History/Stats and hero motion.

All changed architecture/UI documents receive updated semantic versions,
`Last verified` metadata where applicable, and an immutable final Timeline
entry. If a product contract is reviewed but unchanged, the Android timeline
will record that it remains the source of truth and was unaffected.

## Verification

This is a documentation-first change. Before implementation begins:

- verify all relative Markdown image and document links;
- scan the revised Android spec for the removed Recent concept and for all
  four top-level destinations;
- verify the six onboarding pages and all Wear constraints appear in the
  parity matrix;
- check that no Android wireframe recommends copied iOS tab-bar/glass chrome;
- compare History source, product spec, and the iOS build for Day Detail;
- inspect the final diff for stale PRD §14 wording, contradictory screen
  counts, placeholders, and undocumented scope.

After Android implementation, the real-device acceptance matrix in
`release/screenshots/android/` is the final visual verification surface.

## Explicit decisions

- Android mirrors the current iOS product structure, not the current Android
  draft document.
- Native Android presentation is mandatory; product hierarchy parity does
  not mean pixel parity.
- The glass hero is a custom Ripple product component, while surrounding
  navigation and controls are Android system/Material components.
- There is no Android-only Recent list or dashboard.
- History Day Detail remains required even though it is not visible in a
  static calendar capture.
- Screenshots are evidence; annotated wireframes and state/flow tables are
  the implementation contract.
