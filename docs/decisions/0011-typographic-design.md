# 0011. A typographic design that needs no photo

Status: Accepted · 2026-11-26

## Context

There are no recent photos of the orchestra. The brand profile was written
for an app, and its largest size (36px) gave the home page no presence.

## Decision

The design must not depend on a photo. The home page opens with the
orchestra's name in a Display size (56px, from 768px up) added to the
profile, under a brass rule. The header wraps the navigation below the logo on
narrow screens, with no JavaScript menu. A photo can be added later without a
redesign. Visual additions go into `docs/ubs-profile.html` first, then the
code.
