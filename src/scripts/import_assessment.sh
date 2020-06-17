#!/usr/bin/env bash

# import_assessment.sh ASSESSMENT_FILE

# This script simplifies the process of importing an assessment JSON file
# into the GoPhish server running in the local Docker composition.

set -o nounset
set -o pipefail

if [ $# -ne 1 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]
then
    echo "Usage: import_assessment.sh ASSESSMENT_FILE"
    exit 255
fi

ASSESSMENT_FILE=$1
ASSESSMENT_FILE_BASE=$(basename "$ASSESSMENT_FILE")
ASSESSMENT_FILE_DIR=$(readlink -f "$ASSESSMENT_FILE" | xargs dirname)

GOPHISH_COMPOSITION="/var/pca/pca-gophish-composition/docker-compose.yml"
GOPHISH_URL="https://gophish:3333"
COMPLETE_CAMPAIGN_SCRIPT="/var/pca/pca-gophish-composition/src/scripts/complete_campaign.sh"

# Fetch GoPhish API key
API_KEY=$(docker-compose -f "$GOPHISH_COMPOSITION" exec -T gophish get-api-key)
api_key_rc="$?"
if [ "$api_key_rc" -ne 0 ]
then
  echo "ERROR: Failed to obtain GoPhish API key from Docker composition."
  echo "Exiting without importing."
  exit 1
fi

# Run gophish-import in the Docker composition
docker-compose -f "$GOPHISH_COMPOSITION" run --rm \
  --volume "$ASSESSMENT_FILE_DIR":/home/cisa gophish-tools \
  gophish-import "$ASSESSMENT_FILE_BASE" "$GOPHISH_URL" "$API_KEY"
import_rc="$?"
if [ "$import_rc" -eq 0 ]
then
  echo "Assessment successfully imported from $ASSESSMENT_FILE!"
  echo ""
else
  echo "ERROR: Assessment import from $ASSESSMENT_FILE failed!"
  exit $import_rc
fi

# TODO - REMOVE THIS TEMP HACK
ASSESSMENT_FILE="$1.json"

# Schedule each campaign to be completed at the specified time
# via the "at" command
for campaign in $(jq '.campaigns | keys | .[]' "$ASSESSMENT_FILE"); do
  campaign_name=$(jq -r ".campaigns[$campaign].name" "$ASSESSMENT_FILE")
  end_date=$(jq -r ".campaigns[$campaign].complete_date" "$ASSESSMENT_FILE")

  end_date_in_at_format=$(date -d "$end_date" +"%Y%m%d%H%M.%S")

  echo "$COMPLETE_CAMPAIGN_SCRIPT $campaign_name" | \
    at -M -t "$end_date_in_at_format"
  schedule_rc="$?"
  if [ "$schedule_rc" -eq 0 ]
  then
    echo "Successfully scheduled campaign $campaign_name to complete at $end_date."
  else
    echo "ERROR: Failed to schedule campaign $campaign_name to complete at $end_date!"
    exit $schedule_rc
  fi
done
echo "All campaigns successfully scheduled for completion."
