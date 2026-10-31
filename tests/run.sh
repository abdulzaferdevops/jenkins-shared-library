#!/bin/bash
# tests/run.sh - tests for the shell helpers in resources/lab/.
# Uses only bash and git. Exit code is the number of failed tests (0 = all passed).
set -u

ROOT=$(cd "$(dirname "$0")/.." && pwd)
DOCS="$ROOT/resources/lab/docs_only.sh"
IMG="$ROOT/resources/lab/image_ref.sh"
pass=0
fail=0

check() {  # check <description> <expected exit> <command...>
  local desc="$1" expected="$2"
  shift 2
  "$@" >/dev/null 2>&1
  local actual=$?
  if [ "$actual" -eq "$expected" ]; then
    pass=$((pass + 1)); printf '  ok    %s\n' "$desc"
  else
    fail=$((fail + 1)); printf '  FAIL  %s (expected exit %s, got %s)\n' "$desc" "$expected" "$actual"
  fi
}

# ---------- docs_only.sh ----------
echo "docs_only.sh"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cd "$work" || exit 1
git init -q -b main .
g() { git -c user.name=test -c user.email=test@example.invalid "$@"; }

mkdir -p site docs scripts
echo "<h1>v1</h1>" > site/index.html
echo "# readme" > README.md
g add . && g commit -q -m "initial"
c0=$(git rev-parse HEAD)

echo "more" >> README.md && g commit -qam "readme only";              c_readme=$(git rev-parse HEAD)
echo "img" > docs/pipeline.png && g add . && g commit -qm "docs dir"; c_docs=$(git rev-parse HEAD)
echo "<h1>v2</h1>" > site/index.html && g commit -qam "site change";  c_site=$(git rev-parse HEAD)
echo "notes" > scripts/NOTES.md && g add . && g commit -qm "nested md"; c_nested=$(git rev-parse HEAD)
echo "x" > scripts/run.sh && echo "y" >> README.md && g add . && g commit -qm "mixed"; c_mixed=$(git rev-parse HEAD)
echo "markdown.sh" > scripts/markdown.sh && g add . && g commit -qm "md-like name"; c_mdlike=$(git rev-parse HEAD)

check "README.md only                 -> docs-only"         0 bash "$DOCS" "$c0" "$c_readme"
check "README + docs/ (two commits)   -> docs-only"         0 bash "$DOCS" "$c0" "$c_docs"
check "site file changed              -> code"              1 bash "$DOCS" "$c_docs" "$c_site"
check "range containing a code change -> code"              1 bash "$DOCS" "$c0" "$c_site"
check "nested *.md file               -> docs-only"         0 bash "$DOCS" "$c_site" "$c_nested"
check "script + README together       -> code"              1 bash "$DOCS" "$c_nested" "$c_mixed"
check "file merely named like md      -> code"              1 bash "$DOCS" "$c_mixed" "$c_mdlike"
check "no previous successful commit  -> code"              1 bash "$DOCS" "" "$c_readme"
check "unknown previous commit        -> code"              1 bash "$DOCS" "deadbeefdeadbeefdeadbeefdeadbeefdeadbeef" "$c_readme"
check "same commit (manual rebuild)   -> code"              1 bash "$DOCS" "$c_readme" "$c_readme"

g checkout -q -b rewritten "$c0"
echo "other" > README.md && g commit -qam "rewritten history"; c_other=$(git rev-parse HEAD)
check "history rewritten (not ancestor) -> code"            1 bash "$DOCS" "$c_readme" "$c_other"
cd "$ROOT" || exit 1

# ---------- image_ref.sh ----------
echo "image_ref.sh"
R="registry.example/ns/ci-labs/flask-api"
H64="781aa695d8b12b1bfc10effd5c64d9f1bcaef08078bdff301337392ed7b41e2b"
check "digest in our repository       -> accepted"          0 bash "$IMG" "$R" "$R@sha256:$H64"
check "tag instead of digest          -> refused"           1 bash "$IMG" "$R" "$R:1025693"
check "other registry                 -> refused"           1 bash "$IMG" "$R" "docker.io/library/nginx@sha256:$H64"
check "other repository, same registry -> refused"          1 bash "$IMG" "$R" "registry.example/ns/ci-labs/other@sha256:$H64"
check "repository name as prefix trick -> refused"          1 bash "$IMG" "$R" "${R}-evil@sha256:$H64"
check "truncated digest (63 chars)    -> refused"           1 bash "$IMG" "$R" "$R@sha256:${H64:0:63}"
check "uppercase hex                  -> refused"           1 bash "$IMG" "$R" "$R@sha256:$(echo "$H64" | tr 'a-f' 'A-F')"
check "shortened with an ellipsis     -> refused"           1 bash "$IMG" "$R" "…flask-api@sha256:$H64"
check "missing arguments              -> usage error"       2 bash "$IMG" "$R"

echo
echo "result: $pass passed, $fail failed"
exit "$fail"
