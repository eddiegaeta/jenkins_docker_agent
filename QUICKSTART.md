# Quick Start Guide

Get up and running with Jenkins Docker Agent in minutes!

## 🚀 Option 1: Use Pre-built Image (Fastest)

```bash
# Pull the image
docker pull your-dockerhub-user/jenkins-docker-agent:latest

# Use in your Jenkinsfile
agent {
    docker {
        image 'your-dockerhub-user/jenkins-docker-agent:latest'
        args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
}
```

## 🔨 Option 2: Build Your Own

### 1. Clone the Repository
```bash
git clone https://github.com/eddiegaeta/jenkins_docker_agent.git
cd jenkins_docker_agent
```

### 2. Build the Image
```bash
# Using the build script
./build.sh v1.0.0 your-dockerhub-username

# Or using Make
make build DOCKER_USER=your-dockerhub-username

# Or using Docker directly
docker build -t your-dockerhub-username/jenkins-docker-agent:latest .
```

### 3. Push to Docker Hub
```bash
# Login to Docker Hub
docker login

# Push the image
./push.sh v1.0.0 your-dockerhub-username

# Or using Make
make push DOCKER_USER=your-dockerhub-username
```

## 🧪 Option 3: Test Locally with Docker Compose

### 1. Update Configuration
Edit `jenkins-casc.yaml` and `docker-compose.yml` with your Docker Hub username.

### 2. Start Jenkins
```bash
# Using docker-compose
docker-compose up -d

# Or using Make
make run-jenkins
```

### 3. Access Jenkins
- **URL**: http://localhost:8080
- **Default credentials**: admin / admin
- **Change password** after first login!

### 4. View Logs
```bash
docker-compose logs -f jenkins-controller

# Or using Make
make logs
```

## 📝 Create Your First Pipeline

1. **In Jenkins UI**: New Item → Pipeline
2. **Name it**: my-first-pipeline
3. **Pipeline Script**:
```groovy
pipeline {
    agent {
        docker {
            image 'your-dockerhub-user/jenkins-docker-agent:latest'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    
    stages {
        stage('Test Tools') {
            steps {
                sh '''
                    echo "=== Tool Versions ==="
                    docker --version
                    kubectl version --client
                    helm version
                    az version
                    aws --version
                    terraform version
                '''
            }
        }
    }
}
```
4. **Save and Build**

## ✅ Verify Installation

Test all tools:
```bash
make test DOCKER_USER=your-dockerhub-username
```

Or manually:
```bash
docker run --rm your-dockerhub-username/jenkins-docker-agent:latest bash -c "
    docker --version &&
    kubectl version --client &&
    helm version &&
    terraform version
"
```

## 🔐 Configure Credentials in Jenkins

1. Go to **Manage Jenkins → Credentials → System → Global credentials**

2. **Add Docker Hub**:
   - Kind: Username with password
   - ID: `DOCKERHUB_CREDENTIALS`
   - Username: your-dockerhub-username
   - Password: your-dockerhub-token

3. **Add Kubernetes** (if needed):
   - Kind: Secret file
   - ID: `KUBECONFIG`
   - File: Upload your kubeconfig

4. **Add Cloud Credentials**:
   - AWS: Use AWS Credentials type
   - Azure: Use Secret text or Username/Password
   - GCP: Use Secret file with service account JSON

## 📚 Next Steps

- Check out [examples/](examples/) for complete pipeline examples
- Read the full [README.md](README.md) for detailed documentation
- Customize the [Dockerfile](Dockerfile) to add more tools
- Set up [GitHub Actions](.github/workflows/docker-build.yml) for automated builds

## 🆘 Troubleshooting

### Docker socket permission denied
```bash
# On the host
sudo chmod 666 /var/run/docker.sock
```

### Agent won't connect
- Verify Docker Host URI: `unix:///var/run/docker.sock`
- Check Jenkins logs: `docker logs jenkins-controller`
- Ensure image is accessible

### Tool not found
```bash
# Rebuild the image
make build DOCKER_USER=your-dockerhub-username

# Verify tools
make test DOCKER_USER=your-dockerhub-username
```

## 🎉 You're Ready!

Start building awesome CI/CD pipelines! 🚀
