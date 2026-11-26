# 0006. Swedish first, English throughout

Status: Accepted · 2026-11-25

## Context

The orchestra is Swedish; visitors include English speakers. Concerts and
news are written in Swedish and not always translated.

## Decision

Swedish at the site root, English under `/en/`. Translations are separate
files side by side (`<slug>.sv.md`, `<slug>.en.md`). General pages require
both languages; concerts and news require Swedish only, and an English page
without a translation shows the Swedish text marked `lang="sv"` and labelled
"In Swedish". Language-neutral fields are read from the Swedish file. Every
route exists in both languages, so the language switch always works.
