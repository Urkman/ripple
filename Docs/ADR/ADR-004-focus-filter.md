# ADR-004 Focus Filter

**Status:** Accepted  
**Date:** 2026-08-28

## Decision

v1 does not ship a Focus Filter. Reminders are paused from Settings (`remindersEnabled`) and never fire inside the sleep window. A Focus Filter would add App Group + Intents complexity without changing the core log path.

## Consequences

Users who want silence during Focus modes turn reminders off. Revisit in v1.1 if demand appears.
