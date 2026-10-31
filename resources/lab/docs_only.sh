#!/bin/bash
# docs_only.sh <base-commit> <head-commit>
#
# Exit 0 when every file changed between the two commits is documentation,
# exit 1 otherwise. Anything uncertain counts as a code change, so the safe
# default is always "deploy".
#
# Documentation = any *.md file, anything under docs/, LICENSE, .gitignore, .gitattributes
set -u

base="${1:-}"
head="${2:-HEAD}"

if [ -z "$base" ] || ! git cat-file -e "${base}^{commit}" 2>/dev/null; then
  echo "docs-only check: no previous successful build to compare with - treating as a code change"
  exit 1
fi
if ! git cat-file -e "${head}^{commit}" 2>/dev/null; then
  echo "docs-only check: unknown head commit '$head' - treating as a code change"
  exit 1
fi
if ! git merge-base --is-ancestor "$base" "$head" 2>/dev/null; then
  echo "docs-only check: history was rewritten since the last successful build - treating as a code change"
  exit 1
fi

files=$(git diff --name-only "$base" "$head")
if [ -z "$files" ]; then
  echo "docs-only check: no files changed (manual rebuild) - treating as a code change"
  exit 1
fi

code=$(printf '%s\n' "$files" | grep -Ev '(^|/)[^/]+\.md$|^docs/|^LICENSE$|^\.gitignore$|^\.gitattributes$' || true)
if [ -z "$code" ]; then
  echo "docs-only check: only documentation changed:"
  printf '%s\n' "$files" | sed 's/^/  /'
  exit 0
fi

echo "docs-only check: code changed:"
printf '%s\n' "$code" | sed 's/^/  /'
exit 1
