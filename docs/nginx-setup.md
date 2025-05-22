# NGINX Setup Guide

NGINX serves as the reverse proxy in our DevSecOps Home Lab, routing requests to the appropriate services.

## Installation

NGINX is installed automatically by the setup scripts. If you need to install it manually:

```bash
sudo apt-get update
sudo apt-get install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
```

## Configuration

### For dsb-node-01

The default configuration for dsb-node-01 is in `/etc/nginx/sites-available/dsb-node`:

```nginx
server {
    listen 80;
    server_name dsb-node-01;

    location / {
        return 301 http://$host/grafana/;
    }

    location /grafana/ {
        proxy_pass http://localhost:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /prometheus/ {
        proxy_pass http://localhost:9090/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /pygoat/ {
        proxy_pass http://localhost:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### For dsb-hub

The default configuration for dsb-hub is in `/etc/nginx/sites-available/dsb-hub`:

```nginx
server {
    listen 80;
    server_name dsb-hub;

    location / {
        return 301 http://$host/gitea/;
    }

    location /gitea/ {
        proxy_pass http://localhost:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /jenkins/ {
        proxy_pass http://localhost:8080/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /sonarqube/ {
        proxy_pass http://localhost:9000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /nexus/ {
        proxy_pass http://localhost:8081/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Enabling the Configuration

To enable the configuration:

```bash
# For dsb-node-01
sudo ln -sf /etc/nginx/sites-available/dsb-node /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# For dsb-hub
sudo ln -sf /etc/nginx/sites-available/dsb-hub /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Restart NGINX
sudo systemctl restart nginx
```

## Adding SSL/TLS (Optional)

For a production environment, you may want to add SSL/TLS encryption:

1. Install Certbot for Let's Encrypt certificates:

```bash
sudo apt-get install -y certbot python3-certbot-nginx
```

2. Obtain and configure certificates:

```bash
sudo certbot --nginx -d your-domain.com
```

3. Follow the prompts to complete the certificate installation.

4. Certbot will automatically update your NGINX configuration to use HTTPS.

## Troubleshooting

If you encounter issues with NGINX:

1. Check the NGINX configuration syntax:

```bash
sudo nginx -t
```

2. View the NGINX logs:

```bash
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

3. Verify that the NGINX service is running:

```bash
sudo systemctl status nginx
```

4. Restart NGINX if needed:

```bash
sudo systemctl restart nginx
```