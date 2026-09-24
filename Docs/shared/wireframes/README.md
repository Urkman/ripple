# Ripple shared wireframes

**Document type:** Shared platform-independent wireframe asset and rendering contract
**Document version:** 1.2.1
**Last verified:** 2026-09-23
**Status:** Normative asset companion to the shared surface catalog

These are platform-independent layout illustrations for the 22 canonical
surfaces in [`../Ripple_SCREEN_CATALOG.md`](../Ripple_SCREEN_CATALOG.md). They
are intentionally neutral: they show semantic regions, hierarchy, content
priority, and responsive composition without prescribing iOS, Android, Wear OS,
or any framework's controls or navigation chrome.

The Markdown surface contracts remain authoritative. Android layout
illustrations and the absence of runtime captures are recorded separately in
[`../Android/UI/README.md`](../Android/UI/README.md)
and do not replace these shared wireframes. The companion
[`../Ripple_VISUAL_REFERENCE_INVENTORY.md`](../Ripple_VISUAL_REFERENCE_INVENTORY.md)
records the evidence classification and visible product-owned elements that
each wireframe must preserve.

Each PNG has an editable SVG source with the same stem. The previews can be
regenerated on macOS from this directory with:

```sh
./render-wireframes.sh
```

The renderer uses the macOS `sips` SVG renderer. The generated PNGs are
documentation artifacts, not runtime screenshots.

## Visual audit status

All 22 canonical surfaces have a linked PNG preview and same-stem editable SVG
source. The 2026-09-23 audit corrected the shared illustrations where the
visible structure was incomplete: History's today-only add action; Stats'
dependent period context, four distinct chart families, and Highlights;
Settings' eight semantic groups; Day Detail row actions and goal context; the
Edit Container destructive action; all seven elapsed days in Wear History;
Today’s flat idle-water line, 62% water fill, and seeded container amounts;
Wear Today’s single `+` entry point, 88% water fill, and complete readout; the Wear amount sheet’s three presets;
row-level Wear Day Detail delete/Undo; the Watch Stats total; and all container
distribution bars in expanded Stats.
The adaptive Today/History diagrams remain neutral resize/fold illustrations;
they are not runtime captures and do not claim Android resize or fold proof.

## Naming

`<stable-id>--<state>--<viewport>.svg` and `.png`

Viewports are semantic (`compact`, `expanded`, or `wearable`), not mandatory
production pixel sizes. The primary compact/wearable image for each surface is
linked from the screen catalog; expanded variants are linked from the affected
canonical surface descriptions.

## Timeline

| Version | Date | Change |
|---|---|---|
| 1.0.0 | 2026-09-18 | Established the shared neutral PNG/SVG wireframe pack and deterministic macOS renderer for all canonical surfaces. |
| 1.1.0 | 2026-09-19 | Added adaptive Today/History diagrams with editable sources; neutral resize/fold illustrations remain distinct from runtime evidence. |
| 1.2.0 | 2026-09-23 | Audited all 22 surface references against the visual inventory and corrected compact, expanded, and wearable illustrations for visible product-owned coverage; canonical PNG/SVG pairs now expose the required semantic regions while platform chrome and runtime-evidence gaps remain explicit. |
| 1.2.1 | 2026-09-23 | Reconciled Today’s idle surface, seeded values and 62% fill, wearable Today/amount/Day Detail/Stats flows and 88% fill, and the full expanded container distribution; refreshed affected PNG previews from their SVG sources. |

## Adaptive illustrations

- [Today resize/fold regions](today--resize--adaptive.png), [editable source](today--resize--adaptive.svg).
- [History resize/fold regions](history--resize--adaptive.png), [editable source](history--resize--adaptive.svg).

These 1100 × 650 neutral overview diagrams illustrate the adaptive rules in
the current Today and History surface contracts. Their captions identify the
surface contract version; neither image set is runtime verification.
