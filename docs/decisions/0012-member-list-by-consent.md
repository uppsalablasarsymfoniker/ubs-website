# 0012. Members listed only with consent

Status: Accepted · 2026-11-25

## Context

The member list is public personal data. The current site's list dates from
2022 and nobody has consented to it.

## Decision

Publish name, section, and an optional role, only for members who have
agreed. Photos and profiles are opt-in and come later. A list years out of
date is worse than none, so the page shows no list until it is filled in.
`members.toml` stays simple enough that an export from Orkestra could replace
it.
