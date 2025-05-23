## devscops-homelab

**Author:** Damien Burks (Original Concept)
**Implementation:** [Jelani Alexander]

### Overview

Welcome to the DevSecOps Home Lab project! This project guides you through setting up a comprehensive home lab environment designed to simulate a real-world infrastructure for testing, learning, and enhancing your DevSecOps skills. Leveraging Infrastructure as Code (Terraform) and cloud-init for automation, this lab provides hands-on experience with a variety of tools and technologies commonly used in the DevSecOps ecosystem, all deployed using Docker and Docker Compose.

Whether you're using physical servers at home or cloud-based virtual machines, this setup aims to provide a consistent and automated deployment process.

### Architecture Overview

The lab architecture is designed across two primary servers to separate infrastructure services from the core DevSecOps toolchain.

*(Note: You would typically include an Architecture Diagram here)*

#### Server: dsb-node-01

This server hosts essential infrastructure services, laying the foundation for containerized environments and monitoring.

-   **NGINX:** Acts as a web server and reverse proxy, routing incoming traffic to the appropriate service.
-   **Docker:** Provides containerization capabilities.
-   **Containerized Web Application (Juice Shop):** An intentionally insecure web application for security training, running in a Docker container for testing and scanning.
-   **Prometheus:** Collects and monitors system and application metrics.
-   **Grafana:** Provides visual dashboards for observing metrics and logs.
-   **Node Exporter:** Collects host-level metrics for Prometheus.

#### Server: dsb-hub

Dedicated to handling the DevSecOps toolchain, this server focuses on source code management, security scanning, continuous integration, and continuous delivery (CI/CD).

-   **NGINX:** Handles traffic management and routing for services on this server.
-   **Gitea:** A lightweight, self-hosted Git service for version control.
-   **SonarQube:** Used for continuous code quality and security checks.
-   **Jenkins:** Automates the CI/CD pipeline.
-   **Docker Scout:** Provides vulnerability scanning and supply chain insights for container images.
-   **Nexus:** Manages dependencies, artifacts, and binaries.
-   **Docker:** Used for containerizing applications and services.

### Prerequisites

Before you begin, ensure you have the following:

-   An Oracle Cloud Infrastructure (OCI) account with necessary permissions to create Compute instances, VCNs, Subnets, Security Lists, and Internet Gateways.
-   Terraform installed locally.
-   OCI CLI configured locally and authenticated to your tenancy. Terraform will use this configuration.
-   An SSH key pair. The public key will be injected into the instances by Terraform for access. Ensure your public key file path is correctly configured in your Terraform variables (e.g., `variables.tf`).
-   (Optional but Recommended) Docker and Docker Compose installed locally if you plan to test or build images locally before deployment.

### Setup

This project uses Terraform to provision the OCI infrastructure and cloud-init to automatically configure the instances and deploy services using Docker Compose on first boot.

1.  **Navigate to the Terraform directory:**
    ```bash
    cd terraform
    ```

2.  **Initialize Terraform:**
    ```bash
    terraform init
    ```
    This downloads the necessary OCI provider plugin.

3.  **Review the Plan:**
    ```bash
    terraform plan
    ```
    Review the proposed infrastructure changes. This should show 9 resources to be added (VCN, subnets, security lists, internet gateway, route table, and the two compute instances). Pay attention to the security list ingress rules to ensure the necessary ports (especially 22 for SSH and 80 for NGINX) are open from your IP or `0.0.0.0/0` for testing.

4.  **Apply the Configuration:**
    ```bash
    terraform apply
    ```
    Type `yes` when prompted to create the resources. Terraform will provision the VCN, subnets, security lists, and launch the two compute instances.

5.  **Wait for Cloud-init to Complete:**
    Once `terraform apply` finishes, the instances will begin booting. The cloud-init scripts embedded by Terraform will automatically run. This process involves:
    -   Updating packages.
    -   Installing Docker and the Docker Compose plugin.
    -   Writing the `docker-compose.yml` and NGINX configuration files to `/opt/dsb-homelab/` (on dsb-node-01) and `/opt/dsb-hub/` (on dsb-hub).
    -   Adding the `ubuntu` user to the `docker` group.
    -   Pulling all necessary Docker images.
    -   Starting all services using `docker compose up -d`.

    This process can take **5-15 minutes** or longer depending on network speed and the number of images.

