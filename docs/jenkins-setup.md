# Jenkins Setup Guide

Jenkins is an open-source automation server that enables developers to build, test, and deploy their applications in our DevSecOps Home Lab.

## Overview

Jenkins provides:
- Continuous Integration and Continuous Delivery (CI/CD)
- Extensibility through plugins
- Integration with various tools in the DevSecOps ecosystem
- Automation of repetitive tasks

## Automatic Installation

Jenkins is installed automatically by the `setup-hub.sh` script. The configuration file is located at `/opt/dsb-homelab/jenkins/docker-compose.yml`.

## Manual Installation

If you need to install Jenkins manually:

1. Create the necessary directory:

```bash
sudo mkdir -p /opt/dsb-homelab/jenkins
```

2. Create the Docker Compose file:

```bash
sudo nano /opt/dsb-homelab/jenkins/docker-compose.yml
```

Add the following content:

```yaml
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    user: root
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - JAVA_OPTS=-Djenkins.install.runSetupWizard=false
    networks:
      - devsecops

  jenkins-agent:
    image: jenkins/inbound-agent:latest
    container_name: jenkins-agent
    user: root
    restart: unless-stopped
    depends_on:
      - jenkins
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - jenkins_agent_home:/home/jenkins/agent
    environment:
      - JENKINS_URL=http://jenkins:8080
      - JENKINS_AGENT_NAME=docker-agent
      - JENKINS_SECRET=jenkins-agent-secret
      - JENKINS_AGENT_WORKDIR=/home/jenkins/agent
    networks:
      - devsecops

volumes:
  jenkins_home:
  jenkins_agent_home:

networks:
  devsecops:
    driver: bridge
```

3. Start Jenkins:

```bash
cd /opt/dsb-homelab/jenkins
sudo docker-compose up -d
```

## Initial Configuration

When you first access Jenkins at http://dsb-hub:8080, you'll need to complete the initial setup:

1. Get the initial admin password:
   ```bash
   sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```

2. Follow the setup wizard:
   - Choose "Install suggested plugins"
   - Create an admin user
   - Set the Jenkins URL
   - Click "Start using Jenkins"

## Installing Essential Plugins

Install these plugins for DevSecOps capabilities:

1. Go to Manage Jenkins > Plugins > Available
2. Search for and install:
   - Docker Pipeline
   - Git
   - Pipeline
   - Blue Ocean
   - SonarQube Scanner
   - OWASP Dependency-Check
   - Gitea
   - HTML Publisher
   - Warnings Next Generation

## Configuring Tools

### SonarQube Integration

1. Go to Manage Jenkins > System Configuration > System
2. Scroll to SonarQube servers
3. Click "Add SonarQube"
4. Enter:
   - Name: SonarQube
   - Server URL: http://sonarqube:9000
   - Server authentication token: [Create a token in SonarQube]
5. Save

### Docker Configuration

1. Go to Manage Jenkins > System Configuration > Global Tool Configuration
2. Scroll to Docker
3. Click "Add Docker"
4. Enter:
   - Name: Docker
   - Installation method: Install automatically
5. Save

### Creating a Jenkins Pipeline for a Sample Application

Create a Jenkinsfile for a sample application:

```groovy
pipeline {
    agent any
    
    tools {
        jdk 'jdk11'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        
        stage('Static Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                sh 'docker run --rm -v $(pwd):/app aquasec/trivy:latest filesystem --no-progress /app'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t sample-app:${BUILD_NUMBER} .'
            }
        }
        
        stage('Deploy') {
            steps {
                sh 'docker run -d --name sample-app-${BUILD_NUMBER} -p 8081:8080 sample-app:${BUILD_NUMBER}'
            }
        }
    }
    
    post {
        always {
            emailext (
                subject: "Build ${currentBuild.result}: Job ${env.JOB_NAME}",
                body: "${currentBuild.result}: ${env.JOB_NAME} Build ${env.BUILD_NUMBER}\nSee details: ${env.BUILD_URL}",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }
    }
}
```

## Creating a Full DevSecOps Pipeline

1. In Jenkins, click "New Item"
2. Enter a name, select "Pipeline", and click "OK"
3. Configure the pipeline:
   - Description: DevSecOps Pipeline for Sample App
   - Pipeline:
     - Definition: Pipeline script from SCM
     - SCM: Git
     - Repository URL: http://gitea:3000/username/sample-app.git
     - Branch Specifier: */main
     - Script Path: Jenkinsfile
4. Click "Save"

## Troubleshooting

### Common Issues

1. **Jenkins won't start**:
   - Check Docker logs: `docker logs jenkins`
   - Verify volume permissions
   - Ensure the Docker socket is accessible

2. **Pipeline failures**:
   - Check the specific stage that failed
   - Review the console output for error messages
   - Verify tool configurations and credentials

3. **Integration issues**:
   - Check connectivity between Jenkins and other services
   - Verify URL configurations and credentials
   - Check network settings in Docker Compose

### Jenkins Agent Issues

To troubleshoot the Jenkins agent:

```bash
# View agent logs
docker logs jenkins-agent

# Restart the agent
docker restart jenkins-agent

# Verify agent is connected in Jenkins UI
# Go to Manage Jenkins > Manage Nodes and Clouds
```

### Resetting Jenkins

If you need to reset Jenkins:

```bash
cd /opt/dsb-homelab/jenkins
sudo docker-compose down
sudo docker volume rm jenkins_home
sudo docker-compose up -d
```

## Best Practices

1. **Use Pipeline as Code**: Store pipeline definitions in your repositories
2. **Implement security scans**: Include SAST, DAST, and dependency checks
3. **Use agents for isolation**: Run builds in agent containers
4. **Secure credentials**: Use Jenkins Credentials for sensitive information
5. **Regular backups**: Back up the Jenkins home directory regularly
6. **Monitor resource usage**: Ensure Jenkins has adequate resources