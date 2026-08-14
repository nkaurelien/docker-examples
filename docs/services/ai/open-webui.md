# Open WebUI

Open WebUI is a user-friendly, feature-rich web interface for interacting with Large Language Models (LLMs). It integrates seamlessly with Ollama, providing a ChatGPT-like user experience.

## Deployment

To deploy Open WebUI locally, navigate to its directory and run:

```bash
cd compose/06-ai/open-webui/
docker compose up -d
```

Access the web interface at [http://localhost:3000](http://localhost:3000).

## Connection to Remote Ollama Server

This setup connects Open WebUI to a remote Ollama server.

### Hardware Specifications (Example Host)
- **GPU**: NVIDIA GPU (e.g. Blackwell GB10 family)
- **NVIDIA Driver**: 580.126.09+
- **CUDA Version**: 13.0+
- **Running Engines**: Ollama (for model serving) and vLLM Engine Core.

### Direct Connection
If the server's port `11434` is publicly accessible:
- Edit `.env` to set:
  ```env
  OLLAMA_BASE_URL=http://<your-remote-server-ip>:11434
  ```

### SSH Tunnel Connection (Recommended)
If port `11434` is private, you can automate this using the provided `make` commands:

1. **Create the environment file**:
   ```bash
   make open-webui-env
   ```
   This copies the template and sets `OLLAMA_BASE_URL` to `http://host.docker.internal:11434`.

2. **Configure your secrets**: Edit `compose/06-ai/open-webui/.env` (which is git-ignored and safe) and add your server details:
   ```env
   OLLAMA_SSH_HOST=<your-remote-server-ip>
   OLLAMA_SSH_PORT=<ssh-port>
   OLLAMA_SSH_USER=<username>
   ```

3. **Open the SSH tunnel**:
   ```bash
   make open-webui-tunnel
   ```
   *(Enter your SSH password when prompted)*

Alternatively, to do this manually:
```bash
ssh -f -N -L 11434:localhost:11434 -p <ssh-port> <username>@<your-remote-server-ip>
```
And set the following in your `.env` file:
```env
OLLAMA_BASE_URL=http://host.docker.internal:11434
```

## Troubleshooting

### Port 11434 Address Already in Use
If the SSH tunnel fails to open because port `11434` is bound by a local Ollama process or a legacy SSH process, you can free the port.

#### Using Make target
```bash
make open-webui-clean-port
```

#### Manually
Find the active PID and terminate it:
```bash
lsof -i :11434
kill -9 <PID>
```
