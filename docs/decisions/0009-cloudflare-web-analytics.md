# 0009. Cloudflare Web Analytics

Status: Accepted · 2026-11-25

## Context

The board wants to know which pages are read and where visitors come from,
without a cookie banner. Candidates: Cloudflare Web Analytics (free),
GoatCounter (free, EU), Plausible (paid, EU).

## Decision

Cloudflare Web Analytics. The build adds its script only when the
`CLOUDFLARE_ANALYTICS_TOKEN` variable is set, so local builds and forks send
nothing. Data is held by a US company. Once hosting moves to Cloudflare, it
can be switched on in the dashboard instead.
