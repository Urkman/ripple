# ADR-003 Live Activity

**Status:** Accepted  
**Date:** 2026-08-28

## Decision

One Live Activity per day.

- Start on the first sip of the day, or at the end of onboarding if the user allowed activities
- Update only on log, undo, goal change, and midnight
- End at local midnight or when the user dismisses it
- No per-second tick
- Quick Add calls `LogIntake` with `source: .liveActivity`
- Attributes content state: `consumedMl`, `goalMl`, `defaultAddMl`, `unit`

## Consequences

Battery and ActivityKit budget stay within system limits. The island and lock screen show a short pulse; the full wave lives only in the app.
