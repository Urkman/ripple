# Platform-independent wireframes

## Fidelity rule

Platform-independent wireframes abstract native rendering; they do not abstract
away product structure. When current reference captures exist, inspect the
whole reference set before drawing the wireframe and maintain a visible-element
inventory for each state and viewport.

Every product-owned visible element in the target state must be represented,
including labels and values, units, controls, dependent context or
date/range-navigation rows, repeated rows/cards, progress and selection
indicators, separators, pager/continuation cues, chart type and structure,
legends/axes/reference lines, helper or footer text, and partially visible
content that communicates scrolling or pagination. Preserve region order,
grouping, alignment, relative sizing, density, and visual hierarchy.

Low fidelity may simplify exact typography, color, icon artwork, shadows, and
pixel dimensions. It must not remove, merge, reorder, substitute, or materially
recompose a product-owned element. A selector with a dependent context row,
or a chart with a particular series and axis structure, remains that structure
in the wireframe unless the written contract explicitly makes the difference a
state or viewport variant.

If a current capture conflicts with an older wireframe, classify the conflict
as state, viewport, localization, system-owned chrome, stale artifact, or
unresolved authority conflict. Do not choose the simpler image by default.

## Artifacts and ownership

Use the project's documentation asset convention. If none exists, put images
in `wireframes/` beside the canonical surface-description directory. Use
`<stable-id>--<state>--<viewport>.png`, for example
`settings--ready--compact.png`. Keep an editable source with the same stem
(such as SVG or an HTML rendering source), plus any local rendering command
needed to reproduce it. Use relative links so the handoff works in another
checkout and on another platform. Do not place shared wireframes in an
iOS-only or Android-only screenshot directory.

Deliver a PNG preview for each wireframe so Markdown viewers can display it
without special tooling. Use a locally available renderer or image tool;
deterministic SVG/HTML rendering is suitable for precise labels and geometry.
Follow applicable image-tool instructions when using image generation. If
rendering is unavailable, report the missing preview as incomplete rather
than silently substituting a text diagram.

The canonical Markdown remains the semantic authority. Images illustrate it;
do not introduce actions, data, or behavior that the text does not define.
Label generated wireframes separately from implementation screenshot evidence.

## Visual language

- Use low-fidelity, neutral boxes, lines, simple symbols, and legible text.
  Represent hierarchy, grouping, alignment, relative width, spacing intent,
  scrolling boundaries, and primary/secondary action priority without dropping
  visible product-owned structure.
- Use generic viewport boundaries. Omit device frames, status bars, operating
  system branding, platform-specific navigation chrome, and framework names.
- Depict ordinary controls semantically: input, slider, toggle, selection,
  list, navigation, dismissal, and primary action. A wireframe must not force
  an iOS control appearance onto Android or vice versa.
- Derive regions and reusable elements from the surface/design contracts.
  Reference semantic tokens where annotations help; neutral wireframe colors
  are illustrative and must not become new production design tokens.
- Show realistic, non-sensitive sample content, amounts with units, and
  meaningful labels. Distinguish sample data from actual defaults in the
  caption when confusion is possible.
- Preserve the reference's information density and composition. Replacing a
  chart family, dropping an axis or legend, collapsing several rows into one,
  or removing a context/navigation row is a contract change, not a harmless
  low-fidelity choice.
- Show a sheet's content boundary and its documented completion/dismissal
  actions. A muted generic parent may show modality, but another screen's
  full layout belongs in its own image and description.

## States and responsive layouts

Provide a representative primary state for each screen and sheet. Add separate
images for documented states that materially change the layout or available
actions, such as empty content, validation errors, or permission denial. If
references show materially different states or viewports, identify them before
selecting the primary image; do not treat a compact or wearable image as a
complete substitute for a more detailed current capture. Do not invent states
just to fill a checklist. Text may cover changes that do not affect structure.

Use semantic viewport names such as compact, expanded, or wearable. Add an
expanded variant when the contract specifies a materially different layout
(for example, a split view). Record the viewport dimensions as illustration
metadata, not mandatory production pixel dimensions. Static images do not
replace motion, focus-order, or accessibility requirements in the text.

## Review and synchronization

Render and visually inspect every new or changed image at readable size.
Check every product-owned item in the visual inventory against the image:
region order, content, action placement, repeated-element count, chart/list
structure, dependent context rows, relative sizing, density, and state. Check
for clipped labels, overlaps, unreadable text, unintended platform styling,
invented controls, and silent omissions. A platform-owned status bar or device
frame may be absent only when it is explicitly classified as excluded.

Each canonical file must embed its primary image and any additional variants,
with alt text and captions identifying state, viewport, and the surface
contract version used to generate or last verify them. The surface index must
link the primary image. Verify that all links resolve to nonempty, decodable
files and that every in-scope visual screen/sheet has coverage.

When a layout, visible action, or illustrated state changes, update the source
and regenerate its preview in the same change. For text-only changes, review
whether the image is affected and record the version against which it was
verified. Report actual generation and visual inspection separately from
runtime UI testing; wireframes cannot prove the app behaves as documented.
