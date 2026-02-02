# Temperature Converter Calculator - Build Plan (Go + Flutter)

## Goal
Build a simple calculator app that converts Celsius <-> Fahrenheit with a Go backend API and a Flutter frontend UI. The backend and (optional) web frontend are containerized and deployed to GKE.

## Phase 1: Product Definition
- Define core features: input temperature, select direction (C->F or F->C), show result.
- Confirm architecture: Go backend (API) + Flutter frontend (UI).
- Set minimal UX: instant conversion on input or on button click, error messages for invalid input.

## Phase 2: Project Setup
- Create repo structure:
  - `backend/` for Go API (net/http or similar)
  - `frontend/` for Flutter app (mobile/web)
  - `tests/` for shared or integration tests (optional)
  - `README.md` for usage and plan
- Add basic tooling:
  - Go: `go mod init`, formatter (`gofmt`), lint (optional)
  - Flutter: `flutter create`, formatter (`dart format`), analyzer

## Phase 3: Core Logic (Go Backend)
- Implement conversion formulas:
  - C -> F: `F = (C * 9/5) + 32`
  - F -> C: `C = (F - 32) * 5/9`
- Define API contract:
  - Endpoint: `POST /convert`
  - Request JSON: `{ "value": number, "from": "C"|"F", "to": "C"|"F" }`
  - Response JSON: `{ "result": number }` or `{ "error": "message" }`
- Runtime config (env):
  - `PORT` (default `8080`)
  - `CORS_ORIGINS` (comma-separated; if empty, all origins allowed)
- Add input parsing and validation:
  - Accept decimals and negative numbers
  - Reject empty or non-numeric input, same-unit conversion
- Add unit tests for edge cases:
  - 0, 100, -40, decimals, invalid input

## Phase 4: UI and Interaction (Flutter)
- Build a simple layout:
  - Input field
  - Unit selector (dropdown or toggle)
  - Convert button or live update
  - Result display
- Wire UI to backend:
  - Call Go API over HTTP
  - Show loading and error states
- Ensure responsive layout (mobile/desktop)

## Phase 5: Testing and QA
- Run Go unit tests
- Run Flutter widget tests (basic)
- Manual test on device/emulator
- Verify conversion accuracy and rounding rules

## Phase 6: Documentation
- Update `README.md` with:
  - Project overview
  - How to run backend locally
  - How to run Flutter app
  - How to run tests
  - Known limitations

## Local Run (Examples)
### Backend
- Default port: `go run .` (from `backend/`)
- Custom port: `PORT=9090 go run .`
- Restrict CORS: `CORS_ORIGINS=http://localhost:3000,http://localhost:8081 go run .`

### Frontend (Flutter)
- Create project: `flutter create frontend` (if not created yet)
- Run app: `flutter run`

## Tooling Setup (Windows)
- Docker Desktop (required for container builds and local runs).
- Google Cloud CLI (`gcloud`) and GKE auth plugin.
- `kubectl` for Kubernetes control.
- `k6` for load testing.

## Phase 7: Containerization (Docker)
- Backend image:
  - `docker build -t tempconv-backend ./backend`
  - `docker run -p 8080:8080 tempconv-backend`
- Flutter web (optional container):
  - `flutter build web` (from `frontend/`)
  - `docker build -t tempconv-frontend -f frontend/Dockerfile frontend`
  - `docker run -p 8081:80 tempconv-frontend`
- Note: GKE nodes are amd64, so use `docker buildx build --platform linux/amd64` when pushing images.

## Container Usage
### Backend API
- Run: `docker run -p 8080:8080 tempconv-backend`
- Endpoint: `POST http://localhost:8080/convert`
- Request body:
  - `{ "value": number, "from": "C"|"F", "to": "C"|"F" }`
- Example:
  - `curl -X POST http://localhost:8080/convert -H "Content-Type: application/json" -d "{\"value\": 100, \"from\": \"C\", \"to\": \"F\"}"`

### Frontend (web, optional)
- Run: `docker run -p 8081:80 tempconv-frontend`
- Open: `http://localhost:8081`

## Phase 8: Kubernetes (GKE)
- Create Artifact Registry repo and push images.
- Create a GKE cluster and get kubeconfig.
- Update image references in `k8s/*.yaml` and apply manifests.
- Verify services and grab LoadBalancer IPs.

## Phase 9: Load Testing (k6)
- Run k6 against the backend service to validate concurrency and latency.

## Future Refactor Plan: gRPC + ProtoBuf
This is a later task (not scheduled now). High-level plan to migrate from REST to gRPC + Protobuf:
- Define Protobuf schema:
  - Create `proto/temperature.proto` with `ConvertRequest` and `ConvertResponse`.
  - Add validation rules and error semantics (status codes, error details).
- Generate code:
  - Add `buf` (optional) and `protoc` config to generate Go server stubs and Dart client.
  - Keep generated code in `backend/gen/` and `frontend/lib/gen/`.
- Backend changes:
  - Implement gRPC service in Go.
  - Keep REST `/convert` temporarily for backwards compatibility.
  - Add gRPC health checks and reflection for debugging.
- Frontend changes:
  - Add gRPC-web client for Flutter web (or use a proxy like Envoy).
  - Replace REST calls with generated gRPC client calls.
- Infrastructure changes:
  - Update Dockerfiles if needed (gRPC port, proxy sidecar if gRPC-web).
  - Update k8s service ports, readiness/liveness probes.
- Testing:
  - Add gRPC unit/integration tests.
  - Update k6 plan or switch to gRPC-capable load testing.
- Cutover:
  - Dual-run REST + gRPC, migrate clients, then remove REST endpoints.

## Typical Deployment Pipeline
- Development / Local: Individual developers write and test code locally.
- CI / Build: Automated tests run (unit, integration).
- Test / QA: Deployed to a dedicated testing environment (may use mock or synthetic data).
- Staging: Deployed after passing earlier stages; closest to production in config, scale, data volume, security, and dependencies.
- Production: Live to real users (after approval from staging).

## Milestone Checklist
- [ ] Requirements agreed
- [ ] Core conversion logic complete
- [ ] UI wired to logic
- [ ] Tests passing
- [ ] Documentation updated
- [ ] Docker added
- [ ] GKE deploy works
- [ ] Load test executed

## Deployment and Testing Guide
### Install Tooling
- Docker Desktop: install and verify `docker --version`.
- Google Cloud CLI: install and run `gcloud init`.
- kubectl: install via `gcloud components install kubectl` or your preferred package manager.
- GKE auth plugin: `gcloud components install gke-gcloud-auth-plugin`.
- k6: install and verify `k6 version`.

### Build and Push Images (amd64)
- Set your project and region:
  - `gcloud config set project YOUR_PROJECT_ID`
  - `gcloud services enable container.googleapis.com artifactregistry.googleapis.com`
- Create Artifact Registry (example `us-central1`):
  - `gcloud artifacts repositories create tempconv --repository-format=docker --location=us-central1`
  - `gcloud auth configure-docker us-central1-docker.pkg.dev`
- Build and push backend image:
  - `docker buildx build --platform linux/amd64 -t us-central1-docker.pkg.dev/YOUR_PROJECT_ID/tempconv/tempconv-backend:1.0.0 -f backend/Dockerfile backend --push`
- Build and push frontend image (optional):
  - `flutter build web` (from `frontend/`)
  - `docker buildx build --platform linux/amd64 -t us-central1-docker.pkg.dev/YOUR_PROJECT_ID/tempconv/tempconv-frontend:1.0.0 -f frontend/Dockerfile frontend --push`

### Create GKE Cluster and Deploy
- Create cluster (example):
  - `gcloud container clusters create tempconv --zone us-central1-a --num-nodes 2`
- Get credentials:
  - `gcloud container clusters get-credentials tempconv --zone us-central1-a`
- Update image references in:
  - `k8s/backend-deployment.yaml`
  - `k8s/frontend-deployment.yaml` (if using web)
- Apply manifests:
  - `kubectl apply -f k8s/`
- Check services:
  - `kubectl get svc tempconv-backend`
  - `kubectl get svc tempconv-frontend` (optional)

### Load Testing (k6)
- Local:
  - `k6 run tests/k6/load.js`
- Against GKE LoadBalancer:
  - `k6 run -e BASE_URL=http://BACKEND_LB_IP tests/k6/load.js`
