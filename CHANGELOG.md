# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-01

### Added
- Initial release of Jenkins Docker Agent
- Docker CLI for container operations
- kubectl for Kubernetes cluster management
- Helm 3 for Kubernetes package management
- Azure CLI (az) for Azure cloud operations
- AWS CLI v2 for Amazon Web Services operations
- Google Cloud SDK (gcloud) for GCP operations
- Terraform for infrastructure as code
- Python 3 with pip and common packages (PyYAML, requests, boto3)
- Node.js LTS with npm
- jq for JSON processing
- yq for YAML processing
- Trivy for security vulnerability scanning
- Hadolint for Dockerfile linting
- Dive for Docker image analysis
- Build and push automation scripts
- Docker Compose setup for local testing
- Jenkins Configuration as Code (JCasC) example
- Comprehensive README documentation
- Multiple example Jenkinsfiles
- MIT License

### Security
- Base image: jenkins/inbound-agent:latest
- All tools installed from official sources
- Trivy integration for vulnerability scanning

[1.0.0]: https://github.com/eddiegaeta/jenkins_docker_agent/releases/tag/v1.0.0
