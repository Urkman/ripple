# ADR-000 Architecture

**Status:** Accepted  
**Date:** 2026-08-28

## Decision

Ripple uses feature-first Clean MVVM.

- One domain, many adapters.
- Features own screens, not rules.
- `@Observable` view models, never `ObservableObject`.
- Use cases are the only write API.
- Swift 6 with strict concurrency.
- Writes go through `@ModelActor`.
- Dependency injection is protocols plus a composition-root container factory.
- No TCA, VIPER, or app-wide router.
- Navigation is platform-local (tabs, split view, watch pages).
- `#if os()` is forbidden in view models and use cases.

## Consequences

Widget, Siri, Watch, Control Center, and notifications all call `LogIntake`. HealthKit is a projection, not a source of truth.
