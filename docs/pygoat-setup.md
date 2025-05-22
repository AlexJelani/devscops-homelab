# PyGoat Vulnerability Testing Lab Setup

PyGoat is a deliberately vulnerable web application built with Python (Django) to learn and practice web security testing.

## Overview

PyGoat includes various vulnerabilities from the OWASP Top 10, such as:
- SQL Injection
- Cross-Site Scripting (XSS)
- Broken Authentication
- Insecure Deserialization
- Security Misconfigurations
- and more...

## Automatic Installation

PyGoat is installed automatically by the `setup-node.sh` script. The Docker Compose file is located at `/opt/dsb-homelab/pygoat/docker-compose.yml`.

## Manual Installation

If you need to install PyGoat manually:

1. Create the necessary directory:

```bash
sudo mkdir -p /opt/dsb-homelab/pygoat
```

2. Create the Docker Compose file:

```bash
sudo nano /opt/dsb-homelab/pygoat/docker-compose.yml
```

Add the following content:

```yaml
version: '3.8'

services:
  pygoat:
    image: adeyosemanputra/pygoat:latest
    container_name: pygoat
    ports:
      - "8000:8000"
    restart: unless-stopped
    command: sh -c "cd /app && python manage.py runserver 0.0.0.0:8000"
```

3. Start PyGoat:

```bash
cd /opt/dsb-homelab/pygoat
sudo docker-compose up -d
```

## Accessing PyGoat

PyGoat is accessible at: http://dsb-node-01:8000

## Using PyGoat for Vulnerability Testing

### Initial Setup

1. When you first access PyGoat, you'll need to register a new account
2. Log in with your credentials
3. You can now access the lessons and challenges

### Available Lessons

PyGoat contains various lessons and labs covering:

1. **A1: Injection**
   - SQL Injection
   - Command Injection

2. **A2: Broken Authentication**
   - Weak Password Policy
   - Insecure Session Management

3. **A3: Sensitive Data Exposure**
   - Insecure Storage of Sensitive Data
   - Transmission of Sensitive Data

4. **A7: Cross-Site Scripting (XSS)**
   - Stored XSS
   - Reflected XSS
   - DOM-based XSS

5. **A8: Insecure Deserialization**
   - Pickle Deserialization

6. **A9: Using Components with Known Vulnerabilities**
   - Outdated Libraries/Components

### Integration with DevSecOps Pipeline

PyGoat can be used as a target application for security testing tools in your CI/CD pipeline:

1. **OWASP ZAP Integration**:
   ```bash
   docker run -t owasp/zap2docker-stable zap-baseline.py -t http://dsb-node-01:8000
   ```

2. **Automated Security Scanning**:
   - Create a Jenkins pipeline job to scan PyGoat with security tools
   - Example Jenkinsfile snippet:
   ```groovy
   stage('Security Scan') {
       steps {
           sh 'docker run --rm -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-stable zap-baseline.py -t http://dsb-node-01:8000 -g gen.conf -r testreport.html'
       }
       post {
           always {
               publishHTML([
                   allowMissing: false,
                   alwaysLinkToLastBuild: true,
                   keepAll: true,
                   reportDir: '.',
                   reportFiles: 'testreport.html',
                   reportName: 'ZAP Security Scan Report'
               ])
           }
       }
   }
   ```

## Adding Your Own Vulnerable Code

You can extend PyGoat by adding your own vulnerable code for testing:

1. SSH into dsb-node-01
2. Access the PyGoat container:
   ```bash
   docker exec -it pygoat bash
   ```
3. Navigate to the app directory:
   ```bash
   cd /app
   ```
4. Create a new Django app or modify existing files to introduce vulnerabilities
5. Restart the PyGoat container:
   ```bash
   exit
   docker restart pygoat
   ```

## Troubleshooting

### Container Issues

If PyGoat isn't running properly:

```bash
# Check container status
docker ps -a | grep pygoat

# View container logs
docker logs pygoat

# Restart the container
docker restart pygoat

# Recreate the container
cd /opt/dsb-homelab/pygoat
docker-compose down
docker-compose up -d
```

### Access Issues

If you can't access PyGoat at http://dsb-node-01:8000:

1. Check the firewall settings:
   ```bash
   sudo ufw status
   sudo ufw allow 8000/tcp
   ```

2. Verify NGINX configuration:
   ```bash
   sudo nano /etc/nginx/sites-available/dsb-node
   # Ensure the PyGoat proxy_pass is correct
   sudo nginx -t
   sudo systemctl restart nginx
   ```

3. Check if the container is exposing the correct port:
   ```bash
   docker inspect pygoat | grep -A 10 Ports
   ```