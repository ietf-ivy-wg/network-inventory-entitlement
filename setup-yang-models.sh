#!/usr/bin/env bash
set -euo pipefail

MODELS_DIR="${MODELS_DIR:-yang/models}"
YANG_REPO_URL="${YANG_REPO_URL:-https://github.com/YangModels/yang.git}"

if [ -d "$MODELS_DIR/.git" ]; then
  echo "Updating $MODELS_DIR"
  git -C "$MODELS_DIR" fetch --depth 10 origin main
  git -C "$MODELS_DIR" checkout main
  git -C "$MODELS_DIR" pull --ff-only
else
  echo "Cloning $YANG_REPO_URL into $MODELS_DIR"
  mkdir -p "$(dirname "$MODELS_DIR")"
  git clone --depth 10 -b main "$YANG_REPO_URL" "$MODELS_DIR"
fi
