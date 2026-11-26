# 0016. Cloudflare hosting now, on Workers static assets

Status: Accepted · 2026-11-26 · Supersedes [0008](0008-github-pages-then-cloudflare.md)

## Context

UBS now has a Cloudflare account, which the CMS sign-in Worker needs anyway.
Waiting for launch to move would mean switching hosts and testing redirects,
headers, and the deploy all at once.

## Decision

Host on Cloudflare from now on, at
`website.uppsalablasarsymfoniker.workers.dev` until the domain moves.
GitHub Actions builds the site and deploys `dist/` with wrangler as Workers
static assets, which Cloudflare now recommends over Pages for a static folder.
The deploy needs a `CLOUDFLARE_API_TOKEN` secret in the repository. GitHub
Pages is switched off.
