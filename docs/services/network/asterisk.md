# Asterisk VoIP PBX

Asterisk is a free and open source framework for building communications applications.

## Features

- Full SIP protocol support
- VoIP calling with multiple codecs
- IVR (Interactive Voice Response)
- Call queues and ACD
- Voicemail with email notifications
- Conference calling
- Call recording
- WebRTC support

## Quick Start

```bash
cd 04-network-management/asterisk
docker compose up -d
```

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 5060 | UDP/TCP | SIP signaling |
| 5061 | TCP | SIP over TLS |
| 10000-10099 | UDP | RTP media |

## Configuration Files

- `config/pjsip.conf` - SIP endpoints
- `config/extensions.conf` - Dialplan
- `config/voicemail.conf` - Voicemail settings

## Resources

- [Asterisk Documentation](https://docs.asterisk.org/)
- [FreePBX](https://www.freepbx.org/)
