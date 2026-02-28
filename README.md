# Temperature Converter Platform

This repository hosts a full-stack temperature converter composed of a Go gRPC backend, a Flutter web client, and Kubernetes deployment assets for Google Kubernetes Engine (GKE). The project is optimized for repeatable Artifact Registry / Cloud Build pipelines and supports both local development and production rollouts.

## Overview
- **Backend**: Implements the `tempconv.v1.TempConverter` gRPC API plus gRPC-Web compatibility and an HTTP `/health` probe.
- **Frontend**: Responsive Flutter web UI with auto-convert toggles, rounding controls, and a configurable backend URL. The default backend can be overridden at build time (`--dart-define BACKEND_URL=...`) or via a `?backend=` query parameter.
- **Infrastructure**: Multi-stage Dockerfiles, k6 load tests, and Kubernetes manifests designed for GKE clusters using Google Artifact Registry images.

## Repository Layout
| Path | Description |
| --- | --- |
| `backend/` | Go service, protobuf stubs (`pb/`), tests, and Dockerfile |
| `frontend/` | Flutter app, generated protobuf clients, and Dockerfile |
| `proto/` | `tempconv.proto` plus build helper scripts |
| `k8s/` | Deployments and Services for backend and frontend |
| `tests/` | k6 load scripts targeting the gRPC-Web proxy |
| `DEPLOYMENT.md` | Detailed instructions for Artifact Registry + GKE workflows |

## Local Development
### Backend
```bash
cd backend
go test ./...
go run .
```

Environment variables:
- `PORT` (default `8080`)
- `CORS_ORIGINS` (comma-separated list; empty allows all origins)

### Frontend
```bash
cd frontend
flutter pub get
flutter run -d chrome --web-port=5001
```

Defaults:
- Web build targets `http://localhost:8080`
- Android emulator uses `http://10.0.2.2:8080`
- Override with `--dart-define BACKEND_URL=http://custom-host:port` or append `?backend=` at runtime.

## Docker & Artifact Registry
Common workflow using the provided `Makefile` (set `TAG` appropriately):
```bash
TAG=2.0.0 make backend-image frontend-image   # Build locally
TAG=2.0.0 make push-backend push-frontend     # Push to Artifact Registry
```

Cloud Build submissions (no local Docker daemon required):
```bash
gcloud builds submit backend \
  --tag us-central1-docker.pkg.dev/PROJECT_ID/tempconv/tempconv-backend:2.0.0

gcloud builds submit frontend \
  --tag us-central1-docker.pkg.dev/PROJECT_ID/tempconv/tempconv-frontend:2.0.0
```
Replace `PROJECT_ID` with your Google Cloud project.

## Kubernetes Deployment
1. Create (or reuse) a GKE cluster.
2. Ensure `k8s/backend-deployment.yaml` and `k8s/frontend-deployment.yaml` reference the desired Artifact Registry images/tags.
3. Apply manifests:
   ```bash
   kubectl apply -f k8s/
   kubectl rollout status deployment/tempconv-backend
   kubectl rollout status deployment/tempconv-frontend
   ```
4. Retrieve service load balancer addresses:
   ```bash
   kubectl get svc tempconv-backend tempconv-frontend
   ```
   (Use these IPs when configuring DNS or updating the frontend default URL; do not commit the values to this repo.)

## Testing & Observability
- **k6 Load Test**: `k6 run tests/k6/load.js` (set `BASE_URL` to the backend service DNS).
- **Backend Logs**: `kubectl logs deployment/tempconv-backend`
- **Frontend Logs**: `kubectl logs deployment/tempconv-frontend`
- **Health Check**: `curl http://<backend-service>/health`

## Updating the Frontend Backend URL
1. Set `BACKEND_URL` in `frontend/Dockerfile` or pass `--build-arg BACKEND_URL=...` when building.
2. Rebuild the frontend image (Cloud Build or Docker).
3. Restart the `tempconv-frontend` deployment (`kubectl rollout restart deployment/tempconv-frontend`).

## Notes
- No public IPs or service URLs are committed to this README. Always obtain the current values via `kubectl get svc` or the GCP console.
- When reusing the `2.0.0` tag, rely on `imagePullPolicy: Always` (already set in the manifests) or bump the tag to ensure new pods pull the latest image.
