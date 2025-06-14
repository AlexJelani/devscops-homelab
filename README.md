## DevSecOps Homelab

**Author:** Damien Burks (Original Concept)
**Implementation:** Jelani Alexander

### Overview

Welcome to the DevSecOps Home Lab project! This project provides a comprehensive home lab environment designed to simulate a real-world infrastructure for testing, learning, and enhancing your DevSecOps skills. Leveraging Docker and Docker Compose, this lab provides hands-on experience with a variety of tools and technologies commonly used in the DevSecOps ecosystem.

Whether you're using physical servers at home or cloud-based virtual machines, this setup aims to provide a consistent and automated deployment process.

### Architecture Overview

The lab architecture is designed across two primary servers to separate infrastructure services from the core DevSecOps toolchain.

*(Note: You would typically include an Architecture Diagram here)*

#### Server: dsb-node-01

This server hosts essential infrastructure services, laying the foundation for containerized environments and monitoring.

-   **NGINX:** Acts as a web server and reverse proxy, routing incoming traffic to the appropriate service.
-   **Docker:** Provides containerization capabilities.
-   **Containerized Web Application (Pygoat):** An intentionally insecure web application for security training, running in a Docker container for testing and scanning.
-   **Prometheus:** Collects and monitors system and application metrics.
-   **Grafana:** Provides visual dashboards for observing metrics and logs.
-   **Node Exporter:** Collects host-level metrics for Prometheus.

#### Server: dsb-hub

Dedicated to handling the DevSecOps toolchain, this server focuses on source code management, security scanning, continuous integration, and continuous delivery (CI/CD).

-   **NGINX:** Handles traffic management and routing for services on this server.
-   **Gitea:** A lightweight, self-hosted Git service for version control.
-   **SonarQube:** Used for continuous code quality and security checks.
-   **Jenkins:** Automates the CI/CD pipeline.
-   **Trivy:** Provides vulnerability scanning and supply chain insights for container images.
-   **Nexus:** Manages dependencies, artifacts, and binaries.
-   **DefectDojo:** An open-source vulnerability management tool that streamlines the testing process.
-   **PostgreSQL:** Database for storing application data.
-   **Docker:** Used for containerizing applications and services.

### Current Setup

The current implementation focuses on the dsb-hub server, which hosts the core DevSecOps toolchain. All services are containerized using Docker and orchestrated with Docker Compose.

### Services and Access Points

All services are accessible through an NGINX reverse proxy that routes requests to the appropriate containers:

-   **Gitea:** `http://<server-ip>/gitea/` - Source code management
-   **Jenkins:** `http://<server-ip>/jenkins/` - CI/CD automation
-   **SonarQube:** `http://<server-ip>/sonarqube/` - Code quality and security analysis
-   **Nexus:** `http://<server-ip>/nexus/` - Artifact repository
-   **DefectDojo:** `http://<server-ip>:8083/` - Vulnerability management

Additionally, some services are accessible directly:

-   **Gitea (direct):** `http://<server-ip>:3000/`
-   **Jenkins (direct):** `http://<server-ip>:8080/jenkins/`
-   **SonarQube (direct):** `http://<server-ip>:9000/`
-   **Nexus (direct):** `http://<server-ip>:8081/`
-   **Trivy API:** `http://<server-ip>:8084/`
-   **PostgreSQL:** Port 5432 (accessible for database clients)

### Docker Compose Configuration

The Docker Compose configuration defines all services, their dependencies, networks, and volumes. Key features include:

-   **Service Configuration:** Each service is configured with appropriate environment variables and volume mappings.
-   **Persistent Storage:** Docker volumes are used to ensure data persistence across container restarts.
-   **Network Isolation:** Services communicate through a dedicated Docker network.
-   **Resource Management:** Services are configured with appropriate resource constraints.

### NGINX Configuration

NGINX is configured as a reverse proxy to route requests to the appropriate services. The configuration includes:

-   **Path-based Routing:** Each service is accessible through a specific path (e.g., `/gitea/`, `/jenkins/`).
-   **Header Management:** Appropriate headers are set for proxied requests.
-   **Default Routing:** Requests to the root path are redirected to Gitea.

### Database Configuration

PostgreSQL is used as the database for various services:

-   **SonarQube Database:** Stores SonarQube analysis data.
-   **DefectDojo Database:** Stores vulnerability management data.
-   **Application Database:** A separate PostgreSQL instance (postgres-todo) is available for application development.

### What You'll Learn

By working with this DevSecOps homelab, you will gain hands-on experience in:

-   **Docker & Docker Compose:** Deploying and managing multi-container applications.
-   **Containerization:** Understanding isolated application environments.
-   **Web Traffic Management:** Configuring NGINX as a reverse proxy.
-   **Security Scanning:** Using tools like SonarQube and Trivy.
-   **CI/CD Fundamentals:** Working with Jenkins pipelines.
-   **Artifact Management:** Using Nexus for dependency and artifact management.
-   **Vulnerability Management:** Using DefectDojo to track and manage vulnerabilities.
-   **Database Management:** Working with PostgreSQL databases.

### Maintenance and Troubleshooting

#### Common Tasks

-   **Viewing Logs:** `docker logs <container_name>`
-   **Restarting Services:** `docker restart <container_name>`
-   **Checking Service Status:** `docker ps`
-   **Accessing Container Shell:** `docker exec -it <container_name> bash`

#### Volume Management

All data is stored in Docker volumes to ensure persistence. You can list volumes with:
```bash
docker volume ls
```

#### Network Management

Services communicate through a Docker network. You can inspect the network with:
```bash
docker network inspect dsb-hub_devsecops
```

### Future Enhancements

Potential enhancements for this homelab include:

-   **SSL/TLS Configuration:** Adding HTTPS support with Let's Encrypt.
-   **Authentication Integration:** Implementing SSO across services.
-   **Monitoring and Alerting:** Adding Prometheus and Grafana for monitoring.
-   **CI/CD Pipeline Examples:** Creating example pipelines for common scenarios.
-   **Infrastructure as Code:** Adding Terraform configurations for cloud deployment.

### Contributing

Contributions to improve the DevSecOps homelab are welcome! Please feel free to submit pull requests or open issues for any improvements or bug fixes.

---

*(Based on the original concept by Damien Burks)*
