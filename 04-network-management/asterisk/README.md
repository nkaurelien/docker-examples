# Asterisk - Open Source VoIP PBX

Asterisk is a free and open source framework for building communications applications. It powers IP PBX systems, VoIP gateways, conference servers, and other custom telephony solutions.

## Features

- **SIP Support**: Full SIP protocol implementation
- **VoIP Calling**: Voice over IP with multiple codecs
- **IVR**: Interactive Voice Response menus
- **Call Queues**: ACD (Automatic Call Distribution)
- **Voicemail**: Voice messaging with email notifications
- **Conference Calling**: Multi-party audio/video conferencing
- **Call Recording**: Record calls for quality assurance
- **CDR**: Call Detail Records for billing/analytics
- **WebRTC**: Browser-based calling support
- **Trunking**: Connect to PSTN via SIP trunks

## Stack Options

| Setup | Description |
|-------|-------------|
| **Asterisk Only** | Lightweight, CLI configuration |
| **FreePBX** | Full web UI, easier management |

## Quick Start

### Asterisk Only

```bash
docker compose up -d asterisk
```

### With FreePBX Web UI

```bash
docker compose --profile freepbx up -d
```

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 5060 | UDP/TCP | SIP signaling |
| 5061 | TCP | SIP over TLS |
| 8088 | TCP | HTTP (AMI/ARI) |
| 8089 | TCP | HTTPS (AMI/ARI) |
| 10000-10099 | UDP | RTP media streams |

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TZ` | `Europe/Paris` | Timezone |
| `SYSLOG_LEVEL` | `4` | Log level (0-8) |
| `TLS_CERTDAYS` | `365` | TLS certificate validity |
| `TLS_KEYBITS` | `2048` | TLS key size |

### Basic SIP Configuration

Create `config/pjsip.conf`:

```ini
; =============================================================================
; PJSIP Configuration for Asterisk
; =============================================================================

; -----------------------------------------------------------------------------
; Transport
; -----------------------------------------------------------------------------
[transport-udp]
type=transport
protocol=udp
bind=0.0.0.0:5060

[transport-tls]
type=transport
protocol=tls
bind=0.0.0.0:5061
cert_file=/etc/asterisk/keys/asterisk.crt
priv_key_file=/etc/asterisk/keys/asterisk.key
method=tlsv1_2

; -----------------------------------------------------------------------------
; Templates
; -----------------------------------------------------------------------------
[endpoint-basic](!)
type=endpoint
context=internal
disallow=all
allow=ulaw
allow=alaw
allow=g722
allow=opus
direct_media=no
rtp_symmetric=yes
force_rport=yes
rewrite_contact=yes

[auth-userpass](!)
type=auth
auth_type=userpass

[aor-single-reg](!)
type=aor
max_contacts=1
remove_existing=yes
qualify_frequency=60

; -----------------------------------------------------------------------------
; Extensions (Users)
; -----------------------------------------------------------------------------
[100](endpoint-basic)
auth=100
aors=100
callerid="User 100" <100>

[100](auth-userpass)
password=secret100
username=100

[100](aor-single-reg)

[101](endpoint-basic)
auth=101
aors=101
callerid="User 101" <101>

[101](auth-userpass)
password=secret101
username=101

[101](aor-single-reg)
```

### Dialplan

Create `config/extensions.conf`:

```ini
; =============================================================================
; Dialplan Configuration
; =============================================================================

[general]
static=yes
writeprotect=no

[globals]
; Global variables

; -----------------------------------------------------------------------------
; Internal Context
; -----------------------------------------------------------------------------
[internal]
; Internal extension dialing (100-199)
exten => _1XX,1,NoOp(Calling extension ${EXTEN})
 same => n,Dial(PJSIP/${EXTEN},30,tT)
 same => n,VoiceMail(${EXTEN}@default,u)
 same => n,Hangup()

; Voicemail access
exten => *98,1,NoOp(Voicemail access)
 same => n,VoiceMailMain(${CALLERID(num)}@default)
 same => n,Hangup()

; Echo test
exten => *43,1,NoOp(Echo test)
 same => n,Answer()
 same => n,Playback(demo-echotest)
 same => n,Echo()
 same => n,Hangup()

; Speaking clock
exten => *60,1,NoOp(Speaking clock)
 same => n,Answer()
 same => n,SayUnixTime(,,ABdY 'digits/at' IMp)
 same => n,Hangup()

; Conference room
exten => 600,1,NoOp(Conference room)
 same => n,Answer()
 same => n,ConfBridge(1)
 same => n,Hangup()

; -----------------------------------------------------------------------------
; Outbound Context (for SIP trunks)
; -----------------------------------------------------------------------------
[outbound]
; Example: route calls via SIP trunk
; exten => _X.,1,Dial(PJSIP/${EXTEN}@trunk-provider)
```

### Voicemail Configuration

Create `config/voicemail.conf`:

```ini
[general]
format=wav49|gsm|wav
serveremail=asterisk@localhost
attach=yes
skipms=3000
maxsilence=10
silencethreshold=128
maxlogins=3
moveheard=yes
charset=UTF-8

