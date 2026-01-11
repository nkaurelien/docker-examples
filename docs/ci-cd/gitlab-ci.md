# GitLab CI/CD pour Docker

Configuration complète de pipelines GitLab CI pour build, test et déploiement d'images Docker.

## Structure du pipeline

```yaml
stages:
  - lint
  - build
  - test
  - deploy
```

## Lint des Dockerfiles

Utiliser **hadolint** pour valider les Dockerfiles :

```yaml
container-lint:
  stage: lint
  image: hadolint/hadolint:latest-debian
  needs: []
  script:
    - hadolint Dockerfile
    - hadolint docker/Dockerfile.dev
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

## Build avec Kaniko

[Kaniko](https://github.com/GoogleContainerTools/kaniko) permet de build des images Docker sans privilèges root.

### Build simple

```yaml
build-image:
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:v1.14.0-debug
    entrypoint: [""]
  script:
    - >
      /kaniko/executor
      --context "${CI_PROJECT_DIR}"
      --dockerfile "${CI_PROJECT_DIR}/Dockerfile"
      --destination "${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA}"
      --destination "${CI_REGISTRY_IMAGE}:latest"
```

### Build multi-environnement

```yaml
.build-base:
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:v1.14.0-debug
    entrypoint: [""]
  script:
    - >
      /kaniko/executor
      --context "${CI_PROJECT_DIR}"
      --dockerfile "${CI_PROJECT_DIR}/Dockerfile"
      --destination "${CI_REGISTRY_IMAGE}:${ENV}-${CI_COMMIT_SHORT_SHA}"
      --destination "${CI_REGISTRY_IMAGE}:${ENV}-latest"

build-dev:
  extends: .build-base
  variables:
    ENV: "dev"
  rules:
    - if: $CI_COMMIT_BRANCH == "develop"

build-prod:
  extends: .build-base
  variables:
    ENV: "prod"
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      when: manual
```

### Build avec arguments

```yaml
build-frontend:
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:v1.14.0-debug
    entrypoint: [""]
  variables:
    API_URL: "https://api.example.com"
  script:
    - >
      /kaniko/executor
      --context "${CI_PROJECT_DIR}"
      --dockerfile "${CI_PROJECT_DIR}/Dockerfile"
      --destination "${CI_REGISTRY_IMAGE}/frontend:${CI_COMMIT_SHORT_SHA}"
      --build-arg "API_URL=${API_URL}"
      --build-arg "NODE_ENV=production"
```

## Scan de sécurité

### Trivy (vulnérabilités containers)

```yaml
container-scan:
  stage: test
  image:
    name: aquasec/trivy:latest
    entrypoint: [""]
  allow_failure: true
  script:
    - trivy image
        --exit-code 0
        --severity HIGH,CRITICAL
        --format json
        --output trivy-report.json
        ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA}
  artifacts:
    reports:
      container_scanning: trivy-report.json
    expire_in: 1 week
```

### Détection de secrets (TruffleHog)

```yaml
secrets-scan:
  stage: test
  image: trufflesecurity/trufflehog:latest
  needs: []
  allow_failure: false
  script:
    - |
      trufflehog git file://. --json --no-update > secrets-report.json 2>/dev/null || true
      if [ -s secrets-report.json ] && grep -q "SourceMetadata" secrets-report.json; then
        echo "ALERT: Secrets detected!"
        exit 1
      fi
  artifacts:
    paths:
      - secrets-report.json
```

## Déploiement avec Ansible

### Template de déploiement

```yaml
.deploy-base:
  image: willhallonline/ansible:2.9-ubuntu-22.04
  stage: deploy
  variables:
    ANSIBLE_HOST_KEY_CHECKING: "False"
  script:
    - cd ansible
    - ansible-galaxy role install -r requirements.yml
    - ansible-playbook -i inventory.yml deploy.yml
        --extra-vars "image_tag=${CI_COMMIT_SHORT_SHA}"
        --limit=${ANSIBLE_HOSTS}
```

### Déploiement par environnement

```yaml
deploy-dev:
  extends: .deploy-base
  variables:
    ANSIBLE_HOSTS: "dev_servers"
  environment:
    name: development
    url: https://dev.example.com
  rules:
    - if: $CI_COMMIT_BRANCH == "develop"

deploy-prod:
  extends: .deploy-base
  variables:
    ANSIBLE_HOSTS: "prod_servers"
  environment:
    name: production
    url: https://example.com
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      when: manual
```

## Variables CI/CD recommandées

Configurer dans **Settings > CI/CD > Variables** :

| Variable | Type | Masked | Description |
|----------|------|--------|-------------|
| `SERVER_PASS` | Variable | Oui | Mot de passe SSH serveurs |
| `REGISTRY_TOKEN` | Variable | Oui | Token d'accès registry |
| `DEPLOY_KEY` | File | Oui | Clé SSH de déploiement |

## Fichier .gitlab-ci.yml complet

```yaml
stages:
  - lint
  - build
  - test
  - deploy

variables:
  IMAGE_TAG: ${CI_COMMIT_SHORT_SHA}

# Lint
container-lint:
  stage: lint
  image: hadolint/hadolint:latest-debian
  script:
    - hadolint Dockerfile

# Build
build:
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:v1.14.0-debug
    entrypoint: [""]
  script:
    - >
      /kaniko/executor
      --context "${CI_PROJECT_DIR}"
      --dockerfile "${CI_PROJECT_DIR}/Dockerfile"
      --destination "${CI_REGISTRY_IMAGE}:${IMAGE_TAG}"

# Security scan
trivy-scan:
  stage: test
  image:
    name: aquasec/trivy:latest
    entrypoint: [""]
  script:
    - trivy image --severity HIGH,CRITICAL ${CI_REGISTRY_IMAGE}:${IMAGE_TAG}

# Deploy
deploy:
  stage: deploy
  image: docker:latest
  script:
    - docker pull ${CI_REGISTRY_IMAGE}:${IMAGE_TAG}
    - docker-compose up -d
  when: manual
```

## Ressources

- [GitLab CI Docker](https://docs.gitlab.com/ee/ci/docker/)
- [Kaniko](https://github.com/GoogleContainerTools/kaniko)
- [Trivy](https://aquasecurity.github.io/trivy/)
