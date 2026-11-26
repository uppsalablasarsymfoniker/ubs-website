# 0007. Editors sign in with GitHub

Status: Accepted · 2026-11-25

## Context

Sveltia needs a GitHub token that may write to the repository. Editors can
paste a personal access token, which takes minutes per editor and expires, or
use OAuth, which needs a secret that can't live in a static page.

## Decision

"Sign in with GitHub" through `sveltia-cms-auth`, a small Cloudflare Worker
on the free tier, with a GitHub App in the organisation. Editors are members
of an "editors" team with Write access. Personal tokens remain the fallback
for developers. This needs a Cloudflare account owned by UBS.
