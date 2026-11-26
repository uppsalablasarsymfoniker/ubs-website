# 0003. Markdown with TOML front matter, not Djot

Status: Accepted · 2026-11-25

## Context

Djot is cleaner to parse, and Gleam has a good Djot parser (`jot`). Sveltia's
rich-text editor reads and writes Markdown only.

## Decision

Content is Markdown, parsed with `mork`, with TOML front matter (`+++`),
parsed with `tom`. Sveltia writes it with `format: toml-frontmatter`.
Storing Djot would have meant a plain text box for editors.
