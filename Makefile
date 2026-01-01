.PHONY: help build push test clean run-jenkins stop-jenkins logs

# Default Docker Hub username - override with: make build DOCKER_USER=yourusername
DOCKER_USER ?= your-dockerhub-username
IMAGE_NAME = jenkins-docker-agent
VERSION ?= $(shell cat VERSION)
FULL_IMAGE = $(DOCKER_USER)/$(IMAGE_NAME)

help: ## Show this help message
	@echo "Jenkins Docker Agent - Makefile Commands"
	@echo "========================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image
	@echo "Building $(FULL_IMAGE):$(VERSION)..."
	docker build -t $(FULL_IMAGE):$(VERSION) -t $(FULL_IMAGE):latest .
	@echo "✅ Build complete!"

push: ## Push the Docker image to registry
	@echo "Pushing $(FULL_IMAGE):$(VERSION) and latest..."
	docker push $(FULL_IMAGE):$(VERSION)
	docker push $(FULL_IMAGE):latest
	@echo "✅ Push complete!"

test: build ## Test the Docker image
	@echo "Testing Docker image..."
	@docker run --rm $(FULL_IMAGE):$(VERSION) bash -c " \
		set -e && \
		echo '=== Verifying tool installations ===' && \
		docker --version && \
		kubectl version --client && \
		helm version && \
		az version && \
		aws --version && \
		gcloud version && \
		terraform version && \
		node --version && \
		npm --version && \
		python3 --version && \
		jq --version && \
		yq --version && \
		echo '✅ All tools verified successfully!' \
	"

scan: build ## Run security scan with Trivy
	@echo "Scanning $(FULL_IMAGE):$(VERSION) for vulnerabilities..."
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		aquasec/trivy image --severity HIGH,CRITICAL $(FULL_IMAGE):$(VERSION)

lint: ## Lint the Dockerfile
	@echo "Linting Dockerfile..."
	docker run --rm -i hadolint/hadolint < Dockerfile

run-jenkins: ## Start Jenkins with docker-compose
	@echo "Starting Jenkins..."
	docker-compose up -d
	@echo "✅ Jenkins is starting..."
	@echo "Access Jenkins at: http://localhost:8080"
	@echo "Default credentials: admin / admin (change after login!)"

stop-jenkins: ## Stop Jenkins
	@echo "Stopping Jenkins..."
	docker-compose down
	@echo "✅ Jenkins stopped"

logs: ## Show Jenkins logs
	docker-compose logs -f jenkins-controller

clean: ## Clean up Docker images and containers
	@echo "Cleaning up..."
	docker-compose down -v
	docker system prune -f
	@echo "✅ Cleanup complete"

all: build test push ## Build, test, and push

version: ## Show current version
	@echo "Current version: $(VERSION)"

.DEFAULT_GOAL := help
