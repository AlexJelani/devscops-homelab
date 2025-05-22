# SonarQube Setup Guide

SonarQube is an open-source platform for continuous inspection of code quality and security in our DevSecOps Home Lab.

## Overview

SonarQube offers:
- Code quality analysis
- Security vulnerability detection
- Test coverage reporting
- Technical debt management
- Integration with CI/CD pipelines

## Automatic Installation

SonarQube is installed automatically by the `setup-hub.sh` script. The configuration file is located at `/opt/dsb-homelab/sonarqube/docker-compose.yml`.

## Manual Installation

If you need to install SonarQube manually:

1. Create the necessary directory:

```bash
sudo mkdir -p /opt/dsb-homelab/sonarqube
```

2. Set kernel parameters required by SonarQube (Elasticsearch):

```bash
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

3. Create the Docker Compose file:

```bash
sudo nano /opt/dsb-homelab/sonarqube/docker-compose.yml
```

Add the following content:

```yaml
version: '3.8'

services:
  sonarqube:
    image: sonarqube:latest
    container_name: sonarqube
    depends_on:
      - sonarqube-db
    environment:
      - SONAR_JDBC_URL=jdbc:postgresql://sonarqube-db:5432/sonar
      - SONAR_JDBC_USERNAME=sonar
      - SONAR_JDBC_PASSWORD=sonar
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
    ports:
      - "9000:9000"
    networks:
      - devsecops
    ulimits:
      nofile:
        soft: 65536
        hard: 65536

  sonarqube-db:
    image: postgres:13
    container_name: sonarqube-db
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD=sonar
      - POSTGRES_DB=sonar
    volumes:
      - sonarqube_db:/var/lib/postgresql/data
    networks:
      - devsecops

volumes:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
  sonarqube_db:

networks:
  devsecops:
    driver: bridge
```

4. Start SonarQube:

```bash
cd /opt/dsb-homelab/sonarqube
sudo docker-compose up -d
```

## Initial Configuration

When you first access SonarQube at http://dsb-hub:9000, log in with the default credentials:
- Username: admin
- Password: admin

You'll be prompted to change the password. Choose a secure password and complete the setup.

## Installing Plugins

Install additional plugins to enhance SonarQube's capabilities:

1. Go to Administration > Marketplace
2. Search for and install:
   - SonarTS (TypeScript analysis)
   - SonarJS (JavaScript analysis)
   - SonarPython (Python analysis)
   - SonarJava (Java analysis)
   - SonarCSS (CSS analysis)
   - SonarHTML (HTML analysis)
   - OWASP Dependency-Check

3. Restart SonarQube after installing plugins:
   ```bash
   cd /opt/dsb-homelab/sonarqube
   sudo docker-compose restart
   ```

## Creating a Quality Gate

Quality Gates define the conditions that a project must meet to pass quality checks:

1. Go to Quality Gates > Create
2. Name: "DevSecOps Standard"
3. Add Conditions:
   - Metric: Coverage is less than 80%
   - Metric: Duplicated Lines (%) is greater than 3%
   - Metric: Maintainability Rating is worse than A
   - Metric: Reliability Rating is worse than A
   - Metric: Security Rating is worse than A
   - Metric: Security Hotspots Reviewed is less than 100%
4. Click "Save"
5. Set as Default

## Creating a Quality Profile

Quality Profiles define the set of rules to check in your code:

1. Go to Quality Profiles
2. Select a language (e.g., Java)
3. Click "Create" next to the language
4. Name: "DevSecOps Java"
5. Parent: Sonar way
6. Click "Create"
7. Click on your new profile
8. Go to "Activate More" and add security-focused rules
9. Set as Default

## Generating a Token for CI/CD Integration

To integrate SonarQube with Jenkins or other CI tools:

1. Click on your profile icon in the top right
2. Select "My Account"
3. Go to "Security" tab
4. Enter a name for your token (e.g., "jenkins-integration")
5. Click "Generate"
6. Copy the token and store it securely (it will only be shown once)

## Running Code Analysis

### Using SonarScanner

For Maven projects:

```bash
mvn sonar:sonar \
  -Dsonar.projectKey=my-project \
  -Dsonar.host.url=http://dsb-hub:9000 \
  -Dsonar.login=YOUR_TOKEN
```

For Gradle projects:

```bash
./gradlew sonarqube \
  -Dsonar.projectKey=my-project \
  -Dsonar.host.url=http://dsb-hub:9000 \
  -Dsonar.login=YOUR_TOKEN
```

For other project types:

```bash
sonar-scanner \
  -Dsonar.projectKey=my-project \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://dsb-hub:9000 \
  -Dsonar.login=YOUR_TOKEN
```

### Integration with Jenkins

In your Jenkinsfile:

```groovy
stage('SonarQube Analysis') {
    steps {
        withSonarQubeEnv('SonarQube') {
            sh 'mvn sonar:sonar'
        }
    }
}

stage('Quality Gate') {
    steps {
        timeout(time: 1, unit: 'HOURS') {
            waitForQualityGate abortPipeline: true
        }
    }
}
```

## Troubleshooting

### Common Issues

1. **Database connection errors**:
   - Check PostgreSQL container is running
   - Verify database credentials
   - Check logs for connectivity issues

2. **Elasticsearch errors**:
   - Verify `vm.max_map_count` is set correctly
   - Check system has enough memory (min 4GB recommended)
   - Review Elasticsearch logs

3. **Plugin compatibility issues**:
   - Ensure plugins are compatible with your SonarQube version
   - Update SonarQube if needed

### Viewing Logs

```bash
# View SonarQube logs
docker logs sonarqube

# View database logs
docker logs sonarqube-db
```

### Restarting SonarQube

```bash
cd /opt/dsb-homelab/sonarqube
sudo docker-compose restart
```

### Rebuilding SonarQube

If you need to rebuild your SonarQube instance:

```bash
cd /opt/dsb-homelab/sonarqube
sudo docker-compose down
sudo docker-compose up -d
```

## Best Practices

1. **Regular updates**: Keep SonarQube and its plugins updated
2. **Custom Quality Gates**: Define quality gates that match your organization's standards
3. **Branch analysis**: Configure branch analysis for feature branches
4. **Pull Request analysis**: Enable PR decoration for real-time feedback
5. **Developer training**: Train developers to understand SonarQube reports
6. **Integrate with CI/CD**: Run analysis as part of your CI/CD pipeline