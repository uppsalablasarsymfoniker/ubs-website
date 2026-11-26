# UBS website — plan

Public website for Uppsala Blåsarsymfoniker (UBS), replacing the current
WordPress/Divi site at uppsalablasarsymfoniker.se (`ubs.nu` redirects there).

This file describes what the site is and is meant to be, and is edited in
place as that changes. Why each choice was made is in `docs/decisions/`;
progress and open work are GitHub issues, grouped by milestone. Preview:
https://uppsalablasarsymfoniker.github.io/ubs-website/

Repository: `uppsalablasarsymfoniker/ubs-website` on GitHub.

## Goals

- Board members can update content from a browser, without touching code.
- AI agents can update content just as easily — plain files in git, no
  proprietary API in the way.
- As little technology as possible: Gleam, static HTML, no database, no
  server to run or patch.
- Follows the UBS graphical profile (`docs/ubs-profile.html`).
- Swedish first, with English throughout.

## Architecture

A static site built by Gleam from Markdown content in this repo, edited
through a git-based CMS.

```
 board member ──► /admin (Sveltia CMS, in the browser)
                        │ commits via GitHub API
 AI agent ──────────────┤ edits files, opens PR / commits
                        ▼
                 GitHub repo: content/*.md + images
                        │ push, or the daily schedule, triggers CI
                        ▼
          GitHub Actions: gleam run build → dist/ (HTML, CSS, assets)
                        │
                        ▼
                 GitHub Pages
```

### Does a static site work with a CMS web UI?

Yes. A git-based CMS is itself a static single-page app served at `/admin`.
It reads and writes Markdown files in the GitHub repo through the GitHub API,
so every save is a commit, and each commit triggers a rebuild and deploy
(typically under a minute). There is no CMS server or database.

Trade-offs to accept:

- Edits appear after the rebuild, not instantly. The CMS shows a preview
  while editing.
- Editors sign in with a GitHub account — **agreed**. Each editor needs the
  Write role on the repository. See *CMS* for the sign-in options.
- Anything dynamic — a contact form, a newsletter sign-up — needs an
  external service. See *Forms*.

### Why this CMS shape is agent-friendly

Content is Markdown with TOML front matter in a fixed folder layout, and the
CMS config (`assets/admin/config.yml`) doubles as the schema. An agent edits
the same files the CMS does, reviewable as an ordinary diff, with git history
as the audit log and undo. No API keys, MCP server, or vendor account
required.

### Alternatives considered

Hosted and self-hosted CMSs, Decap CMS, a Gleam server, and `lustre_ssg`:
see decisions [0001](decisions/0001-static-site-built-with-gleam.md),
[0002](decisions/0002-sveltia-cms.md), and
[0004](decisions/0004-hand-written-build-module.md).

### Technology

| Concern | Choice |
|---|---|
| Generator | Gleam, a hand-written build module; Lustre elements rendered to HTML strings. Structure follows Hayleigh Thompson's `hayleigh.dev` (see *Repository layout*) |
| Markdown | `mork` — passes the full CommonMark spec test suite |
| Front matter | TOML (`+++` delimited), parsed with `tom`. Sveltia writes it with `format: toml-frontmatter`. Markdown rather than Djot: [0003](decisions/0003-markdown-with-toml-front-matter.md) |
| Dates | `gleam_time`. Sveltia writes native TOML date-times (`2027-01-30T19:00:00.000`) and dates (`2027-01-30`) |
| CSS | Tailwind, run from the build through `glailglind`; profile tokens in `@theme`; no DaisyUI ([0005](decisions/0005-tailwind-without-daisyui.md)) |
| Fonts | Self-hosted woff2 (as in Orkestra) — no request to Google at runtime |
| CMS | Sveltia CMS, loaded from unpkg unversioned, as its docs recommend |
| Hosting | GitHub Pages via GitHub Actions now; Cloudflare at launch ([0008](decisions/0008-github-pages-then-cloudflare.md)). Rebuilt on push and daily, so a concert moves to "past" without an edit |
| Images | Sveltia converts uploads to WebP in the browser; images are shown whole ([0010](decisions/0010-images-shown-whole.md)) |
| Video | YouTube embeds via `youtube-nocookie.com` (proposed: [0014](decisions/0014-video-embeds.md)) |

## Languages

Swedish is the default and lives at the site root; English lives under `/en/`
([0006](decisions/0006-swedish-first-languages.md)).

| Content | Swedish | English |
|---|---|---|
| General pages (home, about, join, booking, contact) | required | **required** — the CMS won't save without it, and the build fails without it |
| Concerts, news | required | optional |
| UI text (navigation, labels, dates) | in code | in code |

- Translations are separate files side by side: `content/concerts/<slug>.sv.md`
  and `<slug>.en.md`.
- Fields that don't vary by language — dates, venue, ticket link, image — are
  read from the Swedish file only.
- An English listing shows every concert and news item. An item without an
  English translation shows its Swedish text, marked `lang="sv"` and labelled
  "In Swedish".
- Every route exists in both languages, untranslated concerts and news
  included, so the language switch always links to the same page in the other
  language, and every page declares both with `<link rel="alternate"
  hreflang>`.
- `lang="sv"` goes on the Swedish title, summary, and body only — never on
  the English navigation, labels, and dates around them.

| Swedish | English |
|---|---|
| `/` | `/en/` |
| `/om-oss/` | `/en/about/` |
| `/bli-medlem/` | `/en/join/` |
| `/boka-oss/` | `/en/book-us/` |
| `/kontakt/` | `/en/contact/` |
| `/konserter/`, `/konserter/<slug>/` | `/en/concerts/`, `/en/concerts/<slug>/` |
| `/nyheter/`, `/nyheter/<slug>/` | `/en/news/`, `/en/news/<slug>/` |

## Repository layout

```
content/          Markdown + TOML front matter, edited by the CMS and agents
  pages/          <page>.sv.md + <page>.en.md
  concerts/       <slug>.sv.md [+ <slug>.en.md]
  news/           <slug>.sv.md [+ <slug>.en.md]
  members.toml    member list
  settings.toml   contact details, social links
src/
  app.css               Tailwind input with the profile tokens
  ubs_website.gleam     entry point: `gleam run build`
  ubs_website/
    build.gleam         renders every route and writes dist/
    error.gleam         one error type for everything the build can fail on
    site.gleam          where the site is published (SITE_URL) and when built
    route.gleam         every page's path in each language
    tailwind.gleam      runs Tailwind through glailglind
    data/               what the content is, and loading it from content/:
                        entry (front matter + Markdown), content (all of it),
                        language, page, concert, news, member, settings
    view/               how it looks: document (shell, header, footer, 404),
                        page (general pages, home sections), concert, news,
                        member, date
    meta/               sitemap.xml and robots.txt
test/                   gleeunit tests
assets/                 copied to dist/ as is
  admin/              Sveltia: index.html + config.yml
  fonts/              self-hosted woff2 + OFL licences
  images/             logos; uploads/ for CMS media
dist/                   build output, not committed
```

The layout mirrors Hayleigh Thompson's `hayleigh.dev`
(github.com/hayleigh-dot-dev/hayleigh.dev): `data/` for what the content is,
`view/` for how it looks, `meta/` for machine-readable output, and one build
module. Unlike that site, the build returns errors rather than asserting, per
*Build, test, deploy*.

Build: `gleam run build`. A `serve` command with live reload, like
`hayleigh.dev`'s, is a later follow-up; until then, preview `dist/` with any
static file server.
`SITE_URL` sets the public address, including any path the site lives under
(e.g. `https://uppsalablasarsymfoniker.github.io/ubs-website` for the GitHub
Pages project URL); without it the build targets `http://localhost:8000`.
Every internal link and asset URL goes through `route.gleam`, which adds the
path, so the site works both at a domain root and under a project path.
`CLOUDFLARE_ANALYTICS_TOKEN` adds the analytics script when set.

## Content model

Milestone 1 builds the first five collections. The rest arrive with the
migration, once it is decided what to keep.

