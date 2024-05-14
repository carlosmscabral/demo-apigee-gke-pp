#!/bin/bash

PROJECT_ID=cabral-apigee

# assumes apigeecli is installed
TOKEN=$(gcloud auth print-access-token)

echo "Deleting Developer Apps"
DEVELOPER_ID=$(apigeecli developers get --email gkeuser@acme.com --org "$PROJECT_ID" --token "$TOKEN" --disable-check | jq .'developerId' -r)
apigeecli apps delete --id "$DEVELOPER_ID" --name store-app --org "$PROJECT_ID" --token "$TOKEN"

echo "Deleting Developer"
apigeecli developers delete --email gkeuser@acme.com --org "$PROJECT_ID" --token "$TOKEN"

kubectl delete -f apigee-configs