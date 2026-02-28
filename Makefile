.PHONY: backend-image frontend-image push-backend push-frontend deploy

REGISTRY ?= us-central1-docker.pkg.dev/temp-converter-488818/tempconv
BACKEND_IMAGE ?= $(REGISTRY)/tempconv-backend
FRONTEND_IMAGE ?= $(REGISTRY)/tempconv-frontend
TAG ?= 2.0.0

backend-image:
	docker build -t $(BACKEND_IMAGE):$(TAG) backend

frontend-image:
	docker build -t $(FRONTEND_IMAGE):$(TAG) -f frontend/Dockerfile frontend

push-backend: backend-image
	docker push $(BACKEND_IMAGE):$(TAG)

push-frontend: frontend-image
	docker push $(FRONTEND_IMAGE):$(TAG)

deploy:
	kubectl set image deployment/tempconv-backend backend=$(BACKEND_IMAGE):$(TAG)
	kubectl set image deployment/tempconv-frontend frontend=$(FRONTEND_IMAGE):$(TAG)
