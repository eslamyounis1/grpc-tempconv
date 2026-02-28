# Deployment Guide

Steps to ship the gRPC backend and Flutter web frontend to Google Cloud (Artifact Registry + GKE).

## 1. Prerequisites

- Docker daemon running locally
- gcloud authenticated to the target project (`gcloud auth login` and `gcloud config set project tempconv-485913`)
- Artifact Registry repository `tempconv` in `us-central1`
- GKE cluster configured in `kubectl config`

## 2. Build Images

From the repo root:

```bash
# adjust TAG if needed
TAG=2.0.0 \
  make backend-image frontend-image
```

This produces:
- `us-central1-docker.pkg.dev/tempconv-485913/tempconv/tempconv-backend:2.0.0`
- `us-central1-docker.pkg.dev/tempconv-485913/tempconv/tempconv-frontend:2.0.0`

## 3. Push to Artifact Registry

```bash
TAG=2.0.0 \
  make push-backend push-frontend
```

If this is your first push, ensure Docker is authenticated:

```bash
gcloud auth configure-docker us-central1-docker.pkg.dev
```

## 4. Update Kubernetes Manifests

The manifests under `k8s/` already point at the `:2.0.0` tag. If you bump the tag later, update:

- `k8s/backend-deployment.yaml`
- `k8s/frontend-deployment.yaml`

or use the helper target:

```bash
TAG=2.0.0 make deploy
```

## 5. Apply Manifests

```bash
kubectl apply -f k8s/
```

This will roll out:
- `tempconv-backend` Deployment + Service (ClusterIP)
- `tempconv-frontend` Deployment + Service (LoadBalancer/Ingress)

## 6. Verify

```bash
kubectl get pods
kubectl logs deployment/tempconv-backend
kubectl logs deployment/tempconv-frontend
```

Hit the frontend load balancer URL; the Flutter app will call the backend via gRPC-Web on the internal service DNS name configured in the UI.
