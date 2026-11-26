# 0005. Tailwind without DaisyUI, self-hosted fonts

Status: Accepted · 2026-11-25

## Context

The brand profile is written as DaisyUI theme tokens for Orkestra. The site
should need no Node toolchain.

## Decision

Tailwind v4, run from the build through `glailglind`, which downloads a pinned
standalone binary. The profile's tokens live in `@theme` under the same names
as Orkestra's theme. No DaisyUI: a public site needs few components, and its
stylesheet can't be purged without Node. Fonts are self-hosted woff2, with no
request to Google.
