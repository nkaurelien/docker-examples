# Syncthing P2P File Synchronization Stack

[Syncthing](https://syncthing.net/) is a continuous, peer-to-peer (P2P), encrypted file synchronization application.

## Hostnames & Access

- Main URL: `https://syncthing.example.com`
- Alias URL: `https://sync.example.com`
- Default GUI Admin Login: `admin`

## Network Ports

- `8384` (Web GUI - proxied via Traefik HTTPS)
- `22000/tcp` + `22000/udp` (P2P File Transfer Protocol)
- `21027/udp` (Local Network Discovery)

## Deployment with Ansible

```bash
ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags syncthing
```