| Collection | Storage | Fields | Notes |
|---|---|---|---|
| `pages` | `content/pages/<page>.<locale>.md` | title, description (meta), body | Fixed set: home, about, join, booking, contact. Both languages required. |
| `concerts` | `content/concerts/<slug>.<locale>.md` | title, summary, body · *Swedish only:* performances (list of date-times), venue, ticket URL, image | Upcoming vs. past derived from the last performance. Program and collaborators go in the body. Tickets are always sold elsewhere; the site only links out. |
| `news` | `content/news/<slug>.<locale>.md` | title, summary, body · *Swedish only:* date, image | |
| `members` | `content/members.toml` | list of: name, section, role (optional) | See *Members*. Sections are a fixed list in code with Swedish and English names. |
| `settings` | `content/settings.toml` | email, phone, postal address, Facebook, Instagram | Footer and contact page. |
| `competitions` | later | competition (SM/EM/VM), year, result, repertoire, report, images | Replaces the per-year `sm-2019`-style pages. |
| `testimonials` | later | quote, author, author role, date | "Sagt om oss". |
| `videos` | later | title, YouTube ID, composer, date | "Filmklipp". |
| `galleries` | later | title, date, images | "Bilder". |
| `press` | later | releases; press images with photographer credit | |
| `sponsors` | later | name, logo, link | |

Member sections, in display order: dirigent, flöjt, oboe, fagott, klarinett,
saxofon, horn, trumpet/kornett, trombon, euphonium, tuba, kontrabas, slagverk.

## CMS

Sveltia CMS at `/admin`, configured in `assets/admin/config.yml`.

```yaml
i18n:
  structure: multiple_files
  locales: [sv, en]
  default_locale: sv
```

- **pages** — a file collection, one entry per page, file path
  `content/pages/about.{{locale}}.md`. Fields `i18n: true`, which makes every
  locale required.
- **concerts**, **news** — folder collections, `format: toml-frontmatter`.
  Translatable fields `i18n: true` with `required: [sv]`, so English may be
  left out. Language-neutral fields `i18n: duplicate` (edited in Swedish,
  read-only in English).
- **members**, **settings** — file collections with `format: toml`, no i18n.
  Members is a list widget of objects, stored as `[[members]]` tables.
- **Media** — `media_folder: assets/images/uploads`, `public_folder:
  /images/uploads`, with the WebP transformation from *Technology*. Concerts
  and news have their own folders, `assets/images/concerts` and
  `assets/images/news`, so the CMS shows their existing images.

### Sign-in

Sveltia runs entirely in the editor's browser and talks to the GitHub API
directly, so all it needs is a GitHub access token that may write to this
repository. Sign-in is just how the browser gets that token. Every save is
then a commit authored by the editor, and removing someone's access to the
repository removes their access to the CMS.

Either way, each editor needs a GitHub account and the Write role on the
repository — simplest as members of an "editors" team in the organisation.

Two ways to get the token, both documented by Sveltia:

1. **Personal token** — the editor creates a fine-grained personal access
   token on GitHub (Contents: read and write, this repository only) and
   pastes it into the CMS once; the browser keeps it. Nothing to host, but
   it takes a few minutes per editor, and tokens expire and must be renewed.
2. **"Sign in with GitHub"** (OAuth):
   1. The editor clicks the button; a popup opens GitHub's authorisation
      page for UBS's GitHub App.
   2. The editor approves; GitHub sends a one-time code to the sign-in
      service, `sveltia-cms-auth`.
   3. The service exchanges the code for a token, using the app's secret,
      and hands the token back to the CMS window.

   The service exists only because that secret cannot live in a static
   page. It is a small open-source Cloudflare Worker, free tier, set up once
   by whoever owns UBS's Cloudflare account, and named as `base_url` in the
   CMS config.

**Decided:** "Sign in with GitHub"
([0007](decisions/0007-sign-in-with-github.md)). Personal tokens remain as a
fallback for developers while the Worker isn't deployed yet.

Setup, once UBS has a Cloudflare account:

1. Deploy `sveltia-cms-auth` to Cloudflare Workers (its README has a
   one-click deploy).
2. Create a GitHub App (or OAuth App) in the `uppsalablasarsymfoniker`
   organisation, with the Worker's `/callback` URL as the callback.
3. Set the app's client ID and secret, and `ALLOWED_DOMAINS` (the site's
   domains), as Worker secrets.
4. Put the Worker URL in `assets/admin/config.yml` as `backend.base_url`.
5. Create an "editors" team with Write access to this repository.

## Pages

