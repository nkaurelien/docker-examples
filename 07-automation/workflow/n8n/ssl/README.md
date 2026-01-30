# SSL/TLS Certificates for n8n

This directory should contain your SSL/TLS certificates for HTTPS access to n8n.

## Self-Signed Certificates (Development)

For development purposes, you can generate self-signed certificates:

```bash
# Generate self-signed certificate (valid for 365 days)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/key.pem \
  -out ssl/cert.pem \
  -subj "/C=FR/ST=IDF/L=Paris/O=Dev/CN=localhost"
```

## Let's Encrypt Certificates (Production)

For production, use Let's Encrypt with certbot:

```bash
# Install certbot
sudo apt-get install certbot

# Generate certificate (replace with your domain)
sudo certbot certonly --standalone -d n8n.yourdomain.com

# Copy certificates to this directory
sudo cp /etc/letsencrypt/live/n8n.yourdomain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/n8n.yourdomain.com/privkey.pem ssl/key.pem
sudo chmod 644 ssl/cert.pem
sudo chmod 600 ssl/key.pem
```

## Using with Docker Compose

After placing your certificates in this directory:

1. Uncomment the HTTPS server block in `nginx.conf`
2. Uncomment the HTTPS port and SSL volume mount in `docker-compose.yml`
3. Update `N8N_PROTOCOL` to `https` in your `.env` file
4. Update `WEBHOOK_URL` to use `https://` in your `.env` file
5. Restart the services: `docker compose down && docker compose up -d`

## Files

- `cert.pem` - SSL certificate (public)
- `key.pem` - Private key (keep secure!)

## Security Notes

- **Never commit certificates to version control**
- Keep private keys secure (chmod 600)
- Renew certificates before expiration
- For Let's Encrypt, set up automatic renewal
