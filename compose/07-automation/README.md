# Automation

Workflow automation, CI/CD pipelines, and scheduled task management.

## CI/CD

Continuous integration and continuous deployment pipelines.

### Existing Projects

- **ci-cd/jenkins/** - CI/CD automation server

### Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **Jenkins** | Automation server | [jenkinsci/jenkins](https://github.com/jenkinsci/jenkins) |
| **GitLab CI** | Integrated CI/CD | [gitlab-org/gitlab](https://github.com/gitlab-org/gitlab) |
| **Drone CI** | Container-native CI/CD | [harness/drone](https://github.com/harness/drone) |
| **Woodpecker CI** | Community fork of Drone | [woodpecker-ci/woodpecker](https://github.com/woodpecker-ci/woodpecker) |
| **Concourse CI** | Pipeline-based CI/CD | [concourse/concourse](https://github.com/concourse/concourse) |
| **Tekton** | Kubernetes-native CI/CD | [tektoncd/pipeline](https://github.com/tektoncd/pipeline) |
| **Argo CD** | GitOps continuous delivery | [argoproj/argo-cd](https://github.com/argoproj/argo-cd) |

---

## Workflow

Workflow automation and integration platforms.

### Existing Projects

- **workflow/n8n/** - Workflow automation platform

### Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **n8n** | Workflow automation (Zapier alternative) | [n8n-io/n8n](https://github.com/n8n-io/n8n) |
| **Argo Workflows** | Kubernetes workflow engine | [argoproj/argo-workflows](https://github.com/argoproj/argo-workflows) |
| **Temporal** | Workflow orchestration | [temporalio/temporal](https://github.com/temporalio/temporal) |
| **Huginn** | Agents for automation | [huginn/huginn](https://github.com/huginn/huginn) |
| **Activepieces** | No-code automation | [activepieces/activepieces](https://github.com/activepieces/activepieces) |
| **Automatisch** | Zapier alternative | [automatisch/automatisch](https://github.com/automatisch/automatisch) |
| **Node-RED** | Flow-based programming | [node-red/node-red](https://github.com/node-red/node-red) |

---

## Scheduling

Scheduled tasks and cron job management.

### Existing Projects

- **scheduling/cronjob/** - Scheduled task examples

### Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **Ofelia** | Docker job scheduler | [mcuadros/ofelia](https://github.com/mcuadros/ofelia) |
| **Healthchecks** | Cron job monitoring | [healthchecks/healthchecks](https://github.com/healthchecks/healthchecks) |
| **Cronicle** | Task scheduler | [jhuckaby/Cronicle](https://github.com/jhuckaby/Cronicle) |
| **Rundeck** | Job scheduler and runbook | [rundeck/rundeck](https://github.com/rundeck/rundeck) |
| **Apache Airflow** | Workflow scheduling | [apache/airflow](https://github.com/apache/airflow) |

---

## Quick Start

```bash
# Jenkins
cd ci-cd/jenkins/
docker compose up -d

# n8n
cd workflow/n8n/
docker compose up -d
```

Access n8n at `http://n8n.apps.local`.