Header: logo and name, navigation (Konserter, Nyheter, Om oss, Bli medlem,
Boka oss, Kontakt), language switch. On narrow screens the navigation wraps
below the logo; no JavaScript menu.
Footer: contact details and social links from `settings`.

| Page | Content |
|---|---|
| Hem | Intro from `pages/home`; the next concert, prominently; up to three more upcoming concerts; the three latest news items; links to join and booking |
| Konserter | Upcoming, soonest first; past, newest first, grouped by year |
| Concert | Title, every performance date and time, venue, ticket button while upcoming and a URL is set, image, body |
| Nyheter | All news, newest first, with date and summary |
| News item | Title, date, image, body |
| Om oss | Body from `pages/about`; member list grouped by section in the order above |
| Bli medlem | Body from `pages/join`; contact link |
| Boka oss | Body from `pages/booking`; contact link |
| Kontakt | Body from `pages/contact`; contact details and social links from `settings` |
| 404 | Both languages on one page, with links home |

There are no recent photos of the orchestra, so the design must not depend on
one: a typographic home page ([0011](decisions/0011-typographic-design.md)). Link previews use the concert's or news item's
image, otherwise the logo PNG; a designed Open Graph image with the logo and
name is a later follow-up. A photo can be added later without a redesign.

Every page has a `<title>`, a meta description, and Open Graph tags; the build
writes `sitemap.xml` with both languages. Dates are formatted per language
("30 januari 2027, 19.00" / "30 January 2027, 19:00").

Accessibility target: WCAG 2.1 AA — the profile's contrast rules, semantic
headings, visible focus, `lang` on every page and on Swedish fallbacks.

### Social media icons

Proposed: Facebook and Instagram get their icons in the footer and on the
contact page ([0015](decisions/0015-social-media-icons.md)).

## Members

The member list is public personal data, so
([0012](decisions/0012-member-list-by-consent.md)):

- Publish name, section, and role only, with each member's consent.
  Photos and Q&A profiles are opt-in per member, and come later.
- Keep the list current — a list that is years out of date is worse than none.
- **Later, maybe:** generate the list from Orkestra, which already holds
  members and sections. Not designed for now; `members.toml` is kept simple
  enough that an export could replace it.

## Forms

Static hosting has no server to receive a form post. Options, simplest first:

1. `mailto:` links for contact and booking.
2. Embedded or linked Google Forms, as already used for the conductor search.
3. A form service (e.g. Formspree) or a small serverless function, if a styled
   on-site form is needed.

**Proposed:** 1 and 2 ([0013](decisions/0013-forms-without-a-server.md)).

## Build, test, deploy

- Content errors — a missing field, malformed front matter, a general page
  without English — fail the build with a message naming the file, so an
  editor can fix it from the CI log. The build never crashes on content.
- `gleam test` covers content parsing, the language fallback rules, routing,
  and date formatting.
- GitHub Actions on push to `main`, daily at 02:00 UTC, and on demand: set up
  Erlang and Gleam (`erlef/setup-beam`), test, build, deploy with
  `actions/deploy-pages`.
- Preview at `uppsalablasarsymfoniker.github.io/ubs-website/` (GitHub Pages)
  until the domain moves.

### Hosting

GitHub Pages while building; Cloudflare at launch, for real redirects of the
old WordPress URLs ([0008](decisions/0008-github-pages-then-cloudflare.md)).

## Analytics

"Cookie-free" analytics count visits without storing anything in the
visitor's browser and without building a profile of any one visitor. A
small script — or the host itself — records the page, referrer, country, and
device type; visits are counted in aggregate, and IP addresses are not kept.
Because nothing is stored on the device and no personal data is retained,
no cookie banner or consent prompt is needed under GDPR and the ePrivacy
rules, unlike Google Analytics.

What it answers: which pages are read, how many visits a concert page gets,
where visitors come from (Facebook, Google, a newspaper link). What it can't:
follow one person across visits, or count unique visitors exactly.

Cloudflare Web Analytics ([0009](decisions/0009-cloudflare-web-analytics.md)).
The build reads the site token from the `CLOUDFLARE_ANALYTICS_TOKEN`
environment variable (a GitHub Actions variable) and adds the script only
when it is set.

## What the current site has

