# Nexus Repository Setup Guide

Nexus Repository Manager is a repository manager that allows you to store and manage artifacts in our DevSecOps Home Lab.

## Overview

Nexus provides:
- Storage for binary artifacts (JARs, WARs, Docker images, npm packages, etc.)
- Proxy repositories for caching remote artifacts
- Private repositories for your own artifacts
- Group repositories for consolidating multiple repositories
- Integration with CI/CD tools

## Automatic Installation

Nexus is installed automatically by the `setup-hub.sh` script. The configuration file is located at `/opt/dsb-homelab/nexus/docker-compose.yml`.

## Manual Installation

If you need to install Nexus manually:

1. Create the necessary directory:

```bash
sudo mkdir -p /opt/dsb-homelab/nexus
```

2. Create the Docker Compose file:

```bash
sudo nano /opt/dsb-homelab/nexus/docker-compose.yml
```

Add the following content:

```yaml
version: '3.8'

services:
  nexus:
    image: sonatype/nexus3:latest
    container_name: nexus
    volumes:
      - nexus_data:/nexus-data
    ports:
      - "8081:8081"
    restart: unless-stopped
    networks:
      - devsecops

volumes:
  nexus_data:

networks:
  devsecops:
    driver: bridge
```

3. Start Nexus:

```bash
cd /opt/dsb-homelab/nexus
sudo docker-compose up -d
```

## Initial Configuration

When you first access Nexus at http://dsb-hub:8081:

1. Log in with the default credentials:
   - Username: admin
   - Password: Located in `/nexus-data/admin.password` inside the container
     ```bash
     sudo docker exec -it nexus cat /nexus-data/admin.password
     ```

2. Change the default password when prompted
3. Complete the initial setup wizard

## Creating Repositories

### Maven Repositories

1. Go to Server Administration and Configuration > Repositories > Repositories
2. Click "Create repository" > "maven2 (hosted)"
3. Enter:
   - Name: maven-releases
   - Version policy: Release
   - Deployment policy: Allow redeploy
4. Click "Create repository"

5. Create a Maven proxy repository:
   - Click "Create repository" > "maven2 (proxy)"
   - Name: maven-central-proxy
   - Remote storage: https://repo1.maven.org/maven2/
   - Click "Create repository"

6. Create a Maven group repository:
   - Click "Create repository" > "maven2 (group)"
   - Name: maven-all
   - Member repositories: Add maven-releases and maven-central-proxy
   - Click "Create repository"

### Docker Repositories

1. Go to Server Administration and Configuration > Repositories > Repositories
2. Click "Create repository" > "docker (hosted)"
3. Enter:
   - Name: docker-internal
   - HTTP: Check and use port 8082
   - Enable Docker V1 API: Check
4. Click "Create repository"

5. Create a Docker proxy repository:
   - Click "Create repository" > "docker (proxy)"
   - Name: docker-hub-proxy
   - Remote storage: https://registry-1.docker.io
   - Docker Index: Use Docker Hub
   - HTTP: Check and use port 8083
   - Click "Create repository"

6. Create a Docker group repository:
   - Click "Create repository" > "docker (group)"
   - Name: docker-all
   - HTTP: Check and use port 8084
   - Member repositories: Add docker-internal and docker-hub-proxy
   - Click "Create repository"

### npm Repositories

1. Click "Create repository" > "npm (hosted)"
2. Enter:
   - Name: npm-internal
3. Click "Create repository"

4. Create an npm proxy repository:
   - Click "Create repository" > "npm (proxy)"
   - Name: npm-registry-proxy
   - Remote storage: https://registry.npmjs.org
   - Click "Create repository"

5. Create an npm group repository:
   - Click "Create repository" > "npm (group)"
   - Name: npm-all
   - Member repositories: Add npm-internal and npm-registry-proxy
   - Click "Create repository"

## Creating Users and Roles

### Creating a Role

1. Go to Server Administration and Configuration > Security > Roles
2. Click "Create role" > "Nexus role"
3. Enter:
   - Role ID: developer
   - Role Name: Developer
   - Privileges: Select appropriate privileges (e.g., nx-repository-view-*-*-read, nx-repository-view-*-*-browse)
4. Click "Create role"

### Creating a User

