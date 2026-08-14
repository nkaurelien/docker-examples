# Monitoring and Reporting

Observability stack: metrics, logs, dashboards, and code quality analysis.

## Observability

Metrics, logs, tracing, and dashboards.

### Existing Projects

- **observability/grafana/** - Metrics visualization and dashboards
- **observability/monitoring/** - Additional monitoring configurations

### Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **Prometheus** | Metrics collection and alerting | [prometheus/prometheus](https://github.com/prometheus/prometheus) |
| **Grafana** | Visualization and dashboards | [grafana/grafana](https://github.com/grafana/grafana) |
| **Loki** | Log aggregation system | [grafana/loki](https://github.com/grafana/loki) |
| **Tempo** | Distributed tracing backend | [grafana/tempo](https://github.com/grafana/tempo) |
| **Jaeger** | Distributed tracing | [jaegertracing/jaeger](https://github.com/jaegertracing/jaeger) |
| **Zabbix** | Enterprise monitoring | [zabbix/zabbix](https://github.com/zabbix/zabbix) |
| **Netdata** | Real-time performance monitoring | [netdata/netdata](https://github.com/netdata/netdata) |
| **Graylog** | Log management platform | [Graylog2/graylog2-server](https://github.com/Graylog2/graylog2-server) |
| **Uptime Kuma** | Uptime monitoring | [louislam/uptime-kuma](https://github.com/louislam/uptime-kuma) |
| **Healthchecks** | Cron job monitoring | [healthchecks/healthchecks](https://github.com/healthchecks/healthchecks) |

---

## Code Quality

Static analysis, code review, and quality metrics.

### Existing Projects

- **code-quality/sonarcube/** - Code quality and security analysis

### Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **SonarQube** | Code quality analysis | [SonarSource/sonarqube](https://github.com/SonarSource/sonarqube) |
| **Sentry** | Error tracking and monitoring | [getsentry/sentry](https://github.com/getsentry/sentry) |
| **Semgrep** | Static analysis tool | [semgrep/semgrep](https://github.com/semgrep/semgrep) |
| **Snyk** | Security scanning | [snyk/cli](https://github.com/snyk/cli) |
| **Trivy** | Vulnerability scanner | [aquasecurity/trivy](https://github.com/aquasecurity/trivy) |
| **Checkov** | Infrastructure as code scanner | [bridgecrewio/checkov](https://github.com/bridgecrewio/checkov) |

---

## Quick Start

```bash
# Grafana
cd observability/grafana/
docker compose up -d

# SonarQube
cd code-quality/sonarcube/
docker compose up -d
```

Access Grafana at `http://grafana.apps.local`.
