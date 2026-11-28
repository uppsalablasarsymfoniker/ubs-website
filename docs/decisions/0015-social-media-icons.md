# 0015. Social media icons

Status: Accepted · 2026-11-28

## Context

The footer and contact page link to Facebook and Instagram as plain text.

## Decision

Show each platform's icon, from Simple Icons (CC0), inlined as SVG in one
colour that follows its link (`fill="currentColor"`), never in brand blue or
the Instagram gradient. In the footer, icons only (24px in a 40px tap area,
with an `aria-label`); on the contact page, the icon beside the account name.
The icon rule goes into `docs/ubs-profile.html` first. Adding a platform means
adding its setting, its CMS field, and its icon together.
