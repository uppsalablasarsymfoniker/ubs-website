# 0002. Sveltia CMS for board editing

Status: Accepted · 2026-11-25

## Context

Board members edit from a browser without touching code. Agents edit the
same content as plain files. A static site has no server for a CMS to run on.

## Decision

Sveltia CMS at `/admin`: a static single-page app that reads and writes the
Markdown files through the GitHub API, so every save is a commit that
triggers a rebuild. Loaded from unpkg unversioned, as its docs recommend.
Its config, `assets/admin/config.yml`, doubles as the content schema.

Edits appear after the rebuild, not instantly. Decap CMS has the same model
and config and is the fallback if Sveltia is abandoned.
