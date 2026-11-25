---
name: tailwind
description: This skill should be used when writing or reviewing Tailwind CSS classes in this project, or when the user asks to "audit Tailwind", "fix spacing", "review the CSS/markup", or mentions inconsistent spacing, sizing, or responsive breakpoints. Enforces the project's Tailwind v4 conventions.
allowed-tools: Read, Glob, Grep, Edit, Bash(grep:*), Bash(rg:*)
---

Tailwind CSS v4 conventions for this project: consistent spacing scale and direction, `size-*` for square elements, mobile-first breakpoints, and GPU-friendly transitions.

## Project context

- Markup is **Gleam + Lustre**, not JSX. Classes live in `attribute.class("…")` inside `src/ubs_website/*.gleam`. There is no `className` and no `.tsx` in this repo.
- Tailwind **v4** (`@import "tailwindcss"` in `assets/css/input.css`). The spacing unit is `--spacing: 0.25rem`, so a scale number of `N` equals `N × 4px`.
- No component library: every component is built from utilities. Markdown body content is styled by the `.prose` rules in `assets/css/input.css`, not by utilities.
- User-facing strings are Swedish; class names and any code you write stay English.

Read the individual rule file before reporting or fixing a violation of it — each one has the rationale and the correct replacement.

## Rules

| Rule | Severity | File |
|------|----------|------|
| Spacing direction | HIGH | `rules/spacing-direction.md` |
| Equal dimensions | HIGH | `rules/equal-dimensions.md` |
| Spacing scale | MEDIUM | `rules/spacing-scale.md` |
| Mobile-first responsive | MEDIUM | `rules/mobile-first.md` |
| Spacing shorthands | MEDIUM | `rules/spacing-shorthands.md` |
| GPU-accelerated animations | MEDIUM | `rules/gpu-animations.md` |

## Two modes

**Writing new markup** — apply the rules as you write. No audit, no report. This is the common case; don't turn a request to build a page into a codebase audit.

**Auditing existing markup** — run the workflow below. Default scope is `src/ubs_website/`; the user may name a narrower path.

## Audit workflow

### Step 1: Scan

Grep for each pattern below. All of them are scoped to `.gleam` files, and matches only count inside an `attribute.class` string.

| Rule | Pattern |
|------|---------|
| Spacing direction | `\b(mt\|pt)-[a-z0-9.\[]` |
| Equal dimensions | `\b(h-[a-z0-9.]+ w-[a-z0-9.]+\|w-[a-z0-9.]+ h-[a-z0-9.]+)` — then keep only pairs whose values match |
| Spacing scale | `\b(p\|m\|gap\|px\|py\|mx\|my\|pb\|pl\|pr\|mb\|ml\|mr\|space-[xy])-(7\|9\|11\|14\|[0-9]+\.5)\b` and any arbitrary value `\-\[[0-9]+px\]` |
| Mobile-first | `(sm\|md\|lg\|xl\|2xl):` — then check whether values shrink as breakpoints grow |
| Spacing shorthands | `\b(mt\|mb)-` / `\b(ml\|mr)-` / `\b(pt\|pb)-` / `\b(pl\|pr)-` pairs on the same element with equal values |
| GPU animations | `transition-all` |

### Step 2: Report

Group findings by severity, most severe first. Cite `file:line`.

```
## Tailwind audit

### HIGH
- `src/ubs_website/concert.gleam:21` — `mt-4` → `mb-4` on the previous sibling, or `gap-4` on the parent
- `src/ubs_website/layout.gleam:64` — `h-10 w-10` → `size-10`

### MEDIUM
- `src/ubs_website/concert.gleam:44` — `gap-[14px]` → `gap-3` (12px) or `gap-4` (16px)

### Summary
| Rule | Violations | Files |
|------|-----------|-------|
| Spacing direction | 1 | 1 |
| Equal dimensions | 1 | 1 |
| Spacing scale | 1 | 1 |
| **Total** | **3** | **2** |
```

If a scan finds nothing, say so plainly — don't manufacture findings.

### Step 3: Fix (only when asked)

Report first. Apply fixes only if the user asked for them up front or approves the report.

For each fix:
1. Change only the identified class. Don't restructure markup or rename anything nearby.
2. Spacing fixes shift pixels by design — preserve the *layout intent* (which gaps separate which elements), not the exact rendered spacing.
3. A spacing-direction fix moves spacing to a different element. Update that sibling or parent in the same edit, and check the first and last child of the stack don't lose or gain an edge gap.
4. Run `gleam format` when done, and rebuild CSS if class names changed:
   `tailwindcss -i assets/css/input.css -o dist/css/site.css`
