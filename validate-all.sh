#!/bin/bash
set -x
set -e

echo "Validating yang modules"

./setup-yang-models.sh

PYANG_INPUT='yang/ietf-entitlement-inventory.yang'
MODELS="yang/models"

YANG_PATHS="-p . \
  -p yang \
  -p yang/examples \
  -p $MODELS/standard/ietf/RFC \
  -p $MODELS/experimental/ietf-extracted-YANG-modules \
  -p $MODELS/standard/ieee/published/802.1"

pyang --ietf --max-line-length 69 $YANG_PATHS $PYANG_INPUT

# Compare canonical formatting
for orig in $PYANG_INPUT; do
  pyang --ietf --yang-line-length 69 -f yang --yang-canonical $YANG_PATHS "$orig" > /tmp/canonical.yang
  if ! diff -q "$orig" /tmp/canonical.yang; then
    echo
    echo "ERROR: $orig is not canonical."
    echo
    echo "Run this command:"
    echo
    echo "pyang $YANG_PATHS -f yang --yang-line-length 69 --yang-canonical -o \"$orig\" \"$orig\""
    echo
    exit 1
  fi
done

yanglint $YANG_PATHS yang/ietf-entitlement-inventory.yang -f yang > /dev/null
