---
title: Stay on the Spacing Scale
impact: MEDIUM
tags: spacing, scale, consistency
---

**Rule**: Spacing utilities use the steps from the graphical profile (`docs/ubs-profile.html` §05). Avoid fractional steps and arbitrary pixel values.

Tailwind v4's spacing unit is `0.25rem` (4px), so scale number `N` = `N × 4px`. The profile's scale is that default unit with these steps:

`1` (4px) · `2` (8px) · `3` (12px) · `4` (16px) · `5` (20px) · `6` (24px) · `8` (32px) · `10` (40px) · `12` (48px) · `16` (64px)

Steps above `16` (`20`, `24`, `32`, …) are fine for page-level layout. Off-scale: `7`, `9`, `11`, `14`, fractional steps (`0.5`, `1.5`, `2.5`, …), and arbitrary values like `p-[13px]`.

### Incorrect

```gleam
html.div([attribute.class("p-1.5 gap-7 m-11")], [])
html.div([attribute.class("p-[13px]")], [])
html.div([attribute.class("py-9")], [])
```

### Correct

```gleam
html.div([attribute.class("p-2 gap-6 m-12")], [])
html.div([attribute.class("p-3")], [])
html.div([attribute.class("py-8")], [])
```

When fixing, round to a neighbouring step. Pick the direction that keeps the element's spacing consistent with its siblings rather than the one closest in pixels.

### Exceptions

- Hairline values used for optical alignment (a `1px` border offset, `-mx-px`) are not spacing and aren't covered by this rule.
