# Longhorn

Longhorn is a lightweight, reliable distributed block storage system for Kubernetes.

## Features

- Distributed block storage
- Incremental snapshots and backups
- Cross-cluster disaster recovery
- Scheduled backups
- Volume encryption
- CSI driver

## Installation

```bash
# Helm
helm install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --create-namespace
```

## Resources

- [Official Documentation](https://longhorn.io/docs/)
- [GitHub](https://github.com/longhorn/longhorn)
