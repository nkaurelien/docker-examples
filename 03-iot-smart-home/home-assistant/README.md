# Home Assistant - Open Source Smart Home Platform

Home Assistant is an open-source home automation platform that puts local control and privacy first. This stack includes Zigbee2MQTT for Zigbee device support and Mosquitto as the MQTT broker.

## Stack Components

| Service | Description | Port |
|---------|-------------|------|
| **Home Assistant** | Smart home automation platform | 8123 |
| **Zigbee2MQTT** | Zigbee to MQTT bridge | 8080 |
| **Mosquitto** | MQTT message broker | 1883, 9001 |

## Features

### Home Assistant
- **1800+ Integrations**: Connect virtually any smart device
- **Automations**: Create powerful automation rules
- **Dashboards**: Customizable Lovelace UI
- **Voice Assistants**: Alexa, Google Home, Siri integration
- **Energy Management**: Track and optimize energy usage
- **Local Control**: No cloud dependency
- **Mobile Apps**: iOS and Android companion apps

### Zigbee2MQTT
- **500+ Devices Supported**: Most Zigbee devices work
- **No Vendor Lock-in**: Use any Zigbee adapter
- **Device Groups**: Create and manage device groups
- **OTA Updates**: Over-the-air firmware updates
- **Network Map**: Visualize your Zigbee network

### Mosquitto
- **Lightweight**: Minimal resource usage
- **Reliable**: Production-tested MQTT broker
- **Secure**: TLS/SSL and authentication support
- **WebSocket**: Browser-based MQTT clients

## Prerequisites

- Docker Engine 19.03.9+ (not Docker Desktop)
- USB Zigbee adapter (for Zigbee devices)
  - Recommended: SONOFF Zigbee 3.0 USB Dongle Plus
  - Alternatives: ConBee II, CC2531, CC2652
- `libseccomp` 2.4.2+ on host

### Check Zigbee Adapter

```bash
# List USB devices
ls -l /dev/ttyUSB* /dev/ttyACM*

# Or use dmesg
dmesg | grep tty
```

## Quick Start

1. **Clone and configure**:
```bash
cd 03-iot-smart-home/home-assistant
cp .env.example .env
# Edit .env with your Zigbee device path
```

2. **Create Mosquitto config**:
```bash
cat > mosquitto/config/mosquitto.conf << 'EOF'
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
listener 1883
listener 9001
protocol websockets
allow_anonymous true
EOF
```

3. **Start the stack**:
```bash
docker compose up -d
```

4. **Access services**:
   - Home Assistant: http://localhost:8123
   - Zigbee2MQTT: http://localhost:8080

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TZ` | `Europe/Paris` | Timezone |
| `ZIGBEE_DEVICE` | `/dev/ttyUSB0` | Zigbee adapter device path |

### Zigbee2MQTT Configuration

Create `zigbee2mqtt/configuration.yaml`:

```yaml
# MQTT settings
mqtt:
  base_topic: zigbee2mqtt
  server: mqtt://mosquitto:1883

# Serial adapter
serial:
  port: /dev/ttyUSB0
  # For network adapters:
  # port: tcp://192.168.1.100:6638

# Web frontend
frontend:
  port: 8080

# Home Assistant integration
homeassistant: true

# Permit joining (disable in production)
permit_join: false

# Device settings
advanced:
  homeassistant_discovery_topic: homeassistant
  homeassistant_status_topic: homeassistant/status
  log_level: info
  network_key: GENERATE
  pan_id: GENERATE
```

### Mosquitto with Authentication

```bash
# Create password file
docker exec mosquitto mosquitto_passwd -c /mosquitto/config/passwd homeassistant

# Update mosquitto.conf
cat > mosquitto/config/mosquitto.conf << 'EOF'
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
listener 1883
listener 9001
protocol websockets
allow_anonymous false
password_file /mosquitto/config/passwd
EOF

# Restart
docker compose restart mosquitto
```

### Home Assistant MQTT Integration

Add to `config/configuration.yaml`:

```yaml
# MQTT Configuration
mqtt:
  broker: localhost
  port: 1883
  # With authentication:
  # username: homeassistant
  # password: your_password
