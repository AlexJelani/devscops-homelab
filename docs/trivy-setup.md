# Trivy Scanner Setup Guide

Trivy is a comprehensive and versatile security scanner for containers and other artifacts in our DevSecOps Home Lab.

## Overview

Trivy can scan:
- Container images
- Filesystems
- Git repositories
- Virtual machine images
- Infrastructure as Code files (Terraform, CloudFormation, Kubernetes manifests)

It detects:
- OS package vulnerabilities
- Language-specific dependencies vulnerabilities
- Misconfigurations
- Secrets

## Automatic Installation

Trivy is installed automatically by the `setup-hub.sh` script. The configuration file is located at `/opt/dsb-homelab/trivy/docker-compose.yml`.

## Manual Installation

If you need to install Trivy manually:

1. Create the necessary directory:

```bash
sudo mkdir -p /opt/dsb-homelab/trivy
```

2. Create the Docker Compose file:

```bash
sudo nano /opt/dsb-homelab/trivy/docker-compose.yml
```

Add the following content:

```yaml
version: '3.8'

services:
  trivy:
    image: aquasec/trivy:latest
    container_name: trivy
    volumes:
      - trivy_cache:/root/.cache
    command: server --listen 0.0.0.0:8080
    ports:
      - "8082:8080"
    restart: unless-stopped
    networks:
      - devsecops

volumes:
  trivy_cache:

networks:
  devsecops:
    driver: bridge
```

3. Start Trivy:

```bash
cd /opt/dsb-homelab/trivy
sudo docker-compose up -d
```

## Using Trivy

### Scanning Container Images

Run Trivy directly to scan container images:

```bash
# Basic image scan
docker run --rm aquasec/trivy image nginx:latest

# Save scan results in JSON format
docker run --rm aquasec/trivy image -f json -o results.json nginx:latest

# Filter vulnerabilities by severity
docker run --rm aquasec/trivy image --severity HIGH,CRITICAL nginx:latest
```

### Scanning Repositories

To scan Git repositories:

```bash
docker run --rm aquasec/trivy repo https://github.com/username/repository
```

### Scanning Filesystems

To scan filesystems:

```bash
docker run --rm -v /path/to/project:/app aquasec/trivy fs /app
```

### Scanning in CI/CD Pipeline

Add Trivy to your Jenkins pipeline:

```groovy
stage('Security Scan') {
    steps {
        sh '''
            docker run --rm -v $WORKSPACE:/app aquasec/trivy fs --exit-code 1 \
                --severity HIGH,CRITICAL \
                --no-progress \
                /app
        '''
    }
}
```

## Integrating with Jenkins

Create a more comprehensive Jenkins pipeline that incorporates Trivy:

```groovy
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'docker build -t my-app:$BUILD_NUMBER .'
            }
        }
        
        stage('Vulnerability Scan - Image') {
            steps {
                sh '''
                    docker run --rm -v $WORKSPACE:/report \
                        aquasec/trivy image \
                        -f html \
                        -o /report/trivy-image-report.html \
                        my-app:$BUILD_NUMBER
                '''
                
                publishHTML([
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: '.',
                    reportFiles: 'trivy-image-report.html',
                    reportName: 'Trivy Image Scan Report'
                ])
            }
        }
        
        stage('Vulnerability Scan - Filesystem') {
            steps {
                sh '''
                    docker run --rm -v $WORKSPACE:/app -v $WORKSPACE:/report \
                        aquasec/trivy fs \
                        -f html \
                        -o /report/trivy-fs-report.html \
                        /app
                '''
                
                publishHTML([
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: '.',
                    reportFiles: 'trivy-fs-report.html',
                    reportName: 'Trivy Filesystem Scan Report'
                ])
            }
        }
        
        stage('Deploy') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                echo 'Deploying the application...'
                // Deployment steps here
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
```

## Using Trivy as a Server

Trivy can also run as a server to provide a centralized scanning service:

1. Access the Trivy API:
   ```
   http://dsb-hub:8082/healthz
   ```

2. Scan an image using the Trivy server:
   ```bash
   docker run --rm aquasec/trivy client --remote http://dsb-hub:8082 image nginx:latest
   ```

## Trivy Operator for Kubernetes (Advanced)

If you decide to extend your home lab with Kubernetes, you can install the Trivy Operator:

```bash
helm repo add aqua https://aquasecurity.github.io/helm-charts/
helm repo update
helm install trivy-operator aqua/trivy-operator \
  --namespace trivy-system \
  --create-namespace \
  --set="trivy.imageRef=aquasec/trivy:latest"
```

## Updating Vulnerability Database

Trivy automatically updates its vulnerability database, but you can also update it manually:

```bash
docker run --rm aquasec/trivy image --download-db-only
```

## Troubleshooting

### Common Issues

1. **Scan failures**:
   - Check Trivy logs: `docker logs trivy`
   - Ensure you have enough disk space
   - Verify network connectivity for database updates

2. **Performance issues**:
   - Use cache directory for repeated scans
   - Limit scan targets (specific directories or packages)
   - Adjust vulnerability severity filters

3. **Integration problems**:
   - Check network connectivity between services
   - Verify container permissions
   - Check if Jenkins has access to Docker socket

### Viewing Logs

```bash
docker logs trivy
```

### Restarting Trivy

```bash
cd /opt/dsb-homelab/trivy
sudo docker-compose restart
```

## Best Practices

1. **Regular scanning**: Integrate Trivy into your CI/CD pipeline
2. **Exit-code handling**: Use `--exit-code` to fail builds with vulnerabilities
3. **Report customization**: Customize reports for relevant information
4. **Ignore file**: Use `.trivyignore` for false positives
5. **Cache management**: Mount cache volume for faster repeated scans
6. **Focus on fixable issues**: Prioritize vulnerabilities with available fixes

## Installing Trivy on dsb-node-01 (Infrastructure Node)

While Trivy is primarily integrated with your DevSecOps toolchain on dsb-hub, you may also want to run Trivy on dsb-node-01 to scan running containers, the host filesystem, or local images for vulnerabilities and misconfigurations.

### Manual Installation (Recommended)

1. Create a directory for Trivy (optional, for organizing scan reports or cache):

```bash
sudo mkdir -p /opt/dsb-homelab/trivy
```

2. Run Trivy as a one-off Docker container for scanning:

- Scan a running container (replace `<container_name>`):

```bash
docker run --rm --network host -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image <container_name>
```

- Scan the host filesystem (e.g., `/etc`, `/home`, or a project directory):

```bash
docker run --rm -v /:/host aquasec/trivy fs /host
```

- Scan a local image:

```bash
docker run --rm aquasec/trivy image <local_image_name>
```

3. (Optional) To run Trivy as a service on dsb-node-01, create a Docker Compose file at `/opt/dsb-homelab/trivy/docker-compose.yml` similar to the dsb-hub setup, but ensure the port does not conflict with other services:

```yaml
version: '3.8'
services:
  trivy:
    image: aquasec/trivy:latest
    container_name: trivy
    volumes:
      - trivy_cache:/root/.cache
    command: server --listen 0.0.0.0:8083
    ports:
      - "8083:8080"
    restart: unless-stopped
    networks:
      - devsecops
volumes:
  trivy_cache:
networks:
  devsecops:
    driver: bridge
```

Then start the service:

```bash
cd /opt/dsb-homelab/trivy
sudo docker-compose up -d
```

You can now access the Trivy server API on dsb-node-01 at `http://dsb-node-01:8083/healthz`.

### Notes
- Use Trivy on dsb-node-01 for scanning running containers, the host filesystem, or local images.
- For CI/CD and automated image/repo scanning, continue to use the Trivy setup on dsb-hub.
- Adjust ports as needed to avoid conflicts with other services.