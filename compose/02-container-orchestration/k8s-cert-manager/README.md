# cert-manager - Kubernetes Certificate Management

cert-manager is a powerful and extensible X.509 certificate controller for Kubernetes. It automates the management and issuance of TLS certificates from various sources, including Let's Encrypt, HashiCorp Vault, Venafi, and private PKI.

## Features

- **Automatic Certificate Provisioning**: Automatically obtain certificates from Let's Encrypt and other ACME providers
- **Certificate Renewal**: Automatic renewal before expiry
- **Multiple Issuers**: Support for Let's Encrypt, Vault, Venafi, self-signed, and custom CAs
- **Kubernetes Native**: Certificates and Issuers are Kubernetes CRDs
- **Ingress Integration**: Works with nginx-ingress, Traefik, and other ingress controllers
- **DNS01 & HTTP01 Challenges**: Multiple ACME challenge solvers
- **Private PKI**: Create your own Certificate Authority
- **Cross-namespace Certificates**: ClusterIssuer for cluster-wide certificate issuance

## Prerequisites

- Kubernetes cluster (v1.22+)
- kubectl configured
- Helm 3.x (for Helm installation)

## Installation Methods

### Method 1: Helm (Recommended)

```bash
# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install cert-manager with CRDs
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.14.4 \
  --set installCRDs=true
```

### Method 2: kubectl

```bash
# Install cert-manager with CRDs
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml

# Verify installation
kubectl get pods -n cert-manager
```

### Method 3: kubectl with Helm template

```bash
# Generate manifests and apply
helm template cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true | kubectl apply -f -
```

## Configuration

### values.yaml (Helm)

```yaml
# values.yaml
installCRDs: true

replicaCount: 1

# Resources
resources:
  requests:
    cpu: 10m
    memory: 32Mi
  limits:
    cpu: 100m
    memory: 128Mi

# Prometheus metrics
prometheus:
  enabled: true
  servicemonitor:
    enabled: true

# Webhook configuration
webhook:
  replicaCount: 1
  resources:
    requests:
      cpu: 10m
      memory: 32Mi

# CA Injector
cainjector:
  enabled: true
  replicaCount: 1
  resources:
    requests:
      cpu: 10m
      memory: 32Mi

# Pod security
podSecurityContext:
  runAsNonRoot: true

# Logging
global:
  logLevel: 2

# Leader election
leader:
  lease:
    enabled: true
```

## Issuer Configuration

### Let's Encrypt (Production)

```yaml
# letsencrypt-prod-issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # Production server
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod-account-key
    solvers:
      # HTTP01 challenge
      - http01:
          ingress:
            class: traefik
```

### Let's Encrypt (Staging)

```yaml
# letsencrypt-staging-issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    # Staging server (for testing)
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-staging-account-key
    solvers:
      - http01:
          ingress:
            class: traefik
```

### DNS01 Challenge (Cloudflare)

```yaml
# cloudflare-issuer.yaml
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-token
  namespace: cert-manager
type: Opaque
stringData:
  api-token: your-cloudflare-api-token
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-dns
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-dns-account-key
    solvers:
      - dns01:
          cloudflare:
            apiTokenSecretRef:
              name: cloudflare-api-token
              key: api-token
```

### Self-Signed CA

```yaml
# self-signed-issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
---
# Create a CA certificate
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: my-ca
  namespace: cert-manager
spec:
  isCA: true
  commonName: my-ca
  secretName: my-ca-secret
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: selfsigned-issuer
    kind: ClusterIssuer
---
# CA Issuer using the certificate
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: my-ca-issuer
spec:
  ca:
    secretName: my-ca-secret
```

## Usage

### Request a Certificate

```yaml
# certificate.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-com-tls
  namespace: default
spec:
  secretName: example-com-tls-secret
  duration: 2160h # 90 days
  renewBefore: 360h # 15 days before expiry
  subject:
    organizations:
      - My Organization
  isCA: false
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
  usages:
    - server auth
    - client auth
  dnsNames:
    - example.com
    - www.example.com
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
```

### Ingress Annotation (Automatic)

```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: traefik
  tls:
    - hosts:
        - myapp.example.com
      secretName: myapp-tls
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-app
                port:
                  number: 80
```

### Traefik IngressRoute

```yaml
# ingressroute.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: myapp-cert
  namespace: default
spec:
  secretName: myapp-tls
  dnsNames:
    - myapp.apps.local
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: myapp
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`myapp.apps.local`)
      kind: Rule
      services:
        - name: my-app
          port: 80
  tls:
    secretName: myapp-tls
```

## Wildcard Certificates

```yaml
# wildcard-certificate.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: wildcard-apps-local
  namespace: default
spec:
  secretName: wildcard-apps-local-tls
  dnsNames:
    - "*.apps.local"
    - "apps.local"
  issuerRef:
    name: letsencrypt-dns  # DNS01 required for wildcards
    kind: ClusterIssuer
```

## Verification

```bash
# Check cert-manager pods
kubectl get pods -n cert-manager

# List ClusterIssuers
kubectl get clusterissuers

# List Certificates
kubectl get certificates -A

# Describe certificate
kubectl describe certificate example-com-tls

# Check certificate secret
kubectl get secret example-com-tls-secret -o yaml

# View certificate details
kubectl get secret example-com-tls-secret -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -text -noout

# Check certificate ready status
kubectl get certificates -A -o wide
```

## Troubleshooting

```bash
# Check cert-manager logs
kubectl logs -n cert-manager -l app=cert-manager

# Check webhook logs
kubectl logs -n cert-manager -l app=webhook

# Check certificate requests
kubectl get certificaterequests -A

# Describe failed certificate
kubectl describe certificaterequest <name>

# Check ACME orders
kubectl get orders -A

# Check ACME challenges
kubectl get challenges -A

# Force certificate renewal
kubectl delete secret <certificate-secret-name>
```

### Common Issues

**Certificate stuck in "Pending"**
```bash
# Check certificate request status
kubectl describe certificaterequest <name>

# Check order status
kubectl get orders -A
kubectl describe order <name>
```

**HTTP01 Challenge failing**
- Ensure ingress controller is properly configured
- Check that port 80 is accessible from the internet
- Verify DNS is pointing to the correct IP

**DNS01 Challenge failing**
- Verify API credentials are correct
- Check DNS propagation
- Ensure TXT record permissions

## Monitoring

### Prometheus Metrics

cert-manager exposes metrics on port 9402:

```yaml
# servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: cert-manager
  namespace: cert-manager
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: cert-manager
  endpoints:
    - port: http-metrics
      interval: 30s
```

### Key Metrics

- `certmanager_certificate_ready_status` - Certificate ready status
- `certmanager_certificate_expiration_timestamp_seconds` - Expiration time
- `certmanager_certificate_renewal_timestamp_seconds` - Next renewal time

## Uninstallation

```bash
# Using Helm
helm uninstall cert-manager -n cert-manager

# Remove CRDs (warning: deletes all certificates!)
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.crds.yaml

# Delete namespace
kubectl delete namespace cert-manager
```

## Documentation

- [Official Website](https://cert-manager.io/)
- [GitHub Repository](https://github.com/cert-manager/cert-manager)
- [Documentation](https://cert-manager.io/docs/)
- [ACME Configuration](https://cert-manager.io/docs/configuration/acme/)
- [Troubleshooting Guide](https://cert-manager.io/docs/troubleshooting/)
