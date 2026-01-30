# Home Assistant

Home Assistant is an open-source home automation platform that puts local control and privacy first.

## Features

- 1800+ integrations
- Powerful automation engine
- Beautiful dashboards
- Voice assistant support
- Energy management
- Local control (no cloud required)

## Stack Components

| Service | Description | Port |
|---------|-------------|------|
| **Home Assistant** | Core automation platform | 8123 |
| **Zigbee2MQTT** | Zigbee device bridge | 8080 |
| **Mosquitto** | MQTT message broker | 1883 |

## Quick Start

```bash
cd 03-iot-smart-home/home-assistant
docker compose up -d
```

Access at: `http://localhost:8123`

## Configuration

See the [full documentation](https://github.com/nkaurelien/docker-examples/tree/main/03-iot-smart-home/home-assistant) for detailed setup instructions.

## Resources

- [Official Documentation](https://www.home-assistant.io/docs/)
- [Zigbee2MQTT](https://www.zigbee2mqtt.io/)
- [Community Forum](https://community.home-assistant.io/)
