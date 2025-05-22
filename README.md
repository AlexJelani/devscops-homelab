# DevSecOps Home Lab

**Author:** Damien Burks (Implementation by Bolt)

## Overview

This repository contains everything you need to set up a comprehensive DevSecOps Home Lab in the Oracle Cloud Infrastructure (OCI) Free Tier. The lab simulates a real-world environment for testing, learning, and enhancing your DevSecOps skills with hands-on experience using various tools and technologies.

## Architecture

The architecture is divided across two servers:

![Architecture Diagram](https://i.ibb.co/cXW65fq/devsecops-architecture.png)

### Server 1: dsb-node-01
This server is responsible for hosting essential infrastructure services:
- NGINX: Web server and reverse proxy
- Docker: Containerization engine
- Containerized Web Application (includes PyGoat)
- Prometheus: Metrics collection and monitoring
- Grafana: Visual dashboards for system metrics

### Server 2: dsb-hub
This server hosts the DevSecOps toolchain:
- NGINX: Web server and reverse proxy
- Gitea: Self-hosted Git service
- SonarQube: Code quality and security scanning
- Jenkins: CI/CD automation
- Trivy: Container vulnerability scanning
- Nexus: Repository manager
- Docker: Containerization engine

## Prerequisites

- Oracle Cloud Infrastructure (OCI) Free Tier account
- Terraform installed on your local machine
- OCI CLI configured with API key
- Basic understanding of Linux commands
- SSH client installed on your local machine

## Getting Started

### 1. Setting Up OCI Infrastructure with Terraform

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/devsecops-homelab.git
   cd devsecops-homelab
   ```

2. Configure Terraform:
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Edit `terraform.tfvars` with your OCI credentials and configuration:
   ```hcl
   tenancy_ocid     = "your_tenancy_ocid"
   user_ocid        = "your_user_ocid"
   fingerprint      = "your_api_key_fingerprint"
   private_key_path = "path_to_your_private_key"
   region           = "your_region"
   compartment_ocid = "your_compartment_ocid"
   ```

4. Initialize and apply Terraform configuration:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

5. Note the output IP addresses for both servers.

### 2. Installing Base Components

1. SSH into each server and run the initial setup scripts:
   - For dsb-node-01: `bash <(curl -s https://raw.githubusercontent.com/yourusername/devsecops-homelab/main/scripts/setup-node.sh)`
   - For dsb-hub: `bash <(curl -s https://raw.githubusercontent.com/yourusername/devsecops-homelab/main/scripts/setup-hub.sh)`

### 3. Configuring Individual Services

Follow the detailed guides for each service:
- [NGINX Configuration](docs/nginx-setup.md)
- [Docker Setup](docs/docker-setup.md)
- [Prometheus & Grafana](docs/monitoring-setup.md)
- [Gitea Configuration](docs/gitea-setup.md)
- [Jenkins Pipeline Setup](docs/jenkins-setup.md)
- [SonarQube Integration](docs/sonarqube-setup.md)
- [Trivy Scanner Setup](docs/trivy-setup.md)
- [Nexus Repository](docs/nexus-setup.md)
- [PyGoat Vulnerability Lab](docs/pygoat-setup.md)

## Accessing Your Services

Once setup is complete, you can access all services through your browser:

| Service    | URL                            |
|------------|---------------------------------|
| Grafana    | http://dsb-node-01:3000        |
| Prometheus | http://dsb-node-01:9090        |
| PyGoat     | http://dsb-node-01:8000        |
| Gitea      | http://dsb-hub:3000            |
| Jenkins    | http://dsb-hub:8080            |
| SonarQube  | http://dsb-hub:9000            |
| Nexus      | http://dsb-hub:8081            |

## Learning Paths

This home lab is designed to help you learn various aspects of DevSecOps:

1. **Infrastructure as Code**: Learn how to provision and manage cloud infrastructure using Terraform
2. **Infrastructure Management**: Learn how to set up and maintain containerized applications
3. **Monitoring and Observability**: Use Prometheus and Grafana to monitor system health
4. **Security Testing**: Practice vulnerability scanning with Trivy and PyGoat
5. **CI/CD Pipeline**: Build automated workflows with Jenkins and integrate with security tools
6. **Code Quality**: Implement code quality checks with SonarQube

## Troubleshooting

Check the [troubleshooting guide](docs/troubleshooting.md) for common issues and their solutions.

## Contributing

Feel free to submit issues or pull requests to improve this home lab setup.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.