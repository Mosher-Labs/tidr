#!/bin/bash

payload=$(jq -c . test/fixtures/zoom_recording_payload.json)

echo -n "$payload"

timestamp=$(date +%s)
string_to_sign="$timestamp$payload"

signature="v0=$(echo -n "$string_to_sign" | openssl dgst -sha256 -hmac "$ZOOM_WEBHOOK_SECRET_TOKEN" -binary | base64)"

curl -X POST http://localhost:3000/webhooks/zoom \
  -H "Content-Type: application/json" \
  -H "x-zm-request-timestamp: $timestamp" \
  -H "x-zm-signature: $signature" \
  -d "$payload"
