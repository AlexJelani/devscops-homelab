# Prometheus and Grafana Setup Guide

This guide covers the setup and configuration of Prometheus and Grafana for monitoring in our DevSecOps Home Lab.

## Overview

- **Prometheus**: An open-source monitoring and alerting toolkit designed for reliability and scalability
- **Grafana**: A multi-platform analytics and interactive visualization web application

## Automatic Installation

The monitoring stack is installed automatically by the `setup-node.sh` script. The configuration files are located in `/opt/dsb-homelab/monitoring/`.

## Manual Installation

If you need to install manually:

1. Create the necessary directories:

```bash
sudo mkdir -p /opt/dsb-homelab/monitoring/prometheus
```

2. Create the Docker Compose configuration file:

```bash
sudo nano /opt/dsb-homelab/monitoring/docker-compose.yml
```

Add the following content:

```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./prometheus:/etc/prometheus
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
    ports:
      - "9090:9090"
    restart: unless-stopped
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    volumes:
      - grafana_data:/var/lib/grafana
    ports:
      - "3000:3000"
    restart: unless-stopped
    networks:
      - monitoring
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=devsecopshomelab
      - GF_USERS_ALLOW_SIGN_UP=false

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    restart: unless-stopped
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    expose:
      - 9100
    networks:
      - monitoring

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    restart: unless-stopped
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    expose:
      - 8080
    networks:
      - monitoring

networks:
  monitoring:
    driver: bridge

volumes:
  prometheus_data:
  grafana_data:
```

3. Create the Prometheus configuration:

```bash
sudo nano /opt/dsb-homelab/monitoring/prometheus/prometheus.yml
```

Add the following content:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
```

4. Start the monitoring stack:

```bash
cd /opt/dsb-homelab/monitoring
sudo docker-compose up -d
```

## Accessing the Monitoring Tools

- **Prometheus**: http://dsb-node-01:9090
- **Grafana**: http://dsb-node-01:3000 (Login: admin/devsecopshomelab)

## Configuring Grafana

1. **Add Prometheus as a Data Source**:
   - Go to Configuration > Data Sources > Add data source
   - Select "Prometheus"
   - URL: http://prometheus:9090
   - Click "Save & Test"

2. **Import Dashboards**:
   - Go to Dashboards > Import
   - Import dashboard templates using the following IDs:
     - 1860 (Node Exporter Full)
     - 893 (Docker Dashboard)
     - 13946 (Docker Container Metrics)

## Advanced Configuration

### Adding Alert Rules in Prometheus

Create a new file in the Prometheus configuration directory:

```bash
sudo nano /opt/dsb-homelab/monitoring/prometheus/alert_rules.yml
```

Example alert rules:

```yaml
groups:
- name: example
  rules:
  - alert: HighCPULoad
    expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: High CPU load (instance {{ $labels.instance }})
      description: "CPU load is > 80%\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
```

Update the Prometheus configuration to include the rules:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

scrape_configs:
  # ... existing scrape configs ...
```

Restart Prometheus:

```bash
cd /opt/dsb-homelab/monitoring
sudo docker-compose restart prometheus
```

### Enabling Alertmanager

Add Alertmanager to the Docker Compose file:

```yaml
alertmanager:
  image: prom/alertmanager:latest
  container_name: alertmanager
  volumes:
    - ./alertmanager:/etc/alertmanager
  command:
    - '--config.file=/etc/alertmanager/config.yml'
    - '--storage.path=/alertmanager'
  ports:
    - "9093:9093"
  restart: unless-stopped
  networks:
    - monitoring
```

Create the Alertmanager configuration:

```bash
sudo mkdir -p /opt/dsb-homelab/monitoring/alertmanager
sudo nano /opt/dsb-homelab/monitoring/alertmanager/config.yml
```

Add basic configuration:

```yaml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'email-notifications'

receivers:
- name: 'email-notifications'
  email_configs:
  - to: 'your-email@example.com'
    from: 'alertmanager@example.com'
    smarthost: smtp.example.com:587
    auth_username: 'username'
    auth_password: 'password'
```

Update Prometheus to use Alertmanager:

```yaml
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - alertmanager:9093
```

Restart the services:

```bash
cd /opt/dsb-homelab/monitoring
sudo docker-compose up -d
```

## Troubleshooting

### Prometheus Issues

1. **Check Prometheus status**:
   - Access http://dsb-node-01:9090/status to see the current status
   - Check http://dsb-node-01:9090/targets to see if targets are being scraped

2. **View Prometheus logs**:
   ```bash
   sudo docker logs prometheus
   ```

### Grafana Issues

1. **Reset admin password**:
   ```bash
   docker exec -it grafana grafana-cli admin reset-admin-password newpassword
   ```

2. **Check Grafana logs**:
   ```bash
   sudo docker logs grafana
   ```

3. **Verify data source connectivity**:
   - Go to Configuration > Data Sources > Prometheus > Test