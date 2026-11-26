---
name: decision-record
description: This skill should be used when a choice about the UBS website is made, proposed, or changed — choosing a technology, service, design rule, content policy, or process — or when the user says "record a decision", "we decided", "let's go with", "change the decision on", or resolves an issue labelled `decision`. Writes or supersedes a numbered record in docs/decisions/ and keeps docs/plan.md and the GitHub issue in step.
---

# Decision records

`docs/decisions/` holds one short file per decision: why the site is the way
it is. `docs/plan.md` says *what* the site is and links each choice to its
record. Records are history: never rewrite an accepted record's reasoning.

## Record a new decision

1. Next number: one more than the highest `NNNN-*.md` in `docs/decisions/`.
2. Copy `docs/decisions/0000-template.md` to `NNNN-short-slug.md`.
3. Fill it in, keeping the template's shape — title, status line, Context,
   Decision — and nothing more. A few sentences each. Name what was rejected
   and why, in the Decision.
4. Status line: `Status: Proposed · YYYY-MM-DD` until the user (or the board,
   through the user) agrees; then `Accepted`. The date is the day of the
   status change.
5. Update `docs/plan.md` to describe the result, with a link
   `([NNNN](decisions/NNNN-short-slug.md))` where the choice shows.
6. If an issue labelled `decision` asked for it, close it from the commit:
   `docs: record decision NNNN, <title>` with `Closes #N` in the body.

## Change or reverse a decision

Write a new record as above, then:

- New record's status line: `Status: Accepted · YYYY-MM-DD · Supersedes [MMMM](MMMM-old-slug.md)`.
- Old record: change only its status line, to
  `Status: Superseded by [NNNN](NNNN-new-slug.md) · YYYY-MM-DD`.
- Point the plan's link at the new record.

Proposed → Accepted, or fixing a typo or broken link, edits the record in
place; anything that changes what was decided is a new record.

## Not a decision

Routine implementation choices that the code or a commit message explains
(a class name, a refactor, a bug fix) don't get a record. The test: would
someone later ask "why is it like this?" and need more than the code to
answer?
