#!/bin/bash
PROJECT_ID=cabral-apigee
LB_IP=10.100.0.52

# show the config first then...
kubectl apply -f apigee-configs/

# assumes apigeecli is installed
TOKEN=$(gcloud auth print-access-token)

echo "Creating Developer"
apigeecli developers create --user gkeuser --email gkeuser@acme.com --first GKE --last User --org "$PROJECT_ID" --token "$TOKEN"

echo "Creating Developer Apps"
apigeecli apps create --name store-app --email gkeuser@acme.com --prods store-product --org "$PROJECT_ID" --token "$TOKEN" --disable-check

API_KEY=$(apigeecli apps get --name store-app --org "$PROJECT_ID" --token "$TOKEN" --disable-check | jq ."[0].credentials[0].consumerKey" -r)
export API_KEY

echo "From a VM in the private network, execute: "
echo "curl -i -H \"host: store.example.com\" ${LB_IP}/items"
echo 'Then, execute...'
echo "curl -i -H \"host: store.example.com\" ${LB_IP}/items -H \"x-api-key: ${API_KEY}\""
echo "Then, execute..."
echo "curl -i -H \"host: store.example.com\" ${LB_IP}/items -H \"x-api-key: ${API_KEY}\" -H \"env: canary\""
echo "Then, execute..."
echo "curl -i -H \"host: store.example.com\" ${LB_IP}/picanha -H \"x-api-key: ${API_KEY}\""
echo 'Then, execute...'
echo "for i in \$(seq 0 7); do curl -i -H \"host: store.example.com\" ${LB_IP}/items -H \"x-api-key: ${API_KEY}\"; done"
echo "Then show Apigee analytics"