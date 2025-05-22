# Gitea Setup Guide

Gitea is a lightweight, self-hosted Git service that provides source code management in our DevSecOps Home Lab.

## Overview

Gitea provides features similar to GitHub, GitLab, or Bitbucket, including:
- Git repository management
- Issue tracking
- Code review
- Wiki
- Webhooks for CI/CD integration

## Automatic Installation

Gitea is installed automatically by the `setup-hub.sh` script. The configuration file is located at `/opt/dsb-homelab/gitea/docker-compose.yml`.

## Manual Installation

If you need to install Gitea manually:

1. Create the necessary directory:

```bash
sudo mkdir -p /opt/dsb-homelab/gitea
```

2. Create the Docker Compose file:

```bash
sudo nano /opt/dsb-homelab/gitea/docker-compose.yml
```

Add the following content:

```yaml
version: '3.8'

services:
  gitea:
    image: gitea/gitea:latest
    container_name: gitea
    environment:
      - USER_UID=1000
      - USER_GID=1000
      - GITEA__database__DB_TYPE=sqlite3
      - GITEA__database__PATH=/data/gitea/gitea.db
    restart: unless-stopped
    volumes:
      - gitea_data:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    ports:
      - "3000:3000"
      - "222:22"

volumes:
  gitea_data:
```

3. Start Gitea:

```bash
cd /opt/dsb-homelab/gitea
sudo docker-compose up -d
```

## Initial Configuration

When you first access Gitea at http://dsb-hub:3000, you'll need to complete the initial setup:

1. **Database Settings**:
   - Database Type: SQLite3
   - Path: /data/gitea/gitea.db

2. **General Settings**:
   - Site Title: DevSecOps Home Lab
   - Repository Root Path: /data/git/repositories
   - Git LFS Root Path: /data/git/lfs
   - Run As Username: git
   - SSH Server Domain: dsb-hub
   - SSH Port: 222
   - Gitea HTTP Listen Port: 3000
   - Gitea Base URL: http://dsb-hub:3000/
   - Log Path: /data/gitea/log

3. **Admin Account Settings**:
   - Username: admin
   - Password: [choose a secure password]
   - Email: admin@example.com

4. Click "Install Gitea" to complete the setup.

## Creating Repositories

1. Log in with your admin account
2. Click the "+" icon in the top right corner
3. Select "New Repository"
4. Fill in the repository details:
   - Owner: Your username
   - Repository Name: e.g., "sample-app"
   - Description: Optional description
   - Visibility: Select Public or Private
5. Click "Create Repository"

## Setting Up SSH Access

To use SSH for Git operations:

1. Generate an SSH key pair if you don't already have one:
   ```bash
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```

2. Copy your public key:
   ```bash
   cat ~/.ssh/id_rsa.pub
   ```

3. In Gitea, go to Settings > SSH Keys
4. Click "Add Key"
5. Paste your public key and add a title
6. Click "Add Key"

7. Configure your SSH client by adding the following to `~/.ssh/config`:
   ```
   Host dsb-hub-gitea
     HostName dsb-hub
     Port 222
     User git
     IdentityFile ~/.ssh/id_rsa
   ```

8. Clone a repository using SSH:
   ```bash
   git clone ssh://git@dsb-hub-gitea:222/username/repository.git
   ```

## Integrating with Jenkins

To set up CI/CD with Jenkins:

1. In Gitea, navigate to your repository
2. Go to Settings > Webhooks
3. Click "Add Webhook" > "Gitea"
4. Configure the webhook:
   - Target URL: http://jenkins:8080/gitea-webhook/post
   - HTTP Method: POST
   - Trigger On: Push, Create, Pull Request
   - Branch Filter: *
5. Click "Add Webhook"

## Backup and Restore

### Backing Up Gitea

```bash
# Stop Gitea
cd /opt/dsb-homelab/gitea
sudo docker-compose down

# Create a backup directory
sudo mkdir -p /opt/dsb-homelab/backups/gitea

# Backup the data volume
sudo docker run --rm -v gitea_data:/data -v /opt/dsb-homelab/backups/gitea:/backup alpine tar -czf /backup/gitea-data-$(date +%Y%m%d).tar.gz -C /data ./

# Restart Gitea
sudo docker-compose up -d
```

### Restoring Gitea

```bash
# Stop Gitea
cd /opt/dsb-homelab/gitea
sudo docker-compose down

# Restore from backup
sudo docker run --rm -v gitea_data:/data -v /opt/dsb-homelab/backups/gitea:/backup alpine sh -c "rm -rf /data/* && tar -xzf /backup/gitea-data-20230101.tar.gz -C /data"

# Restart Gitea
sudo docker-compose up -d
```

## Troubleshooting

### Common Issues

1. **Cannot access Gitea**:
   - Check if the container is running: `docker ps | grep gitea`
   - View container logs: `docker logs gitea`
   - Check NGINX configuration and restart if necessary

2. **SSH connection issues**:
   - Verify the SSH port is correct (222)
   - Check SSH key permissions: `chmod 600 ~/.ssh/id_rsa`
   - Test SSH connection: `ssh -T -p 222 git@dsb-hub`

3. **Database issues**:
   - Check database configuration in app.ini
   - Verify SQLite file permissions if using SQLite

4. **Performance issues**:
   - Adjust cache settings in app.ini
   - Consider upgrading to a database like PostgreSQL for larger installations

### Viewing Logs

```bash
# View container logs
docker logs gitea

# Follow container logs
docker logs -f gitea
```

### Restart Gitea

```bash
cd /opt/dsb-homelab/gitea
sudo docker-compose restart
```