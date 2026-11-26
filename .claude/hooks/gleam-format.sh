#!/bin/bash
# Runs before `git commit` (see .claude/settings.json). Formats every Gleam
# file, because the commit command often stages its files itself
# (`git add … && git commit`), after this hook has run. Files that were
# already staged are staged again, so the commit gets the formatted version.
# Code that doesn't parse blocks the commit.
cd "$CLAUDE_PROJECT_DIR" || exit 0
[[ -f gleam.toml ]] || exit 0

if ! output=$(gleam format src test 2>&1); then
  echo "gleam format failed, so the commit was stopped:" >&2
  echo "$output" >&2
  exit 2
fi

git diff --name-only --cached --diff-filter=ACMR -- '*.gleam' |
  while read -r file; do
    git diff --quiet -- "$file" || git add -- "$file"
  done
exit 0
