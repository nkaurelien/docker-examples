# Code Management

Source code hosting, artifact repositories, and package management.

## Existing Projects

- **docker-registry/** - Private Docker registry
- **jfrog-artifactory/** - Universal artifact repository

## Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **Gitea** | Lightweight Git hosting | [go-gitea/gitea](https://github.com/go-gitea/gitea) |
| **Forgejo** | Gitea community fork | [forgejo/forgejo](https://codeberg.org/forgejo/forgejo) |
| **GitLab CE** | Complete DevOps platform | [gitlab-org/gitlab](https://github.com/gitlab-org/gitlab) |
| **Gogs** | Painless self-hosted Git | [gogs/gogs](https://github.com/gogs/gogs) |
| **OneDev** | Git server with CI/CD | [theonedev/onedev](https://github.com/theonedev/onedev) |
| **Soft Serve** | Terminal Git server | [charmbracelet/soft-serve](https://github.com/charmbracelet/soft-serve) |
| **Harbor** | Cloud-native registry | [goharbor/harbor](https://github.com/goharbor/harbor) |
| **Nexus** | Repository manager | [sonatype/nexus-public](https://github.com/sonatype/nexus-public) |
| **Verdaccio** | Private npm registry | [verdaccio/verdaccio](https://github.com/verdaccio/verdaccio) |
| **Pulp** | Software repository manager | [pulp/pulpcore](https://github.com/pulp/pulpcore) |
| **Zarf** | Airgap software delivery | [defenseunicorns/zarf](https://github.com/defenseunicorns/zarf) |
| **Sourcegraph** | Code search and intelligence | [sourcegraph/sourcegraph](https://github.com/sourcegraph/sourcegraph) |

## Quick Start

```bash
cd docker-registry/
docker compose up -d
```

Push images to your private registry at `localhost:5000`.
