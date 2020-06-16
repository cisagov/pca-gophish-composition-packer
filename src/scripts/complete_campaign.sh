#!/usr/bin/env bash

# complete_campaign.sh CAMPAIGN_ID

# This script simplifies the process of completing a campaign on the
# GoPhish server running in the local Docker composition.

set -o nounset
set -o pipefail

if [ $# -ne 1 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]
then
    echo "Usage: complete_campaign.sh CAMPAIGN_ID"
    exit 255
fi

CAMPAIGN_ID=$1

GOPHISH_COMPOSITION="/var/pca/pca-gophish-composition/docker-compose.yml"
GOPHISH_URL="https://gophish:3333"

# Fetch GoPhish API key
API_KEY=$(docker-compose -f "$GOPHISH_COMPOSITION" exec -T gophish get-api-key)
api_key_rc="$?"
if [ "$api_key_rc" -ne 0 ]
then
  echo "ERROR: Failed to obtain GoPhish API key from Docker composition."
  echo "Exiting without importing."
  exit 1
fi

# Run gophish-complete in the Docker composition
docker-compose -f "$GOPHISH_COMPOSITION" run --rm \
  gophish-tools gophish-complete "--auto=$CAMPAIGN_ID" "$GOPHISH_URL" "$API_KEY"
complete_rc="$?"
if [ "$complete_rc" -eq 0 ]
then
  echo "GoPhish campaign $CAMPAIGN_ID successfully completed!"
else
  echo "ERROR: Failed to complete GoPhish campaign $CAMPAIGN_ID!"
  exit $complete_rc
fi