```

Or configure via UI: Settings > Devices & Services > Add Integration > MQTT

## Zigbee Network Setup

### Pair New Device

1. Enable pairing in Zigbee2MQTT:
   - Web UI: Click "Permit join" button
   - Or set `permit_join: true` temporarily

2. Put device in pairing mode (usually hold button 5-10 seconds)

3. Device appears in Zigbee2MQTT and Home Assistant

### Common Zigbee Adapters

| Adapter | Device Path | Notes |
|---------|-------------|-------|
| SONOFF Zigbee 3.0 | `/dev/ttyUSB0` | Recommended |
| ConBee II | `/dev/ttyACM0` | Reliable |
| CC2652 | `/dev/ttyUSB0` | Good range |
| CC2531 | `/dev/ttyACM0` | Basic, limited |

### Network Key

Generate a new network key for security:

```bash
# Generate random key
openssl rand -hex 16

# Add to zigbee2mqtt/configuration.yaml
# advanced:
#   network_key: [0x01, 0x02, ...]
```

## Home Assistant Add-ons Alternative

The Docker installation doesn't support add-ons. For add-on support, consider:

1. **Separate containers** for each add-on equivalent
2. **Home Assistant Operating System** (HAOS) installation
3. **Supervised installation** (advanced)

### Common Add-on Alternatives

| Add-on | Docker Alternative |
|--------|-------------------|
| File Editor | VS Code with Remote SSH |
| Terminal | `docker exec -it homeassistant bash` |
| Samba | Separate Samba container |
| Node-RED | `nodered/node-red` image |
| InfluxDB | `influxdb` image |
| Grafana | `grafana/grafana` image |

## Extended Stack

### Add Node-RED

```yaml
# Add to compose.yml
services:
  nodered:
    container_name: nodered
    image: nodered/node-red:latest
    restart: unless-stopped
    ports:
      - "1880:1880"
    volumes:
      - ./nodered:/data
    environment:
      - TZ=${TZ:-Europe/Paris}
    networks:
      - homeassistant-network
```

### Add InfluxDB + Grafana

```yaml
services:
  influxdb:
    container_name: influxdb
    image: influxdb:2
    restart: unless-stopped
    ports:
      - "8086:8086"
    volumes:
      - ./influxdb:/var/lib/influxdb2
    environment:
      - DOCKER_INFLUXDB_INIT_MODE=setup
      - DOCKER_INFLUXDB_INIT_USERNAME=admin
      - DOCKER_INFLUXDB_INIT_PASSWORD=adminpassword
      - DOCKER_INFLUXDB_INIT_ORG=home
      - DOCKER_INFLUXDB_INIT_BUCKET=homeassistant
    networks:
      - homeassistant-network

  grafana:
    container_name: grafana
    image: grafana/grafana:latest
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - ./grafana:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    networks:
      - homeassistant-network
```

## Backup

```bash
# Stop services
docker compose stop

# Backup all data
tar czf homeassistant-backup-$(date +%Y%m%d).tar.gz \
  config/ \
  zigbee2mqtt/ \
  mosquitto/

# Restart
docker compose start
```

## Troubleshooting

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker logs -f homeassistant
docker logs -f zigbee2mqtt
docker logs -f mosquitto
```

### Zigbee Adapter Not Found

```bash
# Check device exists
ls -la /dev/ttyUSB* /dev/ttyACM*

# Check permissions
sudo usermod -aG dialout $USER

# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### MQTT Connection Issues

```bash
# Test MQTT connection
docker exec mosquitto mosquitto_sub -t '#' -v

# Check Mosquitto logs
docker logs mosquitto
```

### Home Assistant Restart

```bash
# Via Docker
docker compose restart homeassistant

# Via HA CLI
docker exec homeassistant ha core restart
```

## Security Recommendations

1. **Secure MQTT**: Enable authentication and TLS
2. **Network Segmentation**: Isolate IoT devices on separate VLAN
3. **Disable permit_join**: Only enable when pairing
4. **Regular Updates**: Keep all images updated
5. **Strong Passwords**: Use unique passwords for each service
6. **Firewall**: Restrict external access to necessary ports only

## Documentation

- [Home Assistant](https://www.home-assistant.io/docs/)
- [Zigbee2MQTT](https://www.zigbee2mqtt.io/)
- [Eclipse Mosquitto](https://mosquitto.org/documentation/)
- [Home Assistant Community](https://community.home-assistant.io/)
- [Supported Zigbee Devices](https://www.zigbee2mqtt.io/supported-devices/)
