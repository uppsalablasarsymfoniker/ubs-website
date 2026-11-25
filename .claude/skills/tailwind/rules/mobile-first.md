---
title: Mobile-First Responsive Design
impact: MEDIUM
tags: responsive, breakpoints, mobile-first
---

**Rule**: Unprefixed classes are the mobile base; `sm:` / `md:` / `lg:` / `xl:` progressively enhance upward. Values should grow as breakpoints grow, never shrink.

Tailwind breakpoint variants are `min-width` queries, so a `sm:` rule stays active at `lg`. Writing `text-2xl md:text-xl sm:text-lg` doesn't shrink anything — the largest matching breakpoint wins, and the source order makes the intent unreadable.

### Incorrect

```gleam
// desktop-first — values shrink as the breakpoint grows
html.div([attribute.class("text-2xl md:text-xl sm:text-lg")], [])
html.div([attribute.class("grid-cols-4 md:grid-cols-2 sm:grid-cols-1")], [])
```

### Correct

```gleam
// mobile-first — values scale up
html.div([attribute.class("text-lg md:text-xl lg:text-2xl")], [])
html.div([attribute.class("grid-cols-1 md:grid-cols-2 lg:grid-cols-4")], [])
```

Write variants in ascending breakpoint order so the progression reads left to right.

For the rare case that genuinely needs a desktop-only or mobile-only rule, use v4's `max-*` variants (`max-md:hidden`) or a range (`md:max-lg:flex`) rather than inverting the base classes.
