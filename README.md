# Jenkins Docker Agent

A comprehensive, production-ready Docker agent for Jenkins with pre-installed CI/CD tools including Helm, kubectl, Azure CLI, AWS CLI, Terraform, and more.

## 🚀 Features

This Docker agent image comes pre-loaded with:

### Cloud Provider CLIs
- **Azure CLI** (`az`) - Azure cloud management
- **AWS CLI v2** (`aws`) - Amazon Web Services management
- **Google Cloud SDK** (`gcloud`) - Google Cloud Platform management

### Container & Orchestration Tools
- **Docker CLI** - Build and manage containers
- **kubectl** - Kubernetes cluster management
- **Helm** - Kubernetes package manager

### Infrastructure as Code
- **Terraform** - Infrastructure provisioning and management

### Development Tools
- **Git** - Version control
- **Python 3** with pip - Python scripting and automation
- **Node.js** with npm (LTS) - JavaScript runtime
- **jq** - JSON processor
- **yq** - YAML processor
- **make** - Build automation

### Security & Quality Tools
- **Trivy** - Vulnerability scanner for containers
- **Hadolint** - Dockerfile linter
- **Dive** - Docker image analysis tool

### Python Packages
- PyYAML - YAML parsing
- Requests - HTTP library
- Boto3 - AWS SDK for Python
- Azure CLI Core

---

## 📦 Quick Start

### Build the Image

```bash
./build.sh [tag] [dockerhub-username]
```

Example:
```bash
./build.sh v1.0.0 myusername
```

### Push to Docker Hub

```bash
docker login
./push.sh [tag] [dockerhub-username]
```

Example:
```bash
./push.sh v1.0.0 myusername
```

---

## 🔧 Setting Up Jenkins with Docker Agents

### Prerequisites

1. **Server with Docker Installed**
   ```bash
   docker --version
   ```

2. **Docker Hub Account**
   - Create a [Docker Hub account](https://hub.docker.com/)

3. **GitHub Repository**
   - Your project repository on GitHub

### Step 1: Pull and Run Jenkins Controller

1. Pull the official Jenkins image:
   ```bash
   docker pull jenkins/jenkins:lts
   ```

2. Create a persistent volume:
   ```bash
   docker volume create jenkins_home
   ```

3. Run Jenkins:
   ```bash
   docker run -d --name jenkins-controller \
       --restart unless-stopped \
       -p 8080:8080 -p 50000:50000 \
       -v jenkins_home:/var/jenkins_home \
       -v /var/run/docker.sock:/var/run/docker.sock \
       jenkins/jenkins:lts
   ```

4. Get the initial admin password:
   ```bash
   docker logs jenkins-controller
   ```
   Access Jenkins at `http://<server-ip>:8080`

### Step 2: Install Required Plugins

Go to **Manage Jenkins → Plugin Manager → Available** and install:
- **Docker Pipeline**
- **Git Plugin**
- **Pipeline**
- **Kubernetes Plugin** (optional, for K8s deployments)

### Step 3: Configure Docker in Jenkins

1. Go to **Manage Jenkins → Manage Nodes and Clouds → Configure Clouds**
2. Add a new **Docker** cloud:
   - **Docker Host URI**: `unix:///var/run/docker.sock`
   - Click **Test Connection** to verify

3. Add a Docker Agent template:
   - **Docker Image**: `your-dockerhub-user/jenkins-docker-agent:latest`
   - **Remote File System Root**: `/home/jenkins`
   - **Labels**: `docker-agent` or `k8s-agent`
   - **Usage**: "Only build jobs with label expressions matching this node"

### Step 4: Add Credentials

Go to **Manage Jenkins → Credentials → System → Global credentials**:

1. **Docker Hub Credentials**
   - **Kind**: Username with password
   - **ID**: `DOCKERHUB_CREDENTIALS`

2. **AWS Credentials** (if needed)
   - **Kind**: AWS Credentials
   - **ID**: `AWS_CREDENTIALS`

3. **Azure Service Principal** (if needed)
   - **Kind**: Secret text or Username with password
   - **ID**: `AZURE_CREDENTIALS`

4. **Kubernetes Config** (if needed)
   - **Kind**: Secret file
   - **ID**: `KUBECONFIG`

---

## 📝 Example Pipeline

See [examples/Jenkinsfile](examples/Jenkinsfile) for a complete example.

### Basic Pipeline

```groovy
pipeline {
    agent {
        docker {
            image 'your-dockerhub-user/jenkins-docker-agent:latest'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('DOCKERHUB_CREDENTIALS')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/your-org/your-repo.git'
            }
        }

        stage('Build') {
            steps {
                sh 'docker build -t your-image:${BUILD_NUMBER} .'
            }
        }

        stage('Test') {
            steps {
                sh 'docker run --rm your-image:${BUILD_NUMBER} npm test'
            }
        }

        stage('Security Scan') {
            steps {
                sh 'trivy image your-image:${BUILD_NUMBER}'
            }
        }

        stage('Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'DOCKERHUB_CREDENTIALS',
                    usernameVariable: 'USERNAME',
                    passwordVariable: 'PASSWORD'
                )]) {
                    sh '''
                        echo $PASSWORD | docker login -u $USERNAME --password-stdin
                        docker push your-image:${BUILD_NUMBER}
                        docker logout
                    '''
                }
            }
        }
    }
}
```

---

## 🐳 Docker Compose for Local Testing

Use the provided [docker-compose.yml](docker-compose.yml) for local development:

```bash
docker-compose up -d
```

Access Jenkins at `http://localhost:8080`

---

## 🛠️ Tool Versions

The image uses the latest stable versions of all tools at build time. To check versions:

```bash
docker run --rm your-dockerhub-user/jenkins-docker-agent:latest bash -c "
    docker --version &&
    kubectl version --client &&
    helm version &&
    az version &&
    aws --version &&
    terraform version
"
```

---

## 📚 Advanced Usage

### Kubernetes Deployments

```groovy
stage('Deploy to Kubernetes') {
    steps {
        withCredentials([file(credentialsId: 'KUBECONFIG', variable: 'KUBECONFIG')]) {
            sh '''
                export KUBECONFIG=$KUBECONFIG
                kubectl apply -f k8s/deployment.yaml
                kubectl rollout status deployment/myapp
            '''
        }
    }
}
```

### Helm Deployments

```groovy
stage('Deploy with Helm') {
    steps {
        sh '''
            helm upgrade --install myapp ./helm-chart \
                --namespace production \
                --set image.tag=${BUILD_NUMBER}
        '''
    }
}
```

### Terraform Infrastructure

```groovy
stage('Terraform Apply') {
    steps {
        withCredentials([string(credentialsId: 'AWS_CREDENTIALS', variable: 'AWS_CREDS')]) {
            sh '''
                cd terraform
                terraform init
                terraform plan -out=tfplan
                terraform apply tfplan
            '''
        }
    }
}
```

---

## 🔒 Security Best Practices

1. **Use Specific Image Tags**
   - Pin to specific versions in production: `jenkins-docker-agent:v1.0.0`

2. **Scan Images Regularly**
   - Use Trivy to scan for vulnerabilities
   - Integrate scanning into your pipeline

3. **Rotate Credentials**
   - Update Jenkins credentials regularly
   - Use short-lived tokens when possible

4. **Limit Docker Socket Access**
   - Only mount Docker socket when necessary
   - Consider using Docker-in-Docker (DinD) for isolation

5. **Use Secrets Management**
   - Store sensitive data in Jenkins credentials
   - Use cloud provider secret managers (AWS Secrets Manager, Azure Key Vault)

---

## 🐛 Troubleshooting

### Docker Socket Permission Issues

```bash
# On the host, ensure Jenkins can access Docker socket
sudo chmod 666 /var/run/docker.sock
```

### Agent Connection Issues

- Verify Docker Host URI in Jenkins cloud configuration
- Check that the agent image exists and is accessible
- Review Jenkins logs: `docker logs jenkins-controller`

### Tool Not Found

If a tool is not available in the agent:
1. Rebuild the image: `./build.sh`
2. Verify installation in Dockerfile
3. Check build logs for errors

---

## 📊 Maintenance

### Regular Updates

Update the base image and tools:

```bash
# Pull latest base image
docker pull jenkins/inbound-agent:latest

# Rebuild with latest tools
./build.sh v$(date +%Y%m%d) your-username
./push.sh v$(date +%Y%m%d) your-username
```

### Backup Jenkins Data

```bash
# Backup jenkins_home volume
docker run --rm -v jenkins_home:/data -v $(pwd):/backup \
    ubuntu tar czf /backup/jenkins_home_backup.tar.gz /data
```

### Monitor Image Size

```bash
# Check image size
docker images | grep jenkins-docker-agent

# Analyze layers with dive
dive your-dockerhub-user/jenkins-docker-agent:latest
```

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the build
5. Submit a pull request

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 🙏 Acknowledgments

- Based on the official [Jenkins Inbound Agent](https://hub.docker.com/r/jenkins/inbound-agent)
- Inspired by the DevOps community's best practices

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/eddiegaeta/jenkins_docker_agent/issues)
- **Documentation**: This README
- **Docker Hub**: [your-dockerhub-user/jenkins-docker-agent](https://hub.docker.com/r/your-dockerhub-user/jenkins-docker-agent)

---

**Happy Building! 🚀**
