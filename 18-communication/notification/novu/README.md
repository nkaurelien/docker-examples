# Novu - Open-Source Notification Infrastructure

Novu is a comprehensive notification infrastructure platform that provides a unified API for managing multi-channel notifications including Email, SMS, Push, Chat, and In-App notifications.

## Features

- **Multi-Channel Notifications**: Email, SMS, Push, Chat, In-App
- **Workflow Engine**: Build complex notification workflows
- **Template Management**: Create and manage notification templates
- **Provider Integration**: Support for 50+ notification providers
- **Subscriber Management**: Manage notification recipients
- **Notification Center**: Embeddable in-app notification center
- **Analytics & Logs**: Track notification delivery and engagement
- **API-First Design**: RESTful API for all operations

## Architecture

This setup includes:
- **API**: Main REST API server
- **Worker**: Background job processor for sending notifications
- **WebSocket (WS)**: Real-time updates for in-app notifications
- **Dashboard**: Web-based management interface
- **MongoDB**: Database for storing workflows, templates, and subscribers
- **Redis**: Cache and message queue
- **MinIO**: S3-compatible storage for attachments and assets

## Quick Start

### 1. Setup Environment

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env and customize your settings
nano .env
```

**Important**: Generate secure secrets before starting:

```bash
# Generate JWT secret
openssl rand -hex 32

# Generate encryption key
openssl rand -hex 32

# Generate Novu secret key
openssl rand -hex 32
```

Add these to your `.env` file:
```env
JWT_SECRET=<generated_jwt_secret>
STORE_ENCRYPTION_KEY=<generated_encryption_key>
NOVU_SECRET_KEY=<generated_novu_secret_key>
```

### 2. Start Services

```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### 3. Access Novu

- **Dashboard**: http://localhost:4000
- **API**: http://localhost:3000
- **WebSocket**: http://localhost:3002
- **MinIO Console**: http://localhost:9001

Initial setup:
1. Open the Dashboard at http://localhost:4000
2. Create your admin account
3. Create your first application
4. Get your API key from the settings

## Configuration

### Core Services

#### API Configuration
```env
API_ROOT_URL=http://localhost:3000
API_PORT=3000
FRONT_BASE_URL=http://localhost:4000
```

#### Database Configuration
```env
# MongoDB
MONGO_URL=mongodb://root:password@mongodb:27017/novu-db?authSource=admin
MONGO_MIN_POOL_SIZE=10
MONGO_MAX_POOL_SIZE=500

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
```

#### Storage Configuration
```env
# MinIO (S3-compatible)
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=your_secure_password
S3_LOCAL_STACK=http://minio:9000
S3_BUCKET_NAME=novu
```

#### Security Configuration
```env
JWT_SECRET=your_jwt_secret_here
STORE_ENCRYPTION_KEY=your_encryption_key_here
NOVU_SECRET_KEY=your_novu_secret_key_here
```

### Feature Flags

```env
IS_API_IDEMPOTENCY_ENABLED=true
IS_API_RATE_LIMITING_ENABLED=false
IS_NEW_MESSAGES_API_RESPONSE_ENABLED=false
IS_V2_ENABLED=false
```

## Usage Examples

### Using the API

#### Trigger a Notification

```bash
curl -X POST http://localhost:3000/v1/events/trigger \
  -H "Authorization: ApiKey YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "welcome-email",
    "to": {
      "subscriberId": "user-123",
      "email": "user@example.com"
    },
    "payload": {
      "userName": "John Doe"
    }
  }'
```

#### Create a Subscriber

```bash
curl -X POST http://localhost:3000/v1/subscribers \
  -H "Authorization: ApiKey YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "subscriberId": "user-123",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe"
  }'
```

### Integration Examples

#### Node.js/TypeScript

```typescript
import { Novu } from '@novu/node';

const novu = new Novu('YOUR_API_KEY');

// Trigger notification
await novu.trigger('welcome-email', {
  to: {
    subscriberId: 'user-123',
    email: 'user@example.com',
  },
  payload: {
    userName: 'John Doe',
  },
});

// Create subscriber
await novu.subscribers.identify('user-123', {
  email: 'user@example.com',
  firstName: 'John',
  lastName: 'Doe',
});
```

#### Python

```python
from novu.api import EventApi

event_api = EventApi("http://localhost:3000", "YOUR_API_KEY")

# Trigger notification
event_api.trigger(
    name="welcome-email",
    recipients="user-123",
    payload={
        "userName": "John Doe"
    }
)
```

## Common Commands

```bash
# Service Management
docker-compose up -d              # Start all services
docker-compose down               # Stop all services
docker-compose restart            # Restart all services
docker-compose ps                 # Show service status

# View Logs
docker-compose logs -f            # All services
docker-compose logs -f api        # API only
docker-compose logs -f worker     # Worker only
docker-compose logs -f mongodb    # MongoDB only

# Access Shells
docker-compose exec api sh        # API shell
docker-compose exec mongodb mongosh  # MongoDB shell

# Health Checks
curl http://localhost:3000/v1/health     # API health
docker-compose ps                         # Service health
```

## Service Details

### API Service
- **Port**: 3000
- **Purpose**: REST API for all Novu operations
- **Health Check**: http://localhost:3000/v1/health

