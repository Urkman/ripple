# Ripple shared wireframes

**Document type:** Shared platform-independent wireframe asset and rendering contract
**Document version:** 1.0.0
**Last verified:** 2026-09-18
**Status:** Normative asset companion to the shared surface catalog

These are platform-independent layout illustrations for the 22 canonical
surfaces in [`../Ripple_SCREEN_CATALOG.md`](../Ripple_SCREEN_CATALOG.md). They
are intentionally neutral: they show semantic regions, hierarchy, content
priority, and responsive composition without prescribing iOS, Android, Wear OS,
or any framework's controls or navigation chrome.

The Markdown surface contracts remain authoritative. Android evidence captures
are maintained separately in [`../Android/UI/README.md`](../Android/UI/README.md)
and do not replace these shared wireframes.

Each PNG has an editable SVG source with the same stem. The previews can be
regenerated on macOS from this directory with:

```sh
./render-wireframes.sh
```

The renderer uses the macOS `sips` SVG renderer. The generated PNGs are
documentation artifacts, not runtime screenshots.

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
