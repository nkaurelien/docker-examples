# cert-manager

cert-manager is a Kubernetes certificate controller for automated TLS certificate management.

## Features

- Automatic certificate provisioning
- Let's Encrypt integration
- Certificate renewal
- Multiple issuers (ACME, Vault, self-signed)
- Ingress integration

## Installation

```bash
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true
```

## Resources

- [Official Documentation](https://cert-manager.io/docs/)
- [GitHub](https://github.com/cert-manager/cert-manager)
