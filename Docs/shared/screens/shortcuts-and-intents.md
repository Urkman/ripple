# Ripple Surface — Shortcuts and intents

**Stable surface ID:** `shortcuts-and-intents`  
**Surface contract version:** 1.0.0  
**Last verified:** 2026-09-11  
**Kind:** System surface  
**Localized name:** Localized shortcut/action name

This is the canonical contract for voice, shortcut, and system-intent entry
points.

## Purpose and user outcome

The user can discover and invoke localized Ripple logging actions with a
predefined amount or a selected saved container, receive a concise result, and
continue without learning a second amount model.

## Entry and exit

The system invokes an intent/action adapter. The adapter validates parameters,
resolves any container amount through shared policy, calls `LogIntake` with
source `intent`, and returns a localized result. Invalid or incomplete input
returns an actionable error or opens the app's canonical entry surface when
the system supports continuation.

## Layout and region order

The system presents a localized action name, supported parameters, confirmation
or error result, and an optional route into the app. System voice/shortcut
chrome remains outside Ripple's surface description.

## Read model

Expose only supported localized parameters: amount/unit, optional container,
and any explicitly documented date/source restriction. Integer milliliters are
the domain value.

## Actions and domain operations

Every successful invocation uses `LogIntake`; there is no intent-specific
persistence or goal calculation.

## States

Validate positive amount, supported unit conversion, and selected container
identity before mutation. Success returns amount, unit, and source context.
Projection failure does not roll back local persistence. Unsupported access or
permission produces a localized explanation. Reduced motion has no effect on
the concise result.

## Validation and destructive behavior

Positive amount, supported unit conversion, and selected-container identity are
required. This surface has no destructive action.

## Accessibility and large text

Names, parameters, examples, and errors are localized in DE and EN. Spoken or
assistive results include amount, unit, and outcome. The action remains
discoverable without relying on an icon alone.

## Design tokens and reusable elements

Use the shared unit converter, amount formatting, container entity, copy, and
accessibility roles from [`../Ripple_DESIGN_SYSTEM.md`](../Ripple_DESIGN_SYSTEM.md)
and [`../Ripple_DATA_MODEL.md`](../Ripple_DATA_MODEL.md). The system owns
voice/shortcut chrome and confirmation presentation.

## Responsive/platform-independent behavior

The system may change parameter presentation for voice, shortcut, or compact
contexts; amount → confirmation/error remains the semantic order.

## Forbidden behavior

- A second `LogIntake` implementation or amount formula.
- An unlocalized phrase or error.
- Silent success when local persistence failed.
- A shortcut that exposes Health/projection data as logging truth.

## Related contracts

- [`../Ripple_PRD.md`](../Ripple_PRD.md)
- [`../Ripple_SCREEN_CATALOG.md`](../Ripple_SCREEN_CATALOG.md)
- [`../Ripple_DESIGN_SYSTEM.md`](../Ripple_DESIGN_SYSTEM.md)
- [`../Ripple_DATA_MODEL.md`](../Ripple_DATA_MODEL.md)
- [`today.md`](today.md)
