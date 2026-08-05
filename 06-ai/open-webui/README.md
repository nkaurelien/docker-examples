# Open WebUI

Open WebUI is an extensible, feature-rich, and user-friendly self-hosted WebUI designed to operate entirely offline. It supports various LLM runners, including Ollama and OpenAI-compatible APIs.

In this setup, Open WebUI connects to the Ollama instance hosted on a remote server.

## Host Details

- **Host Name / IP**: `<your-remote-server-ip>`
- **SSH Port**: `<your-ssh-port>`
- **User**: `<username>`
- **GPU**: NVIDIA GPU (supports CUDA-accelerated model engines)

---

## Deployment & Configuration

### Option 1: Direct Network Connection

If the Ollama instance on your remote host is exposed to your local network/internet on port `11434`, you can connect to it directly.

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
2. Make sure the `OLLAMA_BASE_URL` in `.env` is set to your remote Ollama IP:
   ```env
   OLLAMA_BASE_URL=http://<your-remote-server-ip>:11434
   ```
3. Start the container:
   ```bash
   docker compose up -d
   ```

### Option 2: SSH Tunnel (Recommended if port 11434 is blocked/private)

If port `11434` on the remote server is only accessible locally on that host, you can establish an SSH tunnel to forward your local port `11434` to the remote port `11434`.

#### Using Make shortcuts (from repository root)

1. Create the `.env` configuration file:
   ```bash
   make open-webui-env
   ```
2. **Configure your secrets**: Edit the newly created `06-ai/open-webui/.env` (which is git-ignored and safe) and add your server details:
   ```env
   OLLAMA_SSH_HOST=<your-remote-server-ip>
   OLLAMA_SSH_PORT=<ssh-port>
   OLLAMA_SSH_USER=<username>
   ```
3. Launch the SSH tunnel:
   ```bash
   make open-webui-tunnel
   ```
   *(Enter your SSH password when prompted)*
4. Start the container:
   ```bash
   cd 06-ai/open-webui/ && docker compose up -d
   ```

#### Manual Steps

1. Establish the SSH tunnel:
   ```bash
   ssh -f -N -L 11434:localhost:11434 -p <ssh-port> <username>@<your-remote-server-ip>
   ```
   *(Enter your SSH password when prompted)*

2. Copy `.env.example` to `.env` and configure:
   ```bash
   cp .env.example .env
   ```
   Set `OLLAMA_BASE_URL=http://host.docker.internal:11434` inside `.env`.

3. Start Open WebUI:
   ```bash
   docker compose up -d
   ```

---

## Usage

Once started, Open WebUI will be accessible at:
- **URL**: `http://localhost:3000`

The first registered user account will automatically become the Admin account.

---

## Troubleshooting

### Address already in use (Port 11434)
If you get an error that port `11434` is already in use when trying to create the SSH tunnel (e.g. because of a local Ollama instance running, or an old SSH tunnel process), you can free up the port:

#### Using Make shortcut (from repository root)
```bash
make open-webui-clean-port
```

#### Manually
1. Find the PID of the process using port `11434`:
   ```bash
   lsof -i :11434
   ```
2. Kill the process:
   ```bash
   kill -9 <PID>
   # Or kill all local ollama processes
   killall ollama
   ```