1. Go to Server Administration and Configuration > Security > Users
2. Click "Create local user"
3. Enter:
   - ID: developer
   - First Name: Developer
   - Last Name: User
   - Email: developer@example.com
   - Password: [choose a secure password]
   - Status: Active
   - Roles: Add the developer role
4. Click "Create local user"

## Integrating with Maven

Configure Maven to use Nexus:

1. Edit `~/.m2/settings.xml`:

```xml
<settings>
  <mirrors>
    <mirror>
      <id>nexus</id>
      <mirrorOf>*</mirrorOf>
      <url>http://dsb-hub:8081/repository/maven-all/</url>
    </mirror>
  </mirrors>
  <servers>
    <server>
      <id>nexus</id>
      <username>admin</username>
      <password>your-password</password>
    </server>
  </servers>
</settings>
```

2. In your project's `pom.xml`:

```xml
<distributionManagement>
  <repository>
    <id>nexus</id>
    <name>Releases</name>
    <url>http://dsb-hub:8081/repository/maven-releases/</url>
  </repository>
  <snapshotRepository>
    <id>nexus</id>
    <name>Snapshots</name>
    <url>http://dsb-hub:8081/repository/maven-snapshots/</url>
  </snapshotRepository>
</distributionManagement>
```

## Integrating with Docker

1. Configure Docker to use Nexus:

```bash
sudo nano /etc/docker/daemon.json
```

Add the following:

```json
{
  "insecure-registries": ["dsb-hub:8084"]
}
```

2. Restart Docker:

```bash
sudo systemctl restart docker
```

3. Log in to Nexus Docker repository:

```bash
docker login dsb-hub:8084 -u admin -p your-password
```

4. Push an image to Nexus:

```bash
docker tag myimage:latest dsb-hub:8084/myimage:latest
docker push dsb-hub:8084/myimage:latest
```

5. Pull an image from Nexus:

```bash
docker pull dsb-hub:8084/myimage:latest
```

## Integrating with npm

1. Configure npm to use Nexus:

```bash
npm config set registry http://dsb-hub:8081/repository/npm-all/
```

2. Set up authentication:

```bash
npm login --registry=http://dsb-hub:8081/repository/npm-all/
```

3. Publish a package to Nexus:

```bash
npm publish --registry=http://dsb-hub:8081/repository/npm-internal/
```

## Backup and Restore

### Backing Up Nexus

```bash
# Stop Nexus
cd /opt/dsb-homelab/nexus
sudo docker-compose down

# Create a backup directory
sudo mkdir -p /opt/dsb-homelab/backups/nexus

# Backup the data volume
sudo docker run --rm -v nexus_data:/data -v /opt/dsb-homelab/backups/nexus:/backup alpine tar -czf /backup/nexus-data-$(date +%Y%m%d).tar.gz -C /data ./

# Restart Nexus
sudo docker-compose up -d
```

### Restoring Nexus

```bash
# Stop Nexus
cd /opt/dsb-homelab/nexus
sudo docker-compose down

# Restore from backup
sudo docker run --rm -v nexus_data:/data -v /opt/dsb-homelab/backups/nexus:/backup alpine sh -c "rm -rf /data/* && tar -xzf /backup/nexus-data-20230101.tar.gz -C /data"

# Restart Nexus
sudo docker-compose up -d
```

## Troubleshooting

### Common Issues

1. **Cannot access Nexus**:
   - Check if the container is running: `docker ps | grep nexus`
   - View container logs: `docker logs nexus`
   - Verify adequate system resources (Nexus needs at least 4GB RAM)

2. **Repository connection issues**:
   - Check network connectivity between services
   - Verify repository URLs are correct
   - Check credentials in settings files

3. **Upload/download problems**:
   - Verify user permissions
   - Check disk space
   - Confirm repository deployment policies

### Viewing Logs

```bash
docker logs nexus
```

### Restart Nexus

```bash
cd /opt/dsb-homelab/nexus
sudo docker-compose restart
```

## Best Practices

1. **Regular backups**: Schedule regular backups of Nexus data
2. **Resource allocation**: Ensure adequate memory and disk space
3. **Repository cleanup**: Implement cleanup policies to manage disk usage
4. **Security**: Use HTTPS for production environments
5. **Role-based access**: Implement fine-grained access control
6. **Documentation**: Document repository structure and usage for your team