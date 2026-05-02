#!/bin/bash
# deploy.sh - Apply all Kubernetes manifests in the correct order
# Usage: ./deploy.sh

set -e  # exit immediately on any error

NAMESPACE="cloud-virt"
ENV_FILE=".env"
GITHUB_USER="j33r0"
GHCR_SERVER="ghcr.io"

echo "Creating namespace..."
kubectl apply -f namespace.yaml

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: ${ENV_FILE} not found. Copy .env.example to .env and fill it in."
  exit 1
fi

if ! command -v envsubst >/dev/null 2>&1; then
  echo "ERROR: envsubst is required but not installed. Install gettext-base (or gettext)."
  exit 1
fi

set -a
source "$ENV_FILE"
set +a


echo "Creating app-secrets from ${ENV_FILE}..."
kubectl create secret generic app-secrets \
  --from-env-file="$ENV_FILE" \
  --namespace="$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Creating ghcr.io pull secret..."
if [ -z "$GITHUB_PAT" ]; then
  echo "ERROR: GITHUB_PAT environment variable is not set."
  echo "Run: export GITHUB_PAT=your_token_here"
  exit 1
fi
kubectl create secret docker-registry ghcr-pull-secret \
  --docker-server="$GHCR_SERVER" \
  --docker-username="$GITHUB_USER" \
  --docker-password="$GITHUB_PAT" \
  --namespace="$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -


echo "Applying ConfigMap..."
kubectl apply -f configmap.yaml


echo "Applying deployments..."
kubectl apply -f api-deployment.yaml
kubectl apply -f worker-deployment.yaml
kubectl apply -f frontend-deployment.yaml


echo "Applying services..."
kubectl apply -f services.yaml


echo "Applying ingress..."
envsubst < ingress.yaml | kubectl apply -f -

echo ""
echo "Done. Waiting for pods to become ready..."
kubectl rollout status deployment/api -n "$NAMESPACE"
kubectl rollout status deployment/worker -n "$NAMESPACE"
kubectl rollout status deployment/frontend -n "$NAMESPACE"

echo ""
echo "All deployments ready. Current state:"
kubectl get all -n "$NAMESPACE"