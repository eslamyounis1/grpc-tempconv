# Temperature Converter (Go + Flutter)

A full-stack temperature converter with a Go REST API and a Flutter UI. The backend exposes a simple `/convert` endpoint, and the frontend provides a responsive interface for web and mobile.

## Architecture
- **Backend**: Go HTTP server with JSON API and CORS support.
- **Frontend**: Flutter app (web/mobile) that calls the backend.
- **Infra**: Dockerfiles and Kubernetes manifests for deployment.

## Features
- Convert Celsius ? Fahrenheit
- CORS-ready API
- Health endpoint for readiness/liveness probes
- Flutter UI with auto-convert, rounding control, and backend URL input

## API
**POST `/convert`**

Request body:
```json
{
  "value": 36.6,
  "from": "C",
  "to": "F"
}
```

Response:
```json
{
  "result": 97.88
}
```

Errors return:
```json
{
  "error": "message"
}
```

**GET `/health`** ? `{ "status": "ok" }`

## Local Development
### Backend
```bash
cd backend
go test ./...
go run .
```

Environment variables:
- `PORT` (default `8080`)
- `CORS_ORIGINS` (comma-separated list; empty allows all)

### Frontend
```bash
cd frontend
flutter pub get
flutter run
```

Default backend URLs in the app:
- Web: `http://localhost:8080`
- Android emulator: `http://10.0.2.2:8080`

## Docker
### Backend
```bash
docker build -t tempconv-backend ./backend
docker run -p 8080:8080 tempconv-backend
```

### Frontend (web)
```bash
cd frontend
flutter build web
cd ..
docker build -t tempconv-frontend -f frontend/Dockerfile frontend
docker run -p 8081:80 tempconv-frontend
```

## Kubernetes
Manifests live in `k8s/`.
```bash
kubectl apply -f k8s/
```

Update image references in `k8s/backend-deployment.yaml` and `k8s/frontend-deployment.yaml` before deploying.

## Load Testing (k6)
```bash
k6 run tests/k6/load.js
```

To target a custom backend:
```bash
k6 run -e BASE_URL=http://YOUR_BACKEND_URL tests/k6/load.js
```

## Project Layout
- `backend/` Go API
- `frontend/` Flutter app
- `k8s/` Kubernetes manifests
- `tests/` k6 load tests
- `README.plan.md` original build plan
