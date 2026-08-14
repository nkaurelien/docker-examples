# Infrastructure Environment

Core infrastructure services for networking, reverse proxy, SSL/TLS management, and DNS.

## Existing Projects

- **traefik/** - Modern reverse proxy and load balancer
- **dnsServer/** - DNS server configuration
- **nginx-certbot/** - Nginx with Let's Encrypt SSL automation

## Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **Caddy** | Automatic HTTPS web server | [caddyserver/caddy](https://github.com/caddyserver/caddy) |
| **HAProxy** | High-performance TCP/HTTP load balancer | [haproxy/haproxy](https://github.com/haproxy/haproxy) |
| **Pi-hole** | Network-wide ad blocking DNS | [pi-hole/pi-hole](https://github.com/pi-hole/pi-hole) |
| **AdGuard Home** | Network-wide ad and tracker blocking DNS | [AdguardTeam/AdGuardHome](https://github.com/AdguardTeam/AdGuardHome) |
| **CoreDNS** | Cloud-native DNS server | [coredns/coredns](https://github.com/coredns/coredns) |
| **Nginx Proxy Manager** | Easy reverse proxy management UI | [NginxProxyManager/nginx-proxy-manager](https://github.com/NginxProxyManager/nginx-proxy-manager) |
| **Cloudflare Tunnel** | Secure tunnel to expose services | [cloudflare/cloudflared](https://github.com/cloudflare/cloudflared) |
| **Tailscale** | Zero-config VPN mesh network | [tailscale/tailscale](https://github.com/tailscale/tailscale) |
| **WireGuard** | Modern VPN protocol | [WireGuard/wireguard-linux](https://github.com/WireGuard/wireguard-linux) |
| **Netbird** | Open-source VPN alternative to Tailscale | [netbirdio/netbird](https://github.com/netbirdio/netbird) |

## Quick Start

```bash
cd traefik/
docker compose up -d
```

Access Traefik dashboard at `http://traefik.apps.local` (port 8088).
