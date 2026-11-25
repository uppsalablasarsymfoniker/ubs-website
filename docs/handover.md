# Handover

For a new session picking up the UBS website. Read this, then `CLAUDE.md`
(working rules) and `docs/plan.md` (requirements, decisions, and status).
State as of 2026-11-26.

## Where things stand

- **Milestone 1, core pages: done.** Live on the preview at
  https://uppsalablasarsymfoniker.github.io/ubs-website/, deployed from
  `main` of https://github.com/uppsalablasarsymfoniker/ubs-website (public;
  GitHub Pages on the free plan requires it).
- **Next: milestone 2, the CMS** (Sveltia at `/admin`). Its "Sign in with
  GitHub" needs a Cloudflare Worker, and who owns UBS's Cloudflare account
  is the one open question. The CMS config can be written and tested with
  personal-token sign-in before that — see *Milestone 2* below.
- Milestones 3 (migration), 4 (launch), and 5 (later) are not started.

## Run it

```sh
gleam test                     # 29 tests, includes loading the real content/
gleam run build                # writes dist/, runs Tailwind (pinned in gleam.toml)
python3 -m http.server 8000 -d dist   # preview at http://localhost:8000
```

`SITE_URL` sets the public address and base path; unset, the build targets
`http://localhost:8000`. To preview the GitHub Pages path locally, build with
`SITE_URL=http://localhost:8000/ubs-website` and serve `dist/` under that path.

## How the code is organised

The layout follows Hayleigh Thompson's `hayleigh.dev` (the user chose it
deliberately — don't flag it as grouping by design pattern):

| Module | Job |
|---|---|
| `src/ubs_website.gleam` | `gleam run build` entry point; prints errors and exits 1 |
| `build.gleam` | Clears `dist/`, copies `assets/`, renders every route, writes 404, sitemap, robots, CSS |
| `error.gleam` | The single `Error` type; every content variant names the file |
| `site.gleam` | `SITE_URL`, base path, analytics token, build date |
| `route.gleam` | Every route's path in both languages; `href`, `url`, `asset` add the base path |
| `data/entry.gleam` | Reads `+++` TOML front matter + Markdown (`mork`), TOML data files, collections of `<slug>.sv.md` / `.en.md` |
| `data/{page,concert,news,member,settings,content}.gleam` | The content types and `content.load` |
| `data/language.gleam` | `Language`, `pick` for UI strings, `with_fallback` for optional English |
| `view/document.gleam` | HTML shell, header, footer, 404, Swedish-fallback helpers |
| `view/{page,concert,news,member,date}.gleam` | Page views |
| `meta/sitemap.gleam` | `sitemap.xml` (plain strings — Lustre elements put entries in the XHTML namespace) and `robots.txt` |
| `src/app.css` | Tailwind input: profile tokens in `@theme`, fonts, `prose`, `label-type` |

## Rules that are easy to break

- **Gleam CLI only** for project and dependency changes (`gleam add`, not
  editing `gleam.toml`). Small commits straight on `main`, Conventional
  Commits. See `CLAUDE.md`.
- **No `let assert` or `panic` outside `test/`.** Content problems return an
  `error.Error` naming the file, so an editor can fix them from the CI log.
- **Every internal link through `route.href` / `route.asset`.** A literal
  `"/konserter/"` breaks on the preview, which lives under `/ubs-website/`.
- **Every UI string through `language.pick(swedish:, english:)`** — the
  labelled arguments make a missing translation a compile error.
- **`lang="sv"` only on Swedish content text** (title, summary, body) on an
  English page, never on the wrapping article.
- **Match all variants** of our own types; no `_ ->` catch-alls.
- **Brand:** use the theme tokens (`bg-primary`, `text-muted`, …), never hex;
  Playfair (`font-display`, and every `h1`–`h6` by default) only at 20px and
  up — add `font-body` to small headings. The `ubs-brand` and `tailwind`
  skills in `.claude/skills/` hold the rules; `docs/ubs-profile.html` is the
  source of truth.
- **Spacing:** the profile's 4px scale (Tailwind steps 1–6, 8, 10, 12, 16);
  no fractional steps or arbitrary pixel values.

## Tooling in the repo

- `.claude/agents/gleam-reviewer.md` — run it before committing Gleam work.
  If the session did not start in this folder, the agent type is not
  registered: run a general-purpose agent and tell it to follow that file.
- `.claude/hooks/gleam-format.sh` — formats `.gleam` files after each edit.
- `.mcp.json` — the `gleam_packages` MCP server for Hex package docs; loads
  when a session starts in this folder.
- The global `gleam-conventions` skill (`~/.claude/skills/`) mirrors
  https://gleam.run/documentation/conventions-patterns-and-anti-patterns/,
  with the guide's section names.

## Known quirks

- **Deploy flake:** the deploy step sometimes fails with "No artifacts named
  github-pages were found" although the upload worked. Re-run it:
  `gh run rerun <id>`. Seen twice in the first runs; the action versions are
  already current.
- **Tailwind** is downloaded by `glailglind` on first build into
  `build/bin/`; the version is pinned under `[tools.tailwind]` in
  `gleam.toml`.
- **Nested captures** like `list.any(xs, string.ends_with(file, f(_)))` are
  invalid Gleam; `gleam format` will not fix them. Use an explicit `fn`.
- **Collections reject unknown files:** anything in `content/concerts/` or
  `content/news/` not named `<slug>.sv.md` / `<slug>.en.md` fails the build.
  Hidden files (`.DS_Store`) are ignored.

## Milestone 2: the CMS

Everything is decided in `docs/plan.md` (*CMS* and *Sign-in*). To do:

1. `assets/admin/index.html` loading Sveltia from
   `https://unpkg.com/@sveltia/cms/dist/sveltia-cms.js` (unversioned, as its
   docs recommend; no `type="module"`).
2. `assets/admin/config.yml`: GitHub backend for
   `uppsalablasarsymfoniker/ubs-website`, `i18n` with `multiple_files`,
   locales `[sv, en]`, and the five collections exactly as the plan lists
   them. The field names must match what the Gleam code reads:
   - pages: `title`, `summary`, body — files `content/pages/<page>.{{locale}}.md`
   - concerts: `title`, `summary`, body (translatable, `required: [sv]`);
     `performances` (list of datetimes), `venue`, `ticket_url`, `image`
     (`i18n: duplicate`); `format: toml-frontmatter`
   - news: `title`, `summary`, body; `date`, `image`
   - members: `content/members.toml`, list `members` of `name`, `section`
     (select of the keys in `data/member.gleam`), `role`
   - settings: `content/settings.toml`: `email`, `phone`, `postal_address`,
     `facebook`, `instagram`
   - media: `assets/images/uploads`, public `/images/uploads`, WebP
     transformation (max 2000px, quality 85)
3. Test with token sign-in: edit an entry in the CMS, and check that the
   commit it makes builds (the front matter it writes must parse).
4. Once the Cloudflare account exists, follow the five setup steps under
   *Sign-in* in the plan, and set `CLOUDFLARE_ANALYTICS_TOKEN`.

## Waiting on the board

- Review the new join and booking text, and every English translation.
- Confirm the phone number and postal address before adding them to
  `content/settings.toml` (the current site lists a board member's own).
- The real date of the conductor-search news (dated 2026-11-01 for now).
- Members' consent, then fill in `content/members.toml`.
