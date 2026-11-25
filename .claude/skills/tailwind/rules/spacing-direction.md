---
title: Spacing Direction — Bottom Only
impact: HIGH
tags: spacing, margin, padding, gap
---

**Rule**: Don't use `mt-*` or `pt-*` for vertical spacing between stacked elements. Use `gap-*` on the parent, or `mb-*`/`pb-*` on the element above.

**Why**: One direction means one owner. When every element pushes the *next* one down, adding, removing, or reordering a child changes spacing in exactly one place — mixing `mt` and `mb` gives you doubled gaps and gaps that vanish when a sibling is deleted. (Note: this is not about margin collapse. Adjacent vertical margins collapse whichever direction they point, and padding never collapses at all — the win here is predictability, not collapse avoidance.)

Prefer `gap-*` on a flex/grid parent over per-child margins whenever the children are a uniform stack.

### Incorrect

```gleam
html.div([attribute.class("mt-4 pt-4")], [
  html.h2([attribute.class("mt-6")], [element.text("Titel")]),
  html.p([attribute.class("mt-2")], [element.text("Innehåll")]),
])
```

### Correct

```gleam
// gap on the parent — preferred for a uniform stack
html.div([attribute.class("flex flex-col gap-4")], [
  html.h2([], [element.text("Titel")]),
  html.p([], [element.text("Innehåll")]),
])

// or bottom-only margins when the gaps differ
html.div([attribute.class("mb-4 pb-4")], [
  html.h2([attribute.class("mb-2")], [element.text("Titel")]),
  html.p([], [element.text("Innehåll")]),
])
```

### Not a violation

`py-*` and `my-*` are symmetric — they set both sides at once and aren't directional spacers. Container padding like `py-6` is correct and preferred over `pb-6` when the padding is meant to be even on both sides.

```gleam
html.main([attribute.class("max-w-5xl mx-auto px-4 py-6")], [content])
```
