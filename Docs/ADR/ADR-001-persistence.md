# ADR-001 Persistence

**Status:** Accepted  
**Date:** 2026-08-28

## Decision

One SwiftData store, shared across app and extensions.

- `ModelConfiguration(groupContainer: .identifier(appGroup), cloudKitDatabase: .automatic)`
- CloudKit-compatible schema: no unique constraints, optional relationships, defaults on every attribute
- Soft delete via `Intake.isDeleted`
- All writes through `@ModelActor`
- Conflict policy: intakes are append-only plus soft delete with UUID identity; last writer wins per field; `GoalSettings.updatedAt` wins
- `SharedContainer.make()` tries App Group + CloudKit, then App Group local, then in-memory
- Failures surface as `SyncStatus`

## Consequences

HealthKit is never the store. UserDefaults is not a second source of truth (widget placeholder cache only).
