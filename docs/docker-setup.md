# Docker Setup Guide

Docker provides containerization capabilities for our DevSecOps Home Lab, allowing applications and services to run in isolated environments.

## Installation

Docker is installed automatically by the setup scripts. If you need to install it manually:

```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to the docker group to run Docker without sudo
sudo usermod -aG docker $USER
```

Log out and log back in for the group changes to take effect.

## Installing Docker Compose

Docker Compose is also installed automatically. For manual installation:

```bash
# Get the latest Docker Compose version
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)

# Download and install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make it executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify the installation
docker-compose --version
```

## Common Docker Operations

### Viewing Running Containers

```bash
docker ps
```

### Viewing All Containers (Including Stopped)

```bash
docker ps -a
```

### Starting, Stopping, and Restarting Containers

```bash
# Start a container
docker start container_name

# Stop a container
docker stop container_name

# Restart a container
docker restart container_name
```

### Viewing Container Logs

```bash
docker logs container_name

# Follow logs
docker logs -f container_name
```

### Executing Commands Inside Containers

```bash
docker exec -it container_name command

# Example: Open a shell in a container
docker exec -it container_name bash
```

### Docker Compose Operations

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs

# Follow logs for all services
docker-compose logs -f

# View logs for a specific service
docker-compose logs -f service_name
```

## Troubleshooting Docker

### Common Issues

1. **Permission denied**: Ensure you've added your user to the docker group and logged out/in.

2. **Cannot connect to the Docker daemon**: Ensure the Docker service is running.
   ```bash
   sudo systemctl status docker
   sudo systemctl start docker
   ```

3. **Disk space issues**: Remove unused containers, images, and volumes.
   ```bash
   # Remove stopped containers
   docker container prune
   
   # Remove unused images
   docker image prune
   
   # Remove unused volumes
   docker volume prune
   
   # Remove all unused objects (containers, images, volumes, networks)
   docker system prune
   ```

4. **Network issues**: Restart the Docker service or check networking configurations.
   ```bash
   sudo systemctl restart docker
   ```

## Best Practices

1. **Use Docker Compose** for managing multi-container applications
2. **Don't run containers as root** when possible
3. **Use specific image tags** rather than `latest`
4. **Implement resource limits** to prevent container resource starvation
5. **Regularly update images** to receive security patches
6. **Use volumes** for persistent data storage