#!/usr/bin/env bash
set -euo pipefail
set -x

YANG_DIR="yang"
EXAMPLES_DIR="$YANG_DIR/examples"
YANG_LIBRARY="$YANG_DIR/yang-library.json"
MODELS="yang/models"
COVERAGE_FILE="$(mktemp)"
COVERAGE_OUTPUT="$YANG_DIR/coverage.txt"

YANGSON_COVERAGE_PACKAGE="${YANGSON_COVERAGE_PACKAGE:-git+https://github.com/jccardonar/yangson-coverage.git@main}"

if ! command -v uvx >/dev/null 2>&1; then
  echo "ERROR: uvx is required. Install uv first: https://docs.astral.sh/uv/"
  exit 1
fi

trap 'rm -f "$COVERAGE_FILE"' EXIT

./setup-yang-models.sh

YANG_PATHS=(
  "$YANG_DIR"
  "$YANG_DIR/examples"
  "$MODELS/standard/ietf/RFC"
  "$MODELS/experimental/ietf-extracted-YANG-modules"
  "$MODELS/standard/ieee/published/802.1"
)

examples=()
while IFS= read -r -d '' file; do
  examples+=("$file")
done < <(find "$EXAMPLES_DIR" -type f -name 'valid-*.json' -print0 | sort -z)

if [ "${#examples[@]}" -eq 0 ]; then
  echo "ERROR: no valid-*.json examples found under $EXAMPLES_DIR"
  exit 1
fi

uvx --from "$YANGSON_COVERAGE_PACKAGE" yangson_coverage reset_coverage \
  -C "$COVERAGE_FILE"

uvx --from "$YANGSON_COVERAGE_PACKAGE" yangson_coverage run \
  -y "$YANG_LIBRARY" \
  -p "${YANG_PATHS[@]}" \
  -i "${examples[@]}" \
  -C "$COVERAGE_FILE"

uvx --from "$YANGSON_COVERAGE_PACKAGE" yangson_coverage show_coverage \
  -y "$YANG_LIBRARY" \
  -p "${YANG_PATHS[@]}" \
  -C "$COVERAGE_FILE" \
  | tee "$COVERAGE_OUTPUT"
