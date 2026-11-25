---
title: Use size-* for Equal Dimensions
impact: HIGH
tags: size, width, height, dimensions
---

**Rule**: When width and height are the same, use `size-*` instead of paired `h-*` and `w-*`. (`size-*` is available in Tailwind ≥ 3.4; this project is on v4.)

### Incorrect

```gleam
html.div([attribute.class("h-8 w-8")], [])
html.div([attribute.class("h-12 w-12")], [])
html.div([attribute.class("h-full w-full")], [])
html.div([attribute.class("w-6 h-6")], [])
```

### Correct

```gleam
html.div([attribute.class("size-8")], [])
html.div([attribute.class("size-12")], [])
html.div([attribute.class("size-full")], [])
html.div([attribute.class("size-6")], [])
```

Keep separate utilities when the dimensions genuinely differ — these are correct as written:

```gleam
html.div([attribute.class("h-8 w-12")], [])
html.div([attribute.class("h-full w-screen")], [])
```

Two caveats before collapsing a pair:

- Only collapse when both values are literally the same token. `h-4 w-1/4` and `h-full w-screen` are different lengths despite looking symmetric.
- If one dimension is overridden at a breakpoint (`h-8 w-8 md:w-12`), collapsing to `size-8 md:w-12` still works, but check the responsive intent — often the clearer fix is to keep both axes explicit.
