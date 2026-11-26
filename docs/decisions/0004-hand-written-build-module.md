# 0004. A hand-written build module, not `lustre_ssg`

Status: Accepted · 2026-11-25

## Context

The site has about a dozen routes in two languages with their own path rules.

## Decision

One build module renders Lustre elements to HTML and writes `dist/`. The
code layout follows Hayleigh Thompson's `hayleigh.dev`: `data/` for what the
content is, `view/` for how it looks, `meta/` for machine-readable output.
Unlike that site, the build returns errors naming the file rather than
asserting. Adapting `lustre_ssg` to the language rules would be longer.
