---
name: ubs-brand
description: This skill should be used when writing or reviewing any user-facing markup or styling in this project — Lustre views in `src/ubs_website/`, `assets/css/input.css`, a new page, view, or component — or when picking a color, font size, or heading level, styling text on a colored background, placing the logo, or when the user mentions brand, graphical profile, colors, typography, contrast, or the logo. Supplies the UBS brand tokens and the contrast rules that constrain them.
allowed-tools: Read, Glob, Grep, Edit, Bash(grep:*), Bash(rg:*)
---

UBS brand tokens for this project. **Source of truth: `docs/ubs-profile.html`** — open it for specimens, the live contrast matrix, and print values. Change that file first; `assets/css/input.css` mirrors it.

Every value below already exists as a Tailwind v4 `@theme` token in `assets/css/input.css`. The names follow the profile's §06 theme map, so `bg-primary` means the same here as in Orkestra. **Use the token, never a raw hex.** A hex literal in markup or CSS is the bug this skill exists to prevent.

## Ownership

This skill owns **color, typography, logo, and assets**. It does *not* own spacing — the `tailwind` skill owns the spacing scale and layout conventions. Defer to it for `gap-*`, `p-*`, `m-*`, breakpoints, and `size-*`.

## Rebuilding

After changing classes, rebuild: `tailwindcss -i assets/css/input.css -o dist/css/site.css`.

The brand utilities below are force-emitted via `@source inline(...)` in `input.css`, so they exist even before first use — do not remove those directives. Any *other* new utility is generated only when Tailwind finds it in a source file, and until you rebuild it silently falls back to the inherited value rather than erroring.

## Color

| Brand color | Hex | Use in markup |
|---|---|---|
| UBS Red | `#B2292E` | `bg-primary`, `text-primary` |
| Dark Red | `#8B1A2B` | `hover:bg-primary-hover` |
| Warm Brass | `#C4A35A` | `bg-accent` — decorative only, see below |
| UBS Black | `#1A1A1A` | `bg-neutral`, `bg-secondary`, `text-base-content` |
| Warm Gray | `#6B6460` | `text-muted` — **on light surfaces only** |
| Warm Gray Light | `#8A827D` | `text-muted-inverse` — **on dark surfaces only** |
| Warm White | `#FAF8F5` | `bg-base-100` |
| Surface | `#F0EEEB` | `bg-base-200` |
| Border | `#E0DDD8` | `bg-base-300`, `border-base-300` |

Pair `bg-*` with its `text-*-content` (`bg-primary text-primary-content`) and contrast is handled for you.

### Status colors (profile §08)

Functional, not brand identity. Low chroma so they sit alongside the muted palette; error alone is high-chroma, because urgency is its job.

| Status color | Hex | Use in markup | On base-100 / base-200 |
|---|---|---|---|
| Error | `#D01C29` | `bg-error`, `text-error` | 5.11 / 4.67 |
| Success | `#246E3A` | `bg-success`, `text-success` | 5.88 / 5.39 |
| Warning | `#8F5D04` | `bg-warning`, `text-warning` | 5.30 / 4.85 |
| Info | `#3E668F` | `bg-info`, `text-info` | 5.66 / 5.18 |

All four clear AA as a fill under `*-content` and as text on both light surfaces. base-200 governs — it is the darkest light surface text sits on. base-300 is a border, never a text surface.

- **Error is not primary, and the difference is load-bearing.** UBS Red owns primary actions and Dark Red their hover state; error is a brighter red in the same family (ΔE 0.059 from primary, 0.147 from primary-hover). Never substitute `bg-primary` for an error state or vice versa — a failed save would look like a save button.
- **Warning is the AA-safe sibling of brass, not brass.** Brass is 2.27:1 on light and can never carry text; warning is the same hue taken dark enough to pass. Use brass for decoration, warning for meaning.
- **Color is never the only signal.** Pair every status with a word, an icon, or both — a red chip and a green chip are the same chip to a color-blind reader.

### Contrast rules — these are not style preferences

Never ship these four; each fails WCAG AA:

- **`text-muted` on any dark surface** (`bg-neutral`, `bg-secondary`) — 3.00:1, fails at *every* size. Use `text-muted-inverse`.
- **`text-muted-inverse` on any light surface** — 3.56:1. Use `text-muted`.
- **Brass text on a light surface** — 2.27:1. Brass is decorative: fills, rules, dividers, never body text on light.
- **Dark text on `bg-primary`** — 2.69:1. Use `text-primary-content`.

Large-text-only (24px+, or 19px+ bold): brass ↔ dark red, 3.83:1.

Safe at any size, on the two text surfaces `bg-base-100` and `bg-base-200`: `text-base-content` (16.42 / 15.03), `text-primary` (6.10 / 5.58), `text-muted` (5.48 / 5.01). Also `text-base-100` or `text-accent` on `bg-neutral` (16.4:1, 7.2:1).

`bg-base-300` is a **border**, not a text surface — the profile assigns it to hairlines and input borders, and it is not rated for text. Dark text on it is dimmer than the figures above (`text-muted` is 4.29:1 there, below AA). If a design needs a filled panel, use `bg-base-200`.

When introducing a pair not listed here, check it against the matrix in profile §02 rather than guessing.

## Typography

Six steps. Size, line-height, and letter-spacing travel together in one utility — never add `leading-*` or `tracking-*` on top.

| Utility | Size | Leading | Tracking | For |
|---|---|---|---|---|
| `text-h1` | 36px | 1.15 | 0.5px | Page title |
| `text-h2` | 28px | 1.2 | 0 | Section heading |
| `text-h3` | 20px | 1.3 | 0 | Subheading |
| `text-body` | 16px | 1.6 | 0 | Body copy (the `body` default) |
| `text-small` | 13px | 1.5 | 0 | Captions, helper text, dense labels |
| `text-label` | 11px | 1.4 | 1.5px | Uppercase eyebrow labels |

- `text-*` utilities outside this table (`text-xl`, `text-sm`, `text-2xl`, …) are off-scale. If a design seems to need one, extend the profile — do not add a one-off.
- For the full uppercase label treatment (size + weight 600 + tracking + `uppercase`) use the **`label-type`** utility rather than assembling it by hand.
- Families: `font-display` (Playfair Display), `font-body` (Source Sans 3), `font-mono` (Source Code Pro). `h1`–`h6` get `font-display` automatically — only add it to non-heading elements.
- Playfair is display-only; its hairlines break down below 20px. Never use `font-display` below `text-h3`.
- Weight is not part of the scale — add `font-bold` explicitly where a step needs it.

## Logo

Files live in `static/images/` and are served from `images/` under the site's base path — build the URL with the path helper, never a literal `/images/…`. Pick the variant by background; do not recolor at runtime.

| File | Background |
|---|---|
| `ubs-logo.svg` | Light surfaces only (`bg-base-*`, white cards) |
| `ubs-logo-white.svg` | `bg-neutral`/`bg-secondary`, `bg-primary`, and other darks |
| `ubs-logo-black.svg` | `bg-accent` (brass) and light accents |

- Minimum `h-8` (32px) on screen. Always pair with `w-auto`.
- Clear space: 25% of the rendered logo height on all four sides.
- Never rotate, stretch, skew, apply any other color, or add shadows, glows, or outlines. CSS `filter` recoloring is not an approved variant — use the right file.
- `alt` is the orchestra name, not "UBS".
- The full-color logo is a single UBS Red fill: 2.69:1 on black, below even the 3:1 floor for graphics. Never put it on a dark surface.

## Radius

Three steps, mapped onto Tailwind's radius utilities: `rounded-sm` 4px (buttons, inputs, tabs) · `rounded-md` 6px (badges, chips, insets) · `rounded-lg` 10px (cards, panels). `rounded-lg` is overridden from Tailwind's 8px default in `input.css`. Other radius utilities are off-scale.

## Language

The site is **Swedish first, with English**. Every user-facing string exists in both languages; Swedish is the default and lives at the site root, English under `/en/`. Class names, tokens, comments, and commit messages stay English. Swedish needs å/ä/ö — never strip diacritics, and check them in any type specimen. Mark any Swedish text shown on an English page with `lang="sv"`.