[default]
100 => 1234,User 100,user100@example.com
101 => 1234,User 101,user101@example.com
```

### RTP Configuration

Create `config/rtp.conf`:

```ini
[general]
rtpstart=10000
rtpend=10099
; STUN server for NAT traversal
; stunaddr=stun.l.google.com:19302
; ICE support
; icesupport=yes
```

## SIP Trunk Configuration

### Example: Connect to VoIP Provider

Add to `config/pjsip.conf`:

```ini
; -----------------------------------------------------------------------------
; SIP Trunk to Provider
; -----------------------------------------------------------------------------
[trunk-provider]
type=registration
transport=transport-udp
outbound_auth=trunk-provider-auth
server_uri=sip:sip.provider.com
client_uri=sip:username@sip.provider.com
retry_interval=60

[trunk-provider-auth]
type=auth
auth_type=userpass
username=your_username
password=your_password

[trunk-provider-endpoint]
type=endpoint
transport=transport-udp
context=from-trunk
disallow=all
allow=ulaw
allow=alaw
outbound_auth=trunk-provider-auth
aors=trunk-provider-aor
from_user=your_username

[trunk-provider-aor]
type=aor
contact=sip:sip.provider.com
qualify_frequency=60

[trunk-provider-identify]
type=identify
endpoint=trunk-provider-endpoint
match=sip.provider.com
```

## WebRTC Configuration

Enable WebRTC in `config/http.conf`:

```ini
[general]
enabled=yes
bindaddr=0.0.0.0
bindport=8088
tlsenable=yes
tlsbindaddr=0.0.0.0:8089
tlscertfile=/etc/asterisk/keys/asterisk.crt
tlsprivatekey=/etc/asterisk/keys/asterisk.key
```

Add WebRTC endpoint template to `config/pjsip.conf`:

```ini
[webrtc](!)
type=endpoint
context=internal
disallow=all
allow=opus
allow=ulaw
transport=transport-wss
webrtc=yes
dtls_auto_generate_cert=yes
```

## CLI Commands

```bash
# Access Asterisk CLI
docker exec -it asterisk asterisk -rvvv

# Useful commands
asterisk -rx "core show version"
asterisk -rx "pjsip show endpoints"
asterisk -rx "pjsip show registrations"
asterisk -rx "core show channels"
asterisk -rx "dialplan show"
asterisk -rx "voicemail show users"

# Reload configuration
asterisk -rx "core reload"
asterisk -rx "pjsip reload"
asterisk -rx "dialplan reload"
```

## Softphones (SIP Clients)

### Desktop
- **Linphone** (Linux, macOS, Windows)
- **Zoiper** (Cross-platform)
- **MicroSIP** (Windows)
- **Telephone** (macOS)

### Mobile
- **Linphone** (iOS, Android)
- **Zoiper** (iOS, Android)
- **Grandstream Wave** (iOS, Android)

### Configuration Example (Linphone)

```
Username: 100
Password: secret100
Domain: your-server-ip
Transport: UDP
Port: 5060
```

## Troubleshooting

### View Logs

```bash
# Asterisk logs
docker exec -it asterisk tail -f /var/log/asterisk/messages

# Full debug
docker exec -it asterisk asterisk -rvvvvv
```

### Common Issues

**Registration failing**
```bash
# Check endpoint status
asterisk -rx "pjsip show endpoints"
asterisk -rx "pjsip show registrations"
```

**No audio (one-way or no audio)**
- Check RTP ports are open (10000-10099/udp)
- Verify NAT settings in pjsip.conf
- Try `direct_media=no` and `rtp_symmetric=yes`

**TLS/SRTP issues**
```bash
# Check certificates
asterisk -rx "pjsip show transports"
```

## Backup

```bash
# Backup configuration
docker exec asterisk tar czf /tmp/asterisk-backup.tar.gz /srv
docker cp asterisk:/tmp/asterisk-backup.tar.gz ./

# Backup with volumes
docker run --rm \
  -v asterisk-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/asterisk-data.tar.gz -C /data .
```

## Security Recommendations

1. **Strong Passwords**: Use complex passwords for all extensions
2. **Firewall**: Restrict SIP ports to known IPs
3. **TLS/SRTP**: Enable encryption for all communications
4. **Fail2Ban**: Enable automatic IP blocking
5. **Regular Updates**: Keep Asterisk image updated
6. **Disable Guest**: Don't allow unauthenticated calls

## Documentation

- [Asterisk Official](https://www.asterisk.org/)
- [Asterisk Documentation](https://docs.asterisk.org/)
- [PJSIP Configuration](https://docs.asterisk.org/Configuration/Channel-Drivers/SIP/Configuring-res_pjsip/)
- [FreePBX](https://www.freepbx.org/)
- [Asterisk Wiki](https://wiki.asterisk.org/)
