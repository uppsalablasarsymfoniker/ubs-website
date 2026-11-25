# UBS website — plan

Public website for Uppsala Blåsarsymfoniker (UBS), replacing the current
WordPress/Divi site at uppsalablasarsymfoniker.se (`ubs.nu` redirects there).

Status: building the core pages. Decisions marked **Proposed** are not yet agreed.

Repository: `uppsalablasarsymfoniker/ubs-website` on GitHub.

## Goals

- Board members can update content from a browser, without touching code.
- AI agents can update content just as easily — plain files in git, no
  proprietary API in the way.
- As little technology as possible: Gleam, static HTML, no database, no
  server to run or patch.
- Follows the UBS graphical profile (`docs/ubs-profile.html`).

## Architecture

**Proposed:** a static site built by Gleam from Markdown content in this repo,
edited through a git-based CMS.

```
 board member ──► /admin (Sveltia CMS, in the browser)
                        │ commits via GitHub API
 AI agent ──────────────┤ edits files, opens PR / commits
                        ▼
                 GitHub repo: content/*.md + images
                        │ push triggers CI
                        ▼
          GitHub Actions: gleam run (generator) → dist/*.html
                        │
                        ▼
                 static hosting (GitHub Pages or Cloudflare Pages)
```

### Does a static site work with a CMS web UI?

Yes. A git-based CMS is itself a static single-page app served at `/admin`.
It reads and writes Markdown files in the GitHub repo through the GitHub API,
so every save is a commit, and each commit triggers a rebuild and deploy
(typically under a minute). There is no CMS server or database.

Trade-offs to accept:

- Edits appear after the rebuild, not instantly. The CMS shows a preview
  while editing.
- Editors sign in with a GitHub account (free) — **agreed**. Sveltia needs a
  small OAuth relay for that (a free Cloudflare Worker, `sveltia-cms-auth`);
  alternatively each editor pastes a personal access token once.
- Anything dynamic — a contact form, a newsletter sign-up — needs an
  external service. See *Forms*.

### Why this CMS shape is agent-friendly

Content is Markdown with TOML front matter in a fixed folder layout, and the
CMS config (`admin/config.yml`) doubles as the schema. An agent edits the same
files the CMS does, reviewable as an ordinary diff, with git history as the
audit log and undo. No API keys, MCP server, or vendor account required.

### Alternatives considered

| Option | Why not (for now) |
|---|---|
| Hosted headless CMS (Sanity, Storyblok, Contentful) | Vendor account, API keys, and a runtime or build-time API dependency. Agent access goes through an MCP server rather than plain files. |
| Self-hosted CMS (Payload, Strapi, Directus) | Needs a server and a database to host, back up, and patch. |
| Decap CMS | Same model as Sveltia and config-compatible; Sveltia is the faster, maintained successor. Keep as fallback. |
| Gleam server (Wisp/Mist) | Only needed for request-time features. None are required yet. |

### Technology

| Concern | Proposed choice | To confirm |
|---|---|---|
| Generator | Gleam + Lustre for HTML, `lustre_ssg` or a small hand-written build script | Whether `lustre_ssg` covers collections or a custom script is simpler |
| Markdown | `mork` — passes the full CommonMark spec test suite | — |
| Front matter | TOML, parsed with `tom` (Sveltia supports `toml-frontmatter`) | — |
| CSS | Tailwind standalone CLI, profile tokens in `@theme` under the same names as Orkestra's DaisyUI theme. No DaisyUI: a public site needs few components and the full DaisyUI stylesheet can't be purged without Node | — |
| CMS | Sveltia CMS | GitHub OAuth relay vs. personal access tokens |
| Hosting | GitHub Pages via GitHub Actions, rebuilt on push and daily (so a concert moves to "past" without an edit) | Cloudflare Pages if preview deploys per PR are wanted |
| Video | YouTube embeds (current practice) | Privacy-enhanced `youtube-nocookie.com` embeds |
| Images | Committed to the repo, resized at build time or by hand | Repo size once galleries are migrated |

### Why Markdown and not Djot

Djot is cleaner to parse, and Gleam has a good Djot parser (`jot`). But
Sveltia's rich-text editor reads and writes Markdown only; storing Djot would
mean giving editors a plain text box with no formatting toolbar. `mork` closes
the gap on the Gleam side, so Markdown costs nothing there.

## Languages

Swedish is the default and lives at the site root; English lives under `/en/`.

| Content | Swedish | English |
|---|---|---|
| General pages (home, about, join, booking, contact) | required | **required** — the build fails without it |
| Concerts, news | required | optional |
| UI text (navigation, labels, dates) | in code | in code |

- Translations are separate files side by side: `content/concerts/<slug>.sv.md`
  and `<slug>.en.md` (Sveltia's `multiple_files` i18n structure).
- Fields that don't vary by language — dates, venue, ticket link, image — are
  read from the Swedish file only.
- An English listing shows every concert and news item. An item without an
  English translation shows its Swedish text, marked `lang="sv"` and labelled
  "In Swedish".
- Each page links to its counterpart in the other language, and declares it
  with `<link rel="alternate" hreflang>`. When there is no English version,
  the language switch goes to the English section page.

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
src/ubs_website.gleam   build entry point: content → dist/
src/ubs_website/        one module per domain (concert, news, page, …)
assets/css/input.css    Tailwind input with the profile tokens
static/                 copied to dist/ as is: fonts, images, admin/ (Sveltia)
dist/                   build output, not committed
```

Build: `gleam run && tailwindcss -i assets/css/input.css -o dist/css/site.css --minify`.
`BASE_PATH` sets the URL prefix (e.g. `/ubs-website` for a GitHub Pages
project URL); it defaults to the domain root.

## Content model

Each collection is a folder under `content/`; each entry is one Markdown file.

| Collection | Fields | Notes |
|---|---|---|
| `concerts` | title, date/time(s), venue, description, program (pieces + composers), ticket link, poster image, collaborators | Upcoming vs. past derived from date. Home page shows the next one. |
| `competitions` | competition (SM/EM/VM), year, placement/result, repertoire, report text, images | Replaces the per-year `sm-2019`-style pages. |
| `news` | title, date, body, image | Also covers announcements like the conductor search. |
| `members` | name, instrument/section, role (e.g. solo, konsertmästare), optional photo and Q&A profile | Drives the member list and "Möt våra musiker". See *Members*. |
| `testimonials` | quote, author, author role, date | "Sagt om oss". |
| `videos` | title, YouTube ID, composer, date | "Filmklipp". |
| `galleries` | title, date, images | "Bilder". |
| `press` | press releases (title, date, file/body), press images with photographer credit | |
| `sponsors` | name, logo, link | Footer and sponsor page. |
| `pages` | single pages: about, join, booking, contact, English | Free-form Markdown. |
| `settings` | contact email, phone, postal address, social links | One file, used by footer. |

## Site structure

Every page in Swedish and English (see *Languages*).

- **Hem** — next concert, upcoming performances, a member spotlight, latest
  video, testimonials, news.
- **Konserter** — upcoming and past concerts; one page per concert.
- **Tävlingar** — history and results for SM, EM, VM; one page per event.
- **Om oss** — history and profile, conductor, **member list by section**,
  member spotlights.
- **Bli medlem** — rehearsals (Mondays in Uppsala), how to audition/join,
  which instruments are needed.
- **Boka oss** — booking the orchestra for events.
- **Media** — videos, photo galleries, press (releases and press images).
- **Nyheter** — news and announcements.
- **Sponsorer** — sponsors and supporters.
- **Kontakt** — email, phone, postal address, social links.

## What the current site has

Surveyed 2026-11-25. Everything below should carry over:

- Navigation: Hem, Konserter, Tävlingar, Om oss (with Bilder, Filmklipp),
  Sponsorer, Kontakt, Press, English.
- Home page sections: next concert, upcoming performances, "Möt våra musiker"
  (member Q&A profiles), about, video clips, "Sagt om oss" (quotes from
  adjudicators, conductors, composers).
- Concert archive back to at least 2024; one page per concert.
- Competition pages: SM 2001, 2002, 2004, 2017, 2018, 2019, 2023; VM 2017;
  EM 2018, 2023, 2024.
- Member list (`/orkestermedlemmar/`) grouped by instrument, last updated 2022.
- Press page with press releases (2018–2019) and downloadable press photos.
- Video page of YouTube recordings; a photo page.
- English page with testimonials.
- Footer: contact email and phone, postal address, Facebook and Instagram,
  sponsors.
- Conductor-search announcement linking to a Google Form.

Problems to fix in the move:

- Stale content: member list from 2022; the competitions page says the EM
  2020 trip is upcoming; the photo page holds one 2018 gallery.
- "Kontakt" and "Sponsorer" are anchor links to the footer, not pages.
- A broken `/undefined` link on the home page.

## Members

The member list is public personal data, so:

- Publish name, instrument, and role only, with each member's consent.
  Photos and Q&A profiles are opt-in per member.
- Keep the list current — a list that is years out of date is worse than none.
- **Later, maybe:** generate the list from Orkestra, which already holds
  members and sections. Not designed for now; the `members` collection is
  kept simple enough that an export could replace it.

## Forms

Static hosting has no server to receive a form post. Options, simplest first:

1. `mailto:` links for contact and booking.
2. Embedded or linked Google Forms, as already used for the conductor search.
3. A form service (e.g. Formspree) or a small serverless function, if a styled
   on-site form is needed.

**Proposed:** 1 and 2.

## Migration

**Deferred** until the core pages are in place. It starts with an inventory
of the current site (the WordPress sitemap lists ~140 posts and ~20 pages:
concerts back to 2015, ~45 member profiles from 2018, competition pages, news,
ticket notices, and leftover test pages), and a keep / rework / drop decision
per group. The intent is to clean up rather than carry everything over.

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
color, typography, logo, and spacing. The `ubs-brand` skill in
`.claude/skills/` still points at Orkestra's paths (`priv/static/css/input.css`,
`src/orkestra/pages/`, the `tailwind` skill); adapt it once the stack and
layout here are fixed.

The profile is written for an app UI. A public site will likely need more:
image treatment, hero layouts, a wider type scale for display headings. Extend
the profile first, then the code.

## Open questions

- Hosting: GitHub Pages, or Cloudflare Pages for preview deploys per PR?
- Ticketing: always an external link (UKK, Tickster …), or anything on-site?
- Newsletter or calendar feed (iCal) for upcoming concerts?
- Analytics: none, or a cookie-free option (e.g. Plausible, Cloudflare Web
  Analytics)?

## Milestones

1. **Core pages** — Gleam generator, profile tokens, layout, both languages;
   home, about (with member list), join, booking, contact, concerts, news.
   Placeholder content; deployed to a preview URL.
2. **CMS** — Sveltia at `/admin` with the core collections, GitHub auth
   working.
3. **Migration** — inventory, select, and migrate content; members give
   consent.
4. **Launch** — redirects, DNS switch, retire WordPress.
5. **Later** — Orkestra integration for members and/or concerts.
