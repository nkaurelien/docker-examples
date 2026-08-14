# Network Management

Tools for network monitoring, traffic analysis, and network infrastructure management.

## Existing Projects

*No projects yet - suggestions below*

## Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **Netbox** | IP address and datacenter management | [netbox-community/netbox](https://github.com/netbox-community/netbox) |
| **phpIPAM** | IP address management | [phpipam/phpipam](https://github.com/phpipam/phpipam) |
| **Oxidized** | Network device configuration backup | [ytti/oxidized](https://github.com/ytti/oxidized) |
| **LibreNMS** | Network monitoring system | [librenms/librenms](https://github.com/librenms/librenms) |
| **Observium** | Network monitoring platform | [observium/observium](https://github.com/observium) |
| **Cacti** | Network graphing solution | [Cacti/cacti](https://github.com/Cacti/cacti) |
| **Ntopng** | Network traffic analysis | [ntop/ntopng](https://github.com/ntop/ntopng) |
| **Wireshark** | Network protocol analyzer | [wireshark/wireshark](https://github.com/wireshark/wireshark) |
| **OpenWISP** | Network management system | [openwisp/openwisp-controller](https://github.com/openwisp/openwisp-controller) |
| **UniFi Controller** | Ubiquiti network management | [linuxserver/docker-unifi-controller](https://github.com/linuxserver/docker-unifi-controller) |
| **OPNsense** | Firewall and routing platform | [opnsense/core](https://github.com/opnsense/core) |

## Example Docker Compose

```yaml
services:
  netbox:
    image: netboxcommunity/netbox:latest
    ports:
      - "8080:8080"
    environment:
      - SUPERUSER_API_TOKEN=your-token
    volumes:
      - netbox-data:/opt/netbox/netbox/media

volumes:
  netbox-data:
```
