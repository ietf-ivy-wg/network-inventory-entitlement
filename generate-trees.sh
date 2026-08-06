#!/bin/bash
# Generate tree files from the YANG module
# This ensures documentation trees stay in sync with the actual model

set -euo pipefail
set -x  # print commands as they run

trap 'rc=$?; echo "::error::generate-trees.sh failed (exit=$rc) at line $LINENO: $BASH_COMMAND"; exit $rc' ERR

YANG_DIR="yang"
TREES_DIR="trees"
YANG_TREES_DIR="yang/trees"

# Paths for pyang
LOCAL_EXPERIMENTAL="/Users/camilo/Documents/Projects/drafts/bmp_yang_model/other_examples/yang/experimental"

# Where to clone if LOCAL_EXPERIMENTAL doesn't exist
YANG_REPO_DIR="${YANG_REPO_DIR:-${RUNNER_TEMP:-/tmp}/yang}"
YANG_REPO_URL="https://github.com/YangModels/yang.git"

mkdir -p "${TREES_DIR}" "${YANG_TREES_DIR}"

if [[ -d "${LOCAL_EXPERIMENTAL}" ]]; then
  echo "Using local experimental folder: ${LOCAL_EXPERIMENTAL}"
  export YANG_MODPATH="${LOCAL_EXPERIMENTAL}/ietf-extracted-YANG-modules"
  export PYANG_PATHS="-p . -p ${LOCAL_EXPERIMENTAL}"
else
  echo "Local experimental folder not found; cloning YangModels/yang into: ${YANG_REPO_DIR}"
  mkdir -p "$(dirname "${YANG_REPO_DIR}")"

  if [[ ! -d "${YANG_REPO_DIR}/.git" ]]; then
    rm -rf "${YANG_REPO_DIR}" || true
    git clone --depth 1 "${YANG_REPO_URL}" "${YANG_REPO_DIR}"
  fi

  export YANG_MODPATH="${YANG_REPO_DIR}/experimental/ietf-extracted-YANG-modules"
  export PYANG_PATHS="-p . -p ${YANG_REPO_DIR}/experimental"
fi

echo "YANG_MODPATH=${YANG_MODPATH}"
echo "PYANG_PATHS=${PYANG_PATHS}"


# Generate the full tree (already exists in yang/trees/)
echo "Generating full tree..."
pyang -f tree --tree-line-length=69 $PYANG_PATHS $YANG_DIR/ietf-entitlement-inventory.yang > $YANG_TREES_DIR/ietf-entitlement-inventory.tree

# Generate capability subtree (extract from first network-element augment only)
echo "Generating capability subtree..."
# ... Previous script
pyang -f tree --tree-line-length=69 $PYANG_PATHS $YANG_DIR/ietf-entitlement-inventory.yang 2>/dev/null | \
sed -e ':a' -e 'N' -e '$!ba' -e 's/  augment \/inv:network-inventory\/inv:network-elements\n[ \t]*\/inv:network-element:/  augment \/inv:network-inventory\/inv:network-elements\/inv:network-element:/g' | \
awk '
  # Enter the network-element augment
  /^  augment \/inv:network-inventory\/inv:network-elements\/inv:network-element:$/ {in_ne=1; next}
  # Leave on any other augment header
  /^  augment / {in_ne=0}

  # Start printing at capabilities within that augment
  in_ne && /^    \+--ro capabilities!/ {p=1}

  # Print until we leave the augment (handled above)
  in_ne && p {
    sub(/^   /,"")     # your old sed s/^   //
    print
  }
' > "$TREES_DIR/capability_tree.txt"

# Generate entitlements subtree
echo "Generating entitlements subtree..."
pyang -f tree $PYANG_PATHS $YANG_DIR/ietf-entitlement-inventory.yang 2>/dev/null | \
awk '
  # Enter the inventory-root augment
  /^  augment \/inv:network-inventory:$/ {in_inv=1; next}
  # Leave on any other augment header
  /^  augment / {in_inv=0}

  # Start printing at entitlements within that augment
  in_inv && /^    \+--ro entitlements!/ {p=1}

  in_inv && p {
    sub(/^   /,"")
    print
  }
' > "$TREES_DIR/entitlements_tree.txt"

# Generate installed-entitlements subtree (from network-element augment)
echo "Generating installed-entitlements subtree..."
pyang -f tree --tree-line-length=69 $PYANG_PATHS $YANG_DIR/ietf-entitlement-inventory.yang 2>/dev/null | \
sed -e ':a' -e 'N' -e '$!ba' -e 's/  augment \/inv:network-inventory\/inv:network-elements\n[ \t]*\/inv:network-element:/  augment \/inv:network-inventory\/inv:network-elements\/inv:network-element:/g' | \
awk '
  /^  augment \/inv:network-inventory\/inv:network-elements\/inv:network-element:$/ {in_ne=1; next}
  /^  augment / {in_ne=0}

  # start at installed-entitlements
  in_ne && /^    \+--ro installed-entitlements!/ {p=1; first=1}

  # once started, stop when we reach the next sibling at the same level
  in_ne && p && !first && /^    \+--ro / {exit}

  in_ne && p {
    sub(/^   /,"")
    print
    first=0
  }
' > "$TREES_DIR/installed_entitlments_tree.txt"

echo "Tree generation complete."
echo ""
echo "Generated files:"
ls -la $TREES_DIR/*.txt
ls -la $YANG_TREES_DIR/*.tree
