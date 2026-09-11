# Documentation contract validation checklist

Adapt paths and commands to the repository. These checks validate the
documentation contract; they do not prove runtime behavior.

## Authority and structure

- [ ] Repository instructions and product authority were read first.
- [ ] The surface index contains every in-scope screen, sheet, wearable
      surface, and system entry point.
- [ ] Every stable ID is unique, lowercase/stable, and maps to exactly one
      canonical description file.
- [ ] Every canonical description file maps back to exactly one stable ID.
- [ ] The index is not duplicating detailed screen layouts or behavior.
- [ ] Platform documents link to canonical descriptions instead of redefining
      them.

## Canonical surface files

- [ ] Purpose/outcome, entry/exit, region order, read model, actions, states,
      validation, accessibility, design contract, responsive behavior, and
      forbidden behavior are present or explicitly not applicable.
- [ ] The language is platform-independent.
- [ ] No framework component names, source paths, or platform API instructions
      appear in the canonical semantic description.
- [ ] A screen description does not absorb another screen or sheet's complete
      contract.
- [ ] Amounts include units, icons have semantic labels, and large text/reduced
      motion behavior is addressed.

## Cross-platform and design/data consistency

- [ ] Shared product behavior, domain operations, source-of-truth rules, and
      accessibility outcomes agree with the product contract.
- [ ] Design references use named tokens/components; feature-local token
      systems were not introduced.
- [ ] Data fields, IDs, units, defaults, validation, soft deletion, and use-case
      boundaries agree with the data model.
- [ ] Native controls are preferred for ordinary interaction where they satisfy
      the semantic contract.
- [ ] Platform-specific navigation/input/system behavior is documented only in
      the relevant platform mapping.
- [ ] Evidence captures are labeled as evidence and do not override text.

## Versioning and repository hygiene

- [ ] Every changed versioned document has updated `Last verified` metadata.
- [ ] Every changed versioned document has one appended immutable timeline row.
- [ ] Relative Markdown links resolve.
- [ ] `git diff --check` passes for tracked changes.
- [ ] No unrelated source, generated, or user changes were overwritten.
- [ ] The final report distinguishes documentation validation from runtime
      tests and build verification.

## Useful checks

Use fast repository search to inspect scope and framework leakage:

```sh
rg -n "TODO|TBD|FIXME|PLACEHOLDER" <maintained-docs>
rg -n "SwiftUI|UIKit|Compose|Material|NavigationStack|TabView|Scaffold" <canonical-surface-directory>
git diff --check
```

For relative links, resolve each Markdown link from the directory containing
its file and ignore external URLs, anchors, and mail links. For stable-ID
coverage, compare the index table, filenames, and the ID field in every
canonical surface file.