Surveyed 2026-11-25. Most of this should carry over, after the cleanup in
*Migration*:

- Navigation: Hem, Konserter, Tävlingar, Om oss (with Bilder, Filmklipp),
  Sponsorer, Kontakt, Press, English.
- Home page sections: next concert, upcoming performances, "Möt våra musiker"
  (member Q&A profiles), about, video clips, "Sagt om oss" (quotes from
  adjudicators, conductors, composers).
- Concert archive back to 2015; one page per concert.
- Competition pages: SM 2001, 2002, 2004, 2017, 2018, 2019, 2023; VM 2017;
  EM 2018, 2023, 2024.
- Member list (`/orkestermedlemmar/`) grouped by instrument, last updated 2022.
- Board list (`/styrelse/`), last updated 2022.
- Press page with press releases (2018–2019) and downloadable press photos.
- Video page of YouTube recordings; a photo page.
- English page with testimonials.
- Footer: contact email and phone, postal address, Facebook and Instagram,
  sponsors.
- Conductor-search announcement linking to a Google Form.

Problems to fix in the move:

- Stale content: member and board lists from 2022; the competitions page says
  the EM 2020 trip is upcoming; the photo page holds one 2018 gallery.
- "Kontakt" and "Sponsorer" are anchor links to the footer, not pages.
- A broken `/undefined` link on the home page.
- Leftover pages: membership login and registration (2018), `test`,
  `hem-2`, `hem-experiment`.

## Core content

Milestone 1 uses real content from the current site, not placeholders:

| Content | Source | Notes |
|---|---|---|
| Home intro | "Om oss" section on the home page | |
| About | "Om oss" section, competitions intro, conductor | Updated where stale (EM 2020 "upcoming") |
| Join | Rehearsal facts from the conductor-search text (Mondays in Uppsala, members travel from Västerås and Stockholm) | The current site has no join page: new text, for the board to review |
| Booking | — | No source: new text, for the board to review |
| Contact | Footer: email, phone, postal address, Facebook, Instagram | Board to confirm phone and postal address — they belong to individual board members |
| Concerts | Every concert from 2025 onward, with images | Older ones follow with the full migration |
| News | Conductor search; latest from the news archive (SM 2023) | |
| Members | — | Not migrated: the 2022 list is stale and nobody has consented. The page shows the section once the list is filled in |

English text for the general pages is translated from the Swedish, since the
current English page covers only a fraction of it. Machine-drafted text is
listed in the pull request or commit so the board can review it.

## Migration

The full migration is **deferred** until the core pages are in place. It starts with an inventory
of the current site (the WordPress sitemap lists ~140 posts and ~20 pages:
concerts back to 2015, ~45 member profiles from 2018, competition pages, news,
ticket notices, and the leftover pages above), and a keep / rework / drop
decision per group. The intent is to clean up rather than carry everything
over.

Then:

1. Export the kept content from WordPress (WP export XML, or scrape
   with Playwright) into Markdown files in the content model above.
2. Download images, press photos, and posters into the repo.
3. Keep URLs that are linked from elsewhere (`/konserter/`, `/sm-2019/` …)
   or add redirects.
4. Switch DNS for uppsalablasarsymfoniker.se and `ubs.nu` (domain at One.com)
   once the new site is live.

## Graphical profile

`docs/ubs-profile.html` is copied from Orkestra and is the source of truth for
color, typography, logo, and spacing. The `ubs-brand` and `tailwind` skills in
`.claude/skills/` apply it to this repository.

The profile is written for an app UI, and a public site needs more of it
(the home page's Display size, for one). Extend the profile first, then the
code.

## Milestones

Progress on each is tracked in the GitHub milestone of the same name.

1. **Core pages** — the Gleam build, content loading, the general pages,
   concerts, news, members, 404, sitemap, and the deploy to the preview URL,
   with the content from *Core content*.
2. **CMS** — Sveltia at `/admin` with the five collections; "Sign in with
   GitHub" via the Worker; Cloudflare Web Analytics token.
3. **Migration** — inventory, select, and migrate content; members give
   consent.
4. **Launch** — redirects, DNS switch, retire WordPress.
5. **Later** — remaining collections; Orkestra integration for members and/or
   concerts.
