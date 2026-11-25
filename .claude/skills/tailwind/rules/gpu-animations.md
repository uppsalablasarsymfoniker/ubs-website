---
title: GPU-Accelerated Animations
impact: MEDIUM
tags: animation, transition, transform, performance
---

**Rule**: Animate `transform` and `opacity`, and name the property you're transitioning instead of using `transition-all`.

**Why**: `transform` and `opacity` are composited on the GPU — they skip layout and paint. Animating `width`, `height`, `margin`, or `padding` forces a layout recalculation every frame. `transition-all` compounds the problem: it also animates properties you never intended to change (colors, borders, and anything a parent state sets), which causes visible flickers on hover.

### Incorrect

```gleam
html.div([attribute.class("transition-all hover:ml-4")], [])
html.div([attribute.class("transition-all duration-300 hover:w-64")], [])
```

### Correct

```gleam
html.div([attribute.class("transition-transform hover:translate-x-4")], [])
html.div([attribute.class("transition-[width] duration-300 hover:w-64")], [])
```

Tailwind's targeted transition utilities: `transition-transform`, `transition-opacity`, `transition-colors`, `transition-shadow`, and `transition-[<property>]` for anything else.

When a layout property really must animate, keep it scoped (`transition-[width]`) so only that property is in play.
