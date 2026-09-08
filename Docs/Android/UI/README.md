# Android UI reference pack

**Reference pack revision:** 2.1.0 (tracks the Android UI specification)
**Last verified:** 2026-09-08

This pack separates evidence from the Android presentation contract:

- Shared product behavior comes from the [Ripple PRD](../../Product/Ripple_PRD.md), especially Section 22.
- Android screen behavior comes from the [Android UI specification](../ANDROID_UI_SPEC.md) and architecture from the [Android architecture guide](../ANDROID_ARCHITECTURE.md).

- The existing iOS PNGs are evidence of the current product hierarchy and visual priorities.
- The SVGs in this directory are normative Android layout wireframes. They name Android-native controls and responsive behavior; they are not pixel-perfect iOS copies.
- Real Android emulator and Wear captures are the final acceptance artifacts. These wireframes do not replace runtime verification.

## iOS evidence

- [iPhone Today](../../../release/screenshots/raw/en-US/iphone-69/01-today.png)
- [iPhone History](../../../release/screenshots/raw/en-US/iphone-69/02-history.png)
- [iPhone Stats](../../../release/screenshots/raw/en-US/iphone-69/03-stats.png)
- [iPad Settings](../../../release/screenshots/raw/en-US/ipad-129/04-settings.png)
- [Watch Today](../../../release/screenshots/raw/en-US/watch-46/01-today.png)
- [Watch History](../../../release/screenshots/raw/en-US/watch-46/02-history.png)
- [Watch Stats](../../../release/screenshots/raw/en-US/watch-46/03-stats.png)

## Android layout contracts

| Reference | Contract |
|---|---|
| `phone-today.svg` | Four-root phone shell; contained glass hero; saved containers; custom amount; no Recent list |
| `phone-history.svg` | Horizontal month pager; weekday grid; one capped ring per day; future days disabled |
| `phone-day-detail.svg` | Nested Day Detail; intake rows; edit/delete/restore; add only for today |
| `phone-stats.svg` | Week/Month/Year selector; summaries; four chart families; highlights |
| `phone-settings.svg` | Profile, goal, containers, reminders, Health, sync, export, about |
| `phone-onboarding.svg` | Six onboarding pages and native permission handoffs |
| `tablet-history-split.svg` | Expanded History calendar/detail split |
| `tablet-stats.svg` | Expanded Stats with persistent navigation and chart content |
| `wear-today.svg` | Full-canvas water field; predefined actions; Crown-first custom amount |
| `wear-history.svg` | Seven elapsed local days; Wear-native list |
| `wear-day-detail.svg` | Wear Day Detail; individual intake deletion |
| `wear-stats.svg` | Current ISO-week summary; one compact chart |

The pack contains documentation only. It does not authorize copying Liquid Glass,
an iOS tab bar, or iOS navigation chrome into Android. Android uses Material 3,
Window Size Classes, standard Android permission surfaces, and Wear-native
navigation while preserving the same screens, information priority, and flows.
