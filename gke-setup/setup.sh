#!/bin/bash
export PROJECT_ID="cabral-apigee"
export ORG="cabral-apigee"
export ENV="dev"
export RUNTIME='https://dev.35.227.240.213.nip.io'

gcloud config set project ${PROJECT_ID}
gcloud container clusters get-credentials cabral-basic-cluster \
    --location=southamerica-east1


kubectl create namespace apigee

helm install apigee-k8s-controller \
oci://us-docker.pkg.dev/apigee-release/apigee-k8s-tooling-helm-charts/apigee-k8s-controller-milestone1-public-preview \
--version 1.1

gcloud iam service-accounts create preview-gsa

gcloud iam service-accounts add-iam-policy-binding \
preview-gsa@${PROJECT_ID}.iam.gserviceaccount.com \
--role roles/iam.workloadIdentityUser \
--member "serviceAccount:${PROJECT_ID}.svc.id.goog[apigee/preview-ksa]" # KSA is created as a part of the controller install

kubectl annotate serviceaccount preview-ksa \
--namespace apigee \
iam.gke.io/gcp-service-account=preview-gsa@${PROJECT_ID}.iam.gserviceaccount.com

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member "serviceAccount:preview-gsa@${PROJECT_ID}.iam.gserviceaccount.com" \
--role "roles/apigee.apiAdminV2"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member "serviceAccount:preview-gsa@${PROJECT_ID}.iam.gserviceaccount.com" \
--role "roles/apigee.analyticsAgent"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member "serviceAccount:preview-gsa@${PROJECT_ID}.iam.gserviceaccount.com" \
--role "roles/networkservices.serviceExtensionsAdmin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member "serviceAccount:preview-gsa@${PROJECT_ID}.iam.gserviceaccount.com" \
--role "roles/compute.networkAdmin"


mkdir apigee-remote-service-cli

wget https://github.com/apigee/apigee-remote-service-cli/releases/download/v2.1.3/apigee-remote-service-cli_2.1.3_macOS_64-bit.tar.gz

tar -xf apigee-remote-service-cli_2.1.3_macOS_64-bit.tar.gz -C apigee-remote-service-cli
 
export CLI_HOME=$PWD/apigee-remote-service-cli

TOKEN=$(gcloud auth print-access-token)
cd $CLI_HOME && ./apigee-remote-service-cli provision -t ${TOKEN} -o ${ORG} -e ${ENV} -r ${RUNTIME}  > config.yaml

kubectl apply -f config.yaml
cd ..


kubectl apply -f apigee-adapter-service.yaml
kubectl apply -f apigee-adapter-gateway.yaml