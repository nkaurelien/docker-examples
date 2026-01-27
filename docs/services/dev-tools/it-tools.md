# IT-Tools

![IT-Tools Logo](https://raw.githubusercontent.com/CorentinTh/it-tools/main/public/logo.svg){ width="100" }

IT-Tools is an open-source project created by **Corentin Thomasset** (Lyon, France) that provides a comprehensive collection of handy online tools for developers and system administrators.

## 🌐 Links

- **GitHub**: [https://github.com/CorentinTh/it-tools](https://github.com/CorentinTh/it-tools)
- **Online Version**: [https://it-tools.tech](https://it-tools.tech)
- **Docker Image**: `ghcr.io/corentinth/it-tools:latest`

## 🛠️ Features

### Network Tools
- **IP Subnet Calculator** - Calculate IP subnets and network ranges
- **IP Address Converter** - Convert IP addresses to binary, decimal, hexadecimal
- **MAC Address Information** - Get vendor information from MAC addresses
- **MAC Address Generator** - Generate random MAC addresses
- **IPv6 ULA Generator** - Generate RFC4193-compliant unique local IPv6 addresses

### Encoding & Decoding
- Base64 encoder/decoder
- URL encoder/decoder
- JWT decoder
- HTML entities encoder/decoder
- And many more...

### Generators
- UUID/GUID generator
- Hash generator (MD5, SHA-1, SHA-256, etc.)
- Password generator
- Lorem Ipsum generator
- QR Code generator

### Converters
- JSON ↔ YAML
- JSON ↔ XML
- Case converter (camelCase, snake_case, etc.)
- Number base converter
- Color converter (HEX, RGB, HSL)

### Text Tools
- Text diff viewer
- Regex tester
- Markdown preview
- String utilities

## 🚀 Quick Start

### Deploy with Docker Compose

1. Navigate to the IT-Tools directory:
   ```bash
   cd it-tools/
   ```

2. Start the service:
   ```bash
   docker-compose up -d
   ```

3. Access the interface at: **[http://localhost:7474](http://localhost:7474)**

### Configuration

The default `docker-compose.yml` configuration:

```yaml
services:
  it-tools:
    image: 'ghcr.io/corentinth/it-tools:latest'
    ports:
      - '7474:80'
    restart: unless-stopped
    container_name: it-tools
```

## 🔧 Customization

### Change Port

To use a different port, modify the `ports` section in `docker-compose.yml`:

```yaml
ports:
  - '8080:80'  # Use port 8080 instead of 7474
```

### Use with Reverse Proxy

Example configuration with Traefik:

```yaml
services:
  it-tools:
    image: 'ghcr.io/corentinth/it-tools:latest'
    restart: unless-stopped
    container_name: it-tools
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.it-tools.rule=Host(`tools.example.com`)"
      - "traefik.http.services.it-tools.loadbalancer.server.port=80"

networks:
  proxy:
    external: true
```

## 📊 Resource Requirements

IT-Tools is a lightweight web application:

- **RAM**: ~50-100 MB
- **CPU**: Minimal
- **Storage**: ~100 MB (Docker image)

## 🔐 Security Considerations

!!! warning "No Built-in Authentication"
    IT-Tools does not include authentication by default. If exposing to the internet:
    
    - Use a reverse proxy with authentication (Basic Auth, OAuth, etc.)
    - Limit access by IP if possible
    - Use HTTPS to encrypt communications

## 🛠️ Common Operations

### View Logs

```bash
docker-compose logs -f it-tools
```

### Check Status

```bash
docker-compose ps
```

### Update to Latest Version

```bash
docker-compose pull
docker-compose up -d
```

### Stop Service

```bash
docker-compose down
```

## 🆘 Troubleshooting

### Container Won't Start

Check the logs for errors:
```bash
docker-compose logs it-tools
```

### Port Already in Use

Check if port 7474 is already in use:
```bash
lsof -i :7474
```

If the port is in use, either stop the conflicting service or change the port in `docker-compose.yml`.

## 📚 Additional Resources

- [Official Documentation](https://github.com/CorentinTh/it-tools#readme)
- [Contributing Guide](https://github.com/CorentinTh/it-tools/blob/main/CONTRIBUTING.md)
- [Report Issues](https://github.com/CorentinTh/it-tools/issues)

## 📄 License

IT-Tools is distributed under the GNU GPL v3.0 license. See the [GitHub repository](https://github.com/CorentinTh/it-tools) for details.