### Worker Service
- **Purpose**: Background job processor for sending notifications
- **Queues**: Handles email, SMS, push, and other notification channels
- **Scalable**: Can run multiple workers for high throughput

### WebSocket Service
- **Port**: 3002
- **Purpose**: Real-time updates for in-app notifications
- **Protocol**: WebSocket for bi-directional communication

### Dashboard Service
- **Port**: 4000
- **Purpose**: Web-based management interface
- **Features**: Workflow builder, template editor, analytics

### MongoDB
- **Port**: 27017
- **Purpose**: Primary database
- **Data**: Workflows, templates, subscribers, notifications

### Redis
- **Port**: 6379
- **Purpose**: Caching and message queue
- **Uses**: Job queue, rate limiting, caching

### MinIO
- **Ports**: 9000 (API), 9001 (Console)
- **Purpose**: S3-compatible object storage
- **Data**: Email attachments, images, assets

## Production Considerations

### Security

1. **Change Default Passwords**: Update all passwords in `.env`
2. **Generate Strong Secrets**: Use `openssl rand -hex 32` for all secrets
3. **Use HTTPS**: Configure reverse proxy with SSL certificates
4. **Network Security**: Don't expose MongoDB, Redis, or MinIO ports publicly
5. **API Authentication**: Always use API keys, never expose them

### Reverse Proxy Configuration

Example nginx configuration:

```nginx
# API
server {
    listen 443 ssl;
    server_name api.novu.yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Dashboard
server {
    listen 443 ssl;
    server_name novu.yourdomain.com;

    location / {
        proxy_pass http://localhost:4000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

# WebSocket
server {
    listen 443 ssl;
    server_name ws.novu.yourdomain.com;

    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
```

Update `.env` for production:
```env
API_ROOT_URL=https://api.novu.yourdomain.com
FRONT_BASE_URL=https://novu.yourdomain.com
VITE_API_HOSTNAME=https://api.novu.yourdomain.com
VITE_WEBSOCKET_HOSTNAME=https://ws.novu.yourdomain.com
```

### Performance Tuning

#### MongoDB
```env
MONGO_MIN_POOL_SIZE=10
MONGO_MAX_POOL_SIZE=500
MONGO_AUTO_CREATE_INDEXES=true
```

#### Worker Scaling
Run multiple worker instances:
```bash
docker-compose up -d --scale worker=3
```

#### Queue Configuration
```env
BROADCAST_QUEUE_CHUNK_SIZE=100
MULTICAST_QUEUE_CHUNK_SIZE=100
```

### Monitoring

#### Sentry Integration
```env
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
```

#### New Relic Integration
```env
NEW_RELIC_ENABLED=true
NEW_RELIC_APP_NAME=novu-production
NEW_RELIC_LICENSE_KEY=your-license-key
```

### Backup Strategy

#### Database Backup
```bash
# Backup MongoDB
docker-compose exec -T mongodb mongodump \
  --uri="mongodb://root:password@localhost:27017/novu-db?authSource=admin" \
  --archive=/tmp/backup.archive

docker-compose exec mongodb cat /tmp/backup.archive > backup-$(date +%Y%m%d).archive
```

#### MinIO Backup
```bash
# Backup MinIO data
docker-compose exec -T minio mc mirror /data /backup
```

## Troubleshooting

### Services Not Starting

1. Check logs: `docker-compose logs -f`
2. Verify ports are available: `netstat -tulpn | grep -E '3000|3002|4000|9000|9001|27017|6379'`
3. Check health: `docker-compose ps`

### MongoDB Connection Issues

```bash
# Check MongoDB is running
docker-compose ps mongodb

# Test connection
docker-compose exec mongodb mongosh \
  "mongodb://root:password@localhost:27017/novu-db?authSource=admin" \
  --eval "db.adminCommand('ping')"
```

### API Not Responding

```bash
# Check API logs
docker-compose logs -f api

# Check health endpoint
curl http://localhost:3000/v1/health

# Restart API
docker-compose restart api
```

### Worker Not Processing Jobs

```bash
# Check worker logs
docker-compose logs -f worker

# Check Redis connection
docker-compose exec redis redis-cli ping

# Restart worker
docker-compose restart worker
```

### MinIO Access Issues

1. Verify credentials match in `.env`:
   ```env
   MINIO_ROOT_USER=admin
   AWS_ACCESS_KEY_ID=admin  # Must match MINIO_ROOT_USER
   ```

2. Access MinIO console: http://localhost:9001

### Reset Everything

```bash
# Stop and remove all data (⚠️  DESTRUCTIVE)
docker-compose down -v
rm -rf mongodb/ minio_data/

# Start fresh
docker-compose up -d
```

## Resources

- **Official Documentation**: https://docs.novu.co
- **GitHub Repository**: https://github.com/novuhq/novu
- **API Reference**: https://docs.novu.co/api/overview
- **Discord Community**: https://discord.gg/novu
- **Blog**: https://novu.co/blog

## Support

- **Documentation**: https://docs.novu.co
- **GitHub Issues**: https://github.com/novuhq/novu/issues
- **Discord**: https://discord.gg/novu
- **Twitter**: @novuhq

## License

Novu is open source and licensed under the MIT License.
