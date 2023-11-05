#!/bin/bash

# Get environment variables
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}"
BUCKET_NAME="${BUCKET_NAME}"
FILE_NAME="${FILE_NAME}"
CONFIG_MAP_NAME="${CONFIG_MAP_NAME}"
COLLECTOR_NAME="${COLLECTOR_NAME}"
NAMESPACE="${NAMESPACE}"

# Download YAML file from S3
aws s3 cp s3://$BUCKET_NAME/$FILE_NAME .

# Create or update the ConfigMap
#kubectl create configmap $CONFIG_MAP_NAME --from-file=$FILE_NAME -n $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

kubectl patch opentelemetrycollector $COLLECTOR_NAME -n $NAMESPACE --type=merge --patch-file $FILE_NAME

# Restart the "collector" deployment
#kubectl rollout restart deployment/$DEPLOYMENT_NAME -n $NAMESPACE

