# SonarQube Docker Compose

Static code analysis with SonarQube using Docker Compose.

## Quick Start

### 1. Start SonarQube Server

```bash
docker compose --profile dev up -d
```

Wait for the server to be healthy (check at http://localhost:9000).

### 2. Login and Create Token

1. Open http://localhost:9000
2. Login with default credentials: `admin` / `admin`
3. Change password on first login
4. Go to **My Account** > **Security** > **Generate Token**
5. Create a token with name `scanner-token` and type `Global Analysis Token`
6. Copy the generated token

### 3. Configure Token

Create a `.env` file with your token:

```bash
echo "SONAR_TOKEN=sqp_your_token_here" > .env
```

### 4. Run Scanner

```bash
docker compose --profile scan up sonar-scanner
```

### 5. View Results

Open http://localhost:9000 and navigate to your project.

## Mac ARM64 (Apple Silicon)

Enable Rosetta in Docker Desktop:
1. Open **Docker Desktop**
2. Go to **Settings** > **Features in development**
3. Enable **Use Rosetta for x86_64/amd64 emulation on Apple Silicon**
4. Click **Apply & Restart**

## Commands

```bash
# Start server only
docker compose --profile dev up -d

# Run scanner (starts server if not running)
docker compose --profile scan up sonar-scanner

# Stop everything
docker compose --profile dev down

# Stop and remove volumes
docker compose --profile dev down -v
```

## Resource Limits

| Service | CPU Limit | Memory Limit |
|---------|-----------|--------------|
| SonarQube Server | 2.0 | 4GB |
| PostgreSQL | 1.0 | 1GB |
| Scanner | 1.0 | 1GB |

## References

- [SonarQube Docker Compose Tutorial](https://medium.com/@denis.verkhovsky/sonarqube-with-docker-compose-complete-tutorial-2aaa8d0771d4)
- [SonarQube Static Code Analysis](https://medium.com/@rikza.kurnia/sonarqube-static-code-analysis-tools-74072ebef727)
- [Docker SonarQube](https://hub.docker.com/_/sonarqube)