#!/usr/bin/env bash

JSON_KEY_ID=$(cat /root/.ssh/jarvis-edml.json | jq -r '.private_key_id')

gcloud iam service-accounts keys delete ${JSON_KEY_ID} \
 --iam-account jarvis@event-driven-ml.iam.gserviceaccount.com \
 --quiet
