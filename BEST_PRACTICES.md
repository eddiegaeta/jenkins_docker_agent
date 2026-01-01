# Jenkins Docker Agent - Best Practices

## 🎯 Image Management

### Versioning
- **Use semantic versioning** (v1.0.0, v1.1.0, etc.)
- **Tag releases** in Git and Docker Hub
- **Pin specific versions** in production Jenkinsfiles
- **Use `latest` only** for development/testing

```groovy
// ❌ Don't do this in production
image 'myuser/jenkins-docker-agent:latest'

// ✅ Do this instead
image 'myuser/jenkins-docker-agent:v1.0.0'
```

### Build Strategy
- **Rebuild monthly** to get security patches
- **Test before pushing** to production
- **Use multi-stage builds** if image gets too large
- **Scan for vulnerabilities** regularly

## 🔒 Security

### Docker Socket Access
```groovy
// Only mount when needed
agent {
    docker {
        image 'myuser/jenkins-docker-agent:v1.0.0'
        args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
}
```

### Credentials
- **Never hardcode** credentials in Jenkinsfiles
- **Use Jenkins credentials** store
- **Rotate regularly** (every 90 days minimum)
- **Use short-lived tokens** when possible

```groovy
// ✅ Good
withCredentials([usernamePassword(
    credentialsId: 'DOCKERHUB_CREDENTIALS',
    usernameVariable: 'USER',
    passwordVariable: 'PASS'
)]) {
    sh 'echo $PASS | docker login -u $USER --password-stdin'
}
```

### Image Scanning
```groovy
stage('Security Scan') {
    steps {
        sh 'trivy image --severity HIGH,CRITICAL myimage:${BUILD_NUMBER}'
    }
}
```

## 🚀 Performance

### Resource Management
```groovy
agent {
    docker {
        image 'myuser/jenkins-docker-agent:v1.0.0'
        // Set resource limits
        args '''
            -v /var/run/docker.sock:/var/run/docker.sock
            --memory=2g
            --cpus=2
        '''
    }
}
```

### Caching
- **Use Docker layer caching** in builds
- **Cache dependencies** (npm, pip, maven)
- **Reuse workspaces** when appropriate

```groovy
// Cache pip packages
sh 'pip install --cache-dir /tmp/pip-cache -r requirements.txt'
```

### Cleanup
```groovy
post {
    always {
        // Clean up Docker artifacts
        sh '''
            docker system prune -f
            docker volume prune -f
        '''
    }
}
```

## 📊 Pipeline Design

### Stage Organization
```groovy
pipeline {
    stages {
        stage('Prepare') { }      // Setup, checkout
        stage('Build') { }        // Compile, package
        stage('Test') { }         // Unit, integration tests
        stage('Quality') { }      // Lint, scan
        stage('Security') { }     // Vulnerability scan
        stage('Publish') { }      // Push artifacts
        stage('Deploy') { }       // Deploy to environment
        stage('Verify') { }       // Health checks
    }
}
```

### Parallel Execution
```groovy
stage('Tests') {
    parallel {
        stage('Unit Tests') { }
        stage('Integration Tests') { }
        stage('Security Scan') { }
    }
}
```

### Error Handling
```groovy
post {
    failure {
        // Send notifications
        emailext(
            subject: "Build Failed: ${env.JOB_NAME}",
            body: "Check console output at ${env.BUILD_URL}"
        )
    }
}
```

## 🛠️ Tool Configuration

### kubectl
```groovy
stage('Deploy to K8s') {
    steps {
        withCredentials([file(credentialsId: 'KUBECONFIG', variable: 'KUBECONFIG')]) {
            sh '''
                export KUBECONFIG=$KUBECONFIG
                kubectl config view  # Verify config
                kubectl get nodes     # Test connection
                kubectl apply -f deployment.yaml
            '''
        }
    }
}
```

### Helm
```groovy
stage('Helm Deploy') {
    steps {
        sh '''
            helm lint ./chart
            helm upgrade --install myapp ./chart \
                --namespace prod \
                --create-namespace \
                --wait \
                --timeout 5m
        '''
    }
}
```

### Terraform
```groovy
stage('Infrastructure') {
    steps {
        sh '''
            cd terraform
            terraform init -backend-config="key=myapp/${BRANCH_NAME}"
            terraform plan -out=tfplan
            terraform apply tfplan
        '''
    }
}
```

### Cloud CLIs
```groovy
// Azure
withCredentials([azureServicePrincipal('AZURE_SP')]) {
    sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID'
    sh 'az aks get-credentials --resource-group mygroup --name mycluster'
}

// AWS
withAWS(credentials: 'AWS_CREDENTIALS', region: 'us-east-1') {
    sh 'aws eks update-kubeconfig --name mycluster'
}
```

## 📝 Documentation

### Pipeline Documentation
```groovy
pipeline {
    // Document what this pipeline does
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
    stages {
        stage('Build') {
            // Explain complex steps
            steps {
                echo "Building application version ${BUILD_NUMBER}"
                sh './build.sh'
            }
        }
    }
}
```

### Self-Documenting Code
```groovy
// ❌ Bad
sh 'kubectl apply -f k8s/*.yaml'

// ✅ Good
echo "Deploying to Kubernetes cluster..."
sh '''
    kubectl apply -f k8s/namespace.yaml
    kubectl apply -f k8s/deployment.yaml
    kubectl apply -f k8s/service.yaml
    kubectl rollout status deployment/myapp -n prod
'''
```

## 🔄 CI/CD Best Practices

### Trunk-Based Development
```groovy
stage('Deploy') {
    when {
        branch 'main'  // Only deploy from main branch
    }
    steps {
        sh './deploy.sh production'
    }
}
```

### Environment Management
```groovy
def deployTo(environment) {
    sh "kubectl apply -f k8s/${environment}/"
}

stage('Deploy to Dev') {
    when { branch 'develop' }
    steps { deployTo('dev') }
}

stage('Deploy to Prod') {
    when { branch 'main' }
    steps {
        input 'Deploy to production?'  // Manual approval
        deployTo('prod')
    }
}
```

### Feature Flags
```groovy
environment {
    FEATURE_NEW_UI = "${env.BRANCH_NAME == 'main' ? 'true' : 'false'}"
}
```

## 🎓 Training

### New Team Members
1. Start with [QUICKSTART.md](QUICKSTART.md)
2. Review example pipelines in [examples/](examples/)
3. Try local setup with Docker Compose
4. Create a test pipeline
5. Move to production gradually

### Resources
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)

## 📈 Monitoring

### Pipeline Metrics
- Build duration trends
- Success/failure rates
- Test coverage
- Deployment frequency

### Alerts
```groovy
post {
    failure {
        slackSend(
            color: 'danger',
            message: "Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        )
    }
}
```

## 🔧 Maintenance

### Regular Tasks
- [ ] Update base image monthly
- [ ] Review and rotate credentials quarterly
- [ ] Audit tool versions quarterly
- [ ] Review and update documentation
- [ ] Clean up old pipelines
- [ ] Archive old builds

### Health Checks
```bash
# Check image size growth
docker images | grep jenkins-docker-agent

# Check for security vulnerabilities
make scan

# Verify all tools
make test
```

---

**Remember**: Security, simplicity, and maintainability should always come first! 🎯
