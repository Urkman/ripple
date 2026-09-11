# Ripple Surface — Wear Stats

**Stable surface ID:** `watch-stats`  
**Surface contract version:** 1.0.0  
**Last verified:** 2026-09-11  
**Kind:** Wearable screen  
**Localized name:** `Statistik` / `Stats`

This is the canonical current-week wearable Stats contract.

## Purpose and user outcome

The user sees a concise hydration summary for the current ISO week and one
compact chart without navigating a phone-style analysis dashboard.

## Entry and exit

Wear Stats is a sibling wearable page. It has no period picker. Back or page
navigation returns to Wear Today or Wear History.

## Layout and region order

1. Stats title/current ISO-week context.
2. Summary total, goal/hit context, and relevant highlight.
3. One compact chart with an accessible textual summary.
4. Empty/offline/error feedback.

## Read model

Read `StatsSnapshot` for the current ISO week through `ObserveStats`.

## Actions and domain operations

Chart selection is presentation-only. Retry refreshes the snapshot. There is
no write operation.

## States

Loading keeps summary/chart framing stable. Empty shows zero-state copy and no
invented marks. Offline keeps cached values with freshness status. Error offers
retry. Future portions do not count as completed days. Reduced motion removes
chart entrance choreography.

## Validation and destructive behavior

Future portions do not count as completed days. Stats has no destructive action
and does not mutate the domain.

## Accessibility and large text

Announce week range, totals, goal context, chart summary, and units. Every
visual mark has a value/date alternative. The layout adapts to wearable size
and native navigation without adding a period picker or four-chart composition.

## Design tokens and reusable elements

Use the wearable summary, compact chart, empty/error, type, spacing, and motion
tokens from [`../Ripple_DESIGN_SYSTEM.md`](../Ripple_DESIGN_SYSTEM.md).

## Responsive/platform-independent behavior

The chart and summary may stack or page for wearable size, but the current ISO
week remains explicit and the period picker remains absent.

## Forbidden behavior

- A week/month/year picker.
- Four phone chart families.
- A combined History/Stats destination.
- A chart without a textual summary.
- Health/projection values replacing the domain snapshot.

## Related contracts

- [`../Ripple_PRD.md`](../Ripple_PRD.md)
- [`../Ripple_SCREEN_CATALOG.md`](../Ripple_SCREEN_CATALOG.md)
- [`../Ripple_DESIGN_SYSTEM.md`](../Ripple_DESIGN_SYSTEM.md)
- [`../Ripple_DATA_MODEL.md`](../Ripple_DATA_MODEL.md)
- [`watch-history.md`](watch-history.md)
