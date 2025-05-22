# DevSecOps Home Lab Troubleshooting Guide

This guide provides solutions for common issues you might encounter with your DevSecOps Home Lab.

## General Troubleshooting

### Checking Service Status

To check if a service is running:

```bash
# Check Docker container status
docker ps

# Check specific container
docker ps | grep container_name

# Check logs for a container
docker logs container_name

# Check system service status
systemctl status service_name
```

### Network Issues

If services cannot communicate with each other:

1. Check if containers are on the same network:
   ```bash
   docker network inspect devsecops
   ```

2. Verify firewall settings:
   ```bash
   sudo ufw status
   ```

3. Check NGINX configuration:
   ```bash
   sudo nginx -t
   sudo systemctl status nginx
   ```

4. Test connectivity between services:
   ```bash
   docker exec -it container_name ping other_container
   ```

### Storage Issues

If you're encountering disk space problems:

1. Check disk usage:
   ```bash
   df -h
   ```

2. Check Docker disk usage:
   ```bash
   docker system df
   ```

3. Prune unused Docker resources:
   ```bash
   docker system prune -a
   ```

## Common Server-Specific Issues

### dsb-node-01 Issues

#### Monitoring Stack Not Working

1. Check if Prometheus and Grafana containers are running:
   ```bash
   cd /opt/dsb-homelab/monitoring
   docker-compose ps
   ```

2. View Prometheus logs:
   ```bash
   docker logs prometheus
   ```

3. View Grafana logs:
   ```bash
   docker logs grafana
   ```

4. Restart the monitoring stack:
   ```bash
   cd /opt/dsb-homelab/monitoring
   docker-compose down
   docker-compose up -d
   ```

#### PyGoat Not Accessible

1. Check PyGoat container status:
   ```bash
   docker ps | grep pygoat
   ```

2. Check PyGoat logs:
   ```bash
   docker logs pygoat
   ```

3. Verify NGINX configuration for PyGoat:
   ```bash
   cat /etc/nginx/sites-available/dsb-node
   ```

4. Restart PyGoat:
   ```bash
   cd /opt/dsb-homelab/pygoat
   docker-compose down
   docker-compose up -d
   ```

### dsb-hub Issues

#### Gitea Issues

1. Check Gitea container status:
   ```bash
   docker ps | grep gitea
   ```

2. View Gitea logs:
   ```bash
   docker logs gitea
   ```

3. Check Gitea configuration:
   ```bash
   docker exec -it gitea cat /data/gitea/conf/app.ini
   ```

4. Restart Gitea:
   ```bash
   cd /opt/dsb-homelab/gitea
   docker-compose down
   docker-compose up -d
   ```

#### Jenkins Issues

1. Check Jenkins container status:
   ```bash
   docker ps | grep jenkins
   ```

2. View Jenkins logs:
   ```bash
   docker logs jenkins
   ```

3. Check Jenkins agent connection:
   ```bash
   docker logs jenkins-agent
   ```

4. Reset Jenkins admin password (if forgotten):
   ```bash
   docker exec -it jenkins bash
   cd /var/jenkins_home
   java -jar /usr/share/jenkins/jenkins.war securityReset
   ```

5. Restart Jenkins:
   ```bash
   cd /opt/dsb-homelab/jenkins
   docker-compose down
   docker-compose up -d
   ```

#### SonarQube Issues

1. Check SonarQube and database containers:
   ```bash
   docker ps | grep sonarqube
   ```

2. View SonarQube logs:
   ```bash
   docker logs sonarqube
   ```

3. Check Elasticsearch settings:
   ```bash
   sysctl vm.max_map_count
   ```

4. Restart SonarQube:
   ```bash
   cd /opt/dsb-homelab/sonarqube
   docker-compose down
   docker-compose up -d
   ```

#### Nexus Issues

1. Check Nexus container status:
   ```bash
   docker ps | grep nexus
   ```

2. View Nexus logs:
   ```bash
   docker logs nexus
   ```

3. Reset admin password (if forgotten):
   ```bash
   # Find the admin password
   docker exec -it nexus cat /nexus-data/admin.password
   
   # If that doesn't work, you may need to reset the database
   cd /opt/dsb-homelab/nexus
   docker-compose down
   # Remove the orient directory
   docker run --rm -v nexus_data:/data alpine rm -rf /data/db/component
   docker-compose up -d
   ```

4. Restart Nexus:
   ```bash
   cd /opt/dsb-homelab/nexus
   docker-compose down
   docker-compose up -d
   ```

## Docker Issues

### Container Won't Start

If a container fails to start:

1. Check container logs:
   ```bash
   docker logs container_name
   ```

2. Check for port conflicts:
   ```bash
   sudo netstat -tulpn | grep port_number
   ```

3. Inspect container configuration:
   ```bash
   docker inspect container_name
   ```

4. Rebuild the container:
   ```bash
   cd /path/to/docker-compose
   docker-compose down
   docker-compose up -d
   ```

### Docker Compose Issues

If docker-compose commands fail:

1. Verify docker-compose is installed:
   ```bash
   docker-compose --version
   ```

2. Check the docker-compose.yml file syntax:
   ```bash
   cd /path/to/docker-compose
   docker-compose config
   ```

3. Try running with verbose output:
   ```bash
   docker-compose --verbose up -d
   ```

## NGINX Issues

### Configuration Errors

If NGINX fails to start or doesn't route traffic correctly:

1. Check NGINX configuration syntax:
   ```bash
   sudo nginx -t
   ```

2. Check NGINX error logs:
   ```bash
   sudo tail -f /var/log/nginx/error.log
   ```

3. Check NGINX access logs:
   ```bash
   sudo tail -f /var/log/nginx/access.log
   ```

4. Restart NGINX:
   ```bash
   sudo systemctl restart nginx
   ```

## CI/CD Pipeline Issues

### Jenkins Pipeline Failures

If Jenkins pipelines fail:

1. Check the stage that failed in the Jenkins UI
2. Verify credentials are configured correctly
3. Check connection to other services (Gitea, SonarQube, etc.)
4. Validate Jenkinsfile syntax

### SonarQube Analysis Failures

If SonarQube analysis fails:

1. Check if SonarQube is running
2. Verify project configuration (sonar-project.properties or pom.xml)
3. Check if token is valid and has correct permissions
4. Look for analysis logs in Jenkins console output

## Recovering from Corruption

If a service becomes corrupted and unrecoverable through normal means:

1. Back up any important data if possible
2. Remove the Docker volumes:
   ```bash
   docker volume rm volume_name
   ```
3. Recreate the service:
   ```bash
   cd /opt/dsb-homelab/service_dir
   docker-compose down
   docker-compose up -d
   ```

## Getting Help

If you've tried the steps in this guide and still can't resolve your issue:

1. Check Docker and service documentation
2. Search for similar issues on Stack Overflow or GitHub
3. Try to isolate the issue to a specific component
4. Document the steps you've tried and the exact error messages
5. Report the issue with all relevant details