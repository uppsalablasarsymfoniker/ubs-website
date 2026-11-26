# 0008. GitHub Pages now, Cloudflare at launch

Status: Accepted · 2026-11-25

## Context

GitHub Pages needs nothing new but has no server redirects or custom headers,
and requires a public repository. Cloudflare has real 301 redirects, custom
headers, and preview deploys, but needs an account and an API token. Both
serve the same `dist/`, so the choice can change.

| | GitHub Pages | Cloudflare (Pages, or Workers static assets) |
|---|---|---|
| Accounts | None beyond GitHub | A Cloudflare account — needed anyway for CMS "Sign in with GitHub" |
| Deploy | `actions/deploy-pages`, no secrets | `wrangler` from Actions, with an API token secret |
| Repository | Must be public on the free plan | Public or private |
| Old WordPress URLs | No server redirects: one HTML page per old URL with a meta refresh | Real 301 redirects from a `_redirects` file |
| Headers | Fixed by GitHub | Custom headers (`_headers`), e.g. a Content Security Policy |
| Preview deploys | None; only `main` is published | A preview URL for every branch and pull request |
| Limits | 1 GB site, ~100 GB bandwidth per month (soft) | Unlimited bandwidth on static requests |
| Custom domain | A/CNAME records at One.com; free HTTPS | `www` via CNAME; the bare domain needs the DNS moved to Cloudflare; free HTTPS |
| Analytics | Bring your own | Cloudflare Web Analytics built in |

## Decision

GitHub Pages while building. Cloudflare at launch: UBS needs a Cloudflare
account for sign-in anyway ([0007](0007-sign-in-with-github.md)), and the old
WordPress URLs need real redirects.
