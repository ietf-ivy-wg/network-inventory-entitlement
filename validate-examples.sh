#!/bin/bash
set -x
set -e

./setup-yang-models.sh

# Specify the directory and the command
DIRECTORY="yang/examples"
MODELS="yang/models"
IANA_HARDWARE="$MODELS/standard/ietf/RFC/iana-hardware@2018-03-13.yang"

if [ ! -f "$IANA_HARDWARE" ]; then
  echo "Could not find $IANA_HARDWARE"
  exit 1
fi

COMMAND="yanglint \
  -p . \
  -p yang \
  -p yang/examples \
  -p $MODELS/standard/ietf/RFC \
  -p $MODELS/experimental/ietf-extracted-YANG-modules \
  -p $MODELS/standard/ieee/published/802.1 \
  $IANA_HARDWARE \
  yang/ietf-entitlement-inventory.yang"

# Command for capability extension example (requires additional modules)
COMMAND_EXT="yanglint \
  -p . \
  -p yang \
  -p yang/examples \
  -p $MODELS/standard/ietf/RFC \
  -p $MODELS/experimental/ietf-extracted-YANG-modules \
  -p $MODELS/standard/ieee/published/802.1 \
  $IANA_HARDWARE \
  yang/ietf-entitlement-inventory.yang \
  yang/examples/example-capability-framework.yang \
  yang/examples/example-capability-extension.yang"

# Loop through all valid JSON files in the directory
for FILE in "$DIRECTORY"/valid-*.json
do
  # If no files match, skip cleanly
  [ -f "$FILE" ] || continue

  # Use extended command for capability extension JSON
  if [[ "$FILE" == *"valid-example8-capability-extension.json" ]]; then
    $COMMAND_EXT "$FILE"
  else
    $COMMAND "$FILE"
  fi
done
