---
title: Collapse Spacing to Shorthands
impact: MEDIUM
tags: shorthand, margin, padding, verbose
---

**Rule**: When opposite or all sides carry the same value, use the shorthand: `px-*` / `py-*` for one axis, `p-*` or `m-*` for all four.

(This is about *shorthand consolidation*. CSS "logical properties" are a different thing — the writing-mode-relative `ms-*`/`me-*`/`ps-*`/`pe-*` utilities. This project is Swedish, left-to-right only, so the physical `mx-*`/`px-*` utilities are fine; reach for the logical ones only if RTL support is ever added.)

### Incorrect

```gleam
html.div([attribute.class("mt-4 mr-4 mb-4 ml-4")], [])
html.div([attribute.class("pt-2 pb-2")], [])
html.div([attribute.class("pl-4 pr-4")], [])
```

### Correct

```gleam
html.div([attribute.class("m-4")], [])
html.div([attribute.class("py-2")], [])
html.div([attribute.class("px-4")], [])
```

Don't collapse when the values differ — `px-4 pt-2 pb-6` is already minimal. And note that collapsing a `pt-*`/`pb-*` pair into `py-*` also clears the [spacing-direction](spacing-direction.md) rule, since `py-*` is symmetric rather than directional.
