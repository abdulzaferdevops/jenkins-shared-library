#!/bin/bash
# image_ref.sh <repository> <reference>
#
# Exit 0 only for an immutable reference to the given repository:
#   <repository>@sha256:<64 lowercase hex characters>
# Tags, other registries, other repositories and malformed digests are refused.
set -u

repo="${1:-}"
ref="${2:-}"

if [ -z "$repo" ] || [ -z "$ref" ]; then
  echo "image check: usage: image_ref.sh <repository> <reference>"
  exit 2
fi

case "$ref" in
  "$repo@sha256:"*) ;;
  *)
    echo "image check: refused '$ref' - must be $repo@sha256:<digest>"
    exit 1
    ;;
esac

digest="${ref#"$repo@sha256:"}"
if [[ ! "$digest" =~ ^[0-9a-f]{64}$ ]]; then
  echo "image check: refused '$ref' - digest must be 64 lowercase hex characters"
  exit 1
fi

echo "image check: accepted sha256:$digest"
exit 0
