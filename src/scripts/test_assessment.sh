#!/usr/bin/env bash

# test_assessment.sh ASSESSMENT_ID

# This script simplifies the process of sending test emails for an
# assessment in the GoPhish server running in the local Docker composition.

set -o nounset
set -o pipefail

if [ $# -ne 1 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]
then
    echo "Usage: test_assessment.sh ASSESSMENT_ID"
    exit 255
fi

ASSESSMENT_ID=$1

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

# Run gophish-test in the Docker composition
docker-compose -f "$GOPHISH_COMPOSITION" run --rm \
  gophish-tools gophish-test "$ASSESSMENT_ID" "$GOPHISH_URL" "$API_KEY"
test_rc="$?"
if [ "$test_rc" -eq 0 ]
then
  echo "Assessment $ASSESSMENT_ID test succeeded!"
else
  echo "ERROR: Assessment $ASSESSMENT_ID test failed!"
  exit $test_rc
fi