6.  **Verify Deployment (Optional but Recommended):**
    -   After waiting, SSH into each instance using the public IPs provided in the `terraform apply` output (e.g., `ssh ubuntu@<dsb-node-01-public-ip>`).
    -   Check the cloud-init logs: `cat /var/log/cloud-init-output.log`
    -   Verify Docker is running: `systemctl status docker`
    -   Check running containers: `docker ps`

### Accessing the Lab

Once cloud-init has completed and the containers are running, you can access the services via the public IP addresses of the instances using the NGINX reverse proxies.

-   **dsb-node-01 (Monitoring & App):** `http://<dsb-node-01-public-ip>/`
    -   Prometheus: `http://<dsb-node-01-public-ip>/prometheus/`
    -   Grafana: `http://<dsb-node-01-public-ip>/grafana/`
    -   Juice Shop: `http://<dsb-node-01-public-ip>/juiceshop/` *(Assuming the Nginx path is `/juiceshop/`. Adjust if different.)*

-   **dsb-hub (DevSecOps Tools):** `http://<dsb-hub-public-ip>/`
    -   Gitea: `http://<dsb-hub-public-ip>/gitea/`
    -   Jenkins: `http://<dsb-hub-public-ip>/jenkins/`
    -   SonarQube: `http://<dsb-hub-public-ip>/sonarqube/`
    -   Nexus: `http://<dsb-hub-public-ip>/nexus/`
    -   Trivy API (if exposed via Nginx): `http://<dsb-hub-public-ip>/trivyapi/`

*(Note: Replace `<dsb-node-01-public-ip>` and `<dsb-hub-public-ip>` with the actual IPs from your `terraform apply` output.)*

### Post-Deployment Configuration (Important!)

While cloud-init automates the initial setup, most of the web applications (Gitea, Jenkins, SonarQube, Grafana, Nexus) need to be configured *internally* to correctly handle being served under a sub-path by NGINX (e.g., `/gitea/` instead of `/`).

You will likely need to SSH into the instances and configure each application's base URL or context path. Refer to the comments in the NGINX configuration files (`cloud-init/dsb-node-01.yaml` and `cloud-init/dsb-hub.yaml`) and the documentation for each specific tool for details on how to set their context paths or root URLs.

For example:
-   **Grafana:** Ensure the `GF_SERVER_ROOT_URL` environment variable is set correctly (e.g., `http://<dsb-node-01-public-ip>/grafana/`). This is attempted in the cloud-init, but you may need to adjust the IP.
-   **Gitea:** Edit the `app.ini` file inside the Gitea container and set `ROOT_URL`.
-   **Jenkins:** Configure the "Jenkins URL" in the Jenkins web UI under "Manage Jenkins" -> "Configure System". You might also need a startup parameter.
-   **SonarQube:** Set the `sonar.web.context` property.
-   **Nexus:** Configure the context path in its properties file.

Failure to perform these steps will result in broken links and incorrect behavior when accessing the applications via NGINX.

### What You'll Learn

By completing this project, you will gain hands-on experience in:

-   **Infrastructure as Code:** Using Terraform to provision cloud resources (OCI).
-   **Cloud-init:** Automating server configuration on first boot.
-   **Docker & Docker Compose:** Deploying and managing multi-container applications.
-   **Containerization:** Understanding isolated application environments.
-   **Web Traffic Management:** Configuring Nginx as a reverse proxy.
-   **Monitoring:** Setting up Prometheus and Grafana.
-   **Security Scanning:** Integrating tools like SonarQube and Trivy.
-   **CI/CD Fundamentals:** Working with Jenkins.
-   **Artifact Management:** Using Nexus.

### Cleanup

To destroy the resources created by Terraform and avoid incurring costs, navigate back to the `terraform` directory and run:

```bash
terraform destroy
```
Type `yes` when prompted. This will tear down all the infrastructure components created by your Terraform configuration.

### Contributing

*(Optional: Add information on how others can contribute if this is a public repository)*

### License

*(Optional: Add license information)*

---

*(Based on the original concept by Damien Burks)*
