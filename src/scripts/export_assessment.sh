#!/usr/bin/env bash

# export_assessment.sh ASSESSMENT_ID

# This script simplifies the process of exporting assessment data from the
# GoPhish server running in the local Docker composition to a JSON file.

set -o nounset
set -o pipefail

if [ $# -ne 1 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]
then
    echo "Usage: export_assessment.sh ASSESSMENT_ID"
    exit 255
fi

ASSESSMENT_ID=$1

GOPHISH_COMPOSITION="/var/pca/pca-gophish-composition/docker-compose.yml"
GOPHISH_URL="https://gophish:3333"
GOPHISH_WRITABLE_DIR="/var/pca/pca-gophish-composition/data"

# Fetch GoPhish API key
API_KEY=$(docker-compose -f "$GOPHISH_COMPOSITION" exec -T gophish get-api-key)
api_key_rc="$?"
if [ "$api_key_rc" -ne 0 ]
then
  echo "ERROR: Failed to obtain GoPhish API key from Docker composition."
  echo "Exiting without importing."
  exit 1
fi

# Run gophish-export in the Docker composition
docker-compose -f "$GOPHISH_COMPOSITION" run --rm \
  --volume "$GOPHISH_WRITABLE_DIR":/home/cisa \
  gophish-tools gophish-export "$ASSESSMENT_ID" "$GOPHISH_URL" "$API_KEY"
export_rc="$?"
if [ "$export_rc" -eq 0 ]
then
  echo "Assessment data successfully exported to: $GOPHISH_WRITABLE_DIR/data_$ASSESSMENT_ID.json"
else
  echo "ERROR: Failed to export GoPhish assessment $ASSESSMENT_ID data!"
  exit $export_rc
fi
