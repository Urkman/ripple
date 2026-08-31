# ADR-002 HealthKit

**Status:** Accepted  
**Date:** 2026-08-28

## Decision

Health is a projection of SwiftData.

- After a successful log, write `HKQuantityTypeIdentifier.dietaryWater` in liters
- Metadata: `app.ripple.intakeUUID` and `app.ripple.source`
- Never write the same UUID twice
- Undo/delete removes the matching Health sample when authorization allows
- Health errors do not roll back the log
- Workout read is a second, explicit opt-in used only for the goal boost
- The app is fully usable without Health

## Consequences

Watch logs reach Health through the same `LogIntake` path. If the logging process cannot write Health, the iPhone projection catches up after sync using the UUID to prevent duplicates.
