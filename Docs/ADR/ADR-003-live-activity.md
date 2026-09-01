# ADR-003 Live Activity

**Status:** Superseded
**Date:** 2026-08-28

## Decision

Ripple does not ship a Live Activity.

The original decision below was superseded because a water-tracking status surface that can expire after a limited system lifetime is not a dependable daily view. Ripple uses interactive widgets, Control Center, Watch, Siri, and notifications instead.

## Consequences

No ActivityKit entitlement, target wiring, or runtime controller is part of the product. Existing persisted profile data remains readable during migration, but it no longer controls any behavior.
