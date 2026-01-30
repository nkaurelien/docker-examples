# Longhorn - Cloud Native Distributed Storage for Kubernetes

Longhorn is a lightweight, reliable, and powerful distributed block storage system for Kubernetes. It implements distributed block storage using containers and microservices.

## Features

- Enterprise-grade distributed storage with no single point of failure
- Incremental snapshot and backup to S3/NFS
- Cross-cluster disaster recovery
- Scheduled backups and snapshots
- Built-in UI for management
- CSI driver for Kubernetes integration
- ReadWriteMany (RWX) volume support
- Volume encryption
- Data locality for performance optimization

## Prerequisites

- Kubernetes cluster (v1.21+)
- `open-iscsi` installed on all nodes
- `NFSv4` client installed (for RWX volumes)
- Each node requires at least one disk for storage

### Node Requirements

```bash
# Install open-iscsi on each node (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y open-iscsi
sudo systemctl enable iscsid
sudo systemctl start iscsid

# For RHEL/CentOS
sudo yum install -y iscsi-initiator-utils
sudo systemctl enable iscsid
sudo systemctl start iscsid
```

## Installation Methods

### Method 1: Helm (Recommended)

```bash
# Add Longhorn Helm repository
helm repo add longhorn https://charts.longhorn.io
helm repo update

# Create namespace
kubectl create namespace longhorn-system

# Install Longhorn
helm install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --set defaultSettings.defaultDataPath="/var/lib/longhorn" \
  --set persistence.defaultClassReplicaCount=3
```

### Method 2: kubectl

```bash
# Apply Longhorn manifests
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.7.2/deploy/longhorn.yaml

# Verify installation
kubectl -n longhorn-system get pods
```

### Method 3: Rancher Apps & Marketplace

1. Navigate to your cluster in Rancher
2. Go to Apps & Marketplace
3. Search for "Longhorn"
4. Click Install and configure options

## Configuration

### values.yaml (Helm)

```yaml
# values.yaml
defaultSettings:
  # Default data path on the nodes
  defaultDataPath: /var/lib/longhorn
  # Replica count for new volumes
  defaultReplicaCount: 3
  # Backup target (S3 or NFS)
  backupTarget: ""
  # Create default disk on labeled nodes only
  createDefaultDiskLabeledNodes: false

persistence:
  # Default storage class replica count
  defaultClassReplicaCount: 3
  # Set as default storage class
  defaultClass: true

ingress:
  enabled: true
  host: longhorn.apps.local
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls: "true"

# Resources for Longhorn components
longhornManager:
  resources:
    requests:
      cpu: 100m
      memory: 128Mi

longhornDriver:
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
```

### StorageClass Example

```yaml
# storageclass.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: longhorn-fast
  annotations:
    storageclass.kubernetes.io/is-default-class: "false"
provisioner: driver.longhorn.io
allowVolumeExpansion: true
reclaimPolicy: Delete
volumeBindingMode: Immediate
parameters:
  numberOfReplicas: "2"
  staleReplicaTimeout: "2880"
  fromBackup: ""
  fsType: "ext4"
  dataLocality: "best-effort"
```

## Usage

### Create a PersistentVolumeClaim

```yaml
# pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-longhorn-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn
  resources:
    requests:
      storage: 10Gi
```

### Use in a Pod

```yaml
# pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
    - name: app
      image: nginx
      volumeMounts:
        - name: data
          mountPath: /data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: my-longhorn-pvc
```

## Accessing the UI

The Longhorn UI is available through the Longhorn frontend service:

```bash
# Port forward to access locally
kubectl -n longhorn-system port-forward svc/longhorn-frontend 8080:80

# Or create an Ingress (see values.yaml above)
```

Access at: http://localhost:8080

## Backup Configuration

### S3 Backup Target

```bash
# Create secret for S3 credentials
kubectl create secret generic aws-secret \
  --from-literal=AWS_ACCESS_KEY_ID=<access-key> \
  --from-literal=AWS_SECRET_ACCESS_KEY=<secret-key> \
  -n longhorn-system

# Configure backup target in Longhorn UI or values.yaml:
# backupTarget: s3://bucket-name@region/
# backupTargetCredentialSecret: aws-secret
```

### NFS Backup Target

```yaml
# In values.yaml
defaultSettings:
  backupTarget: nfs://nfs-server:/path/to/backup
```

## Monitoring

Longhorn exposes Prometheus metrics on port 9500:

```yaml
# ServiceMonitor for Prometheus Operator
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: longhorn-prometheus
  namespace: longhorn-system
spec:
  selector:
    matchLabels:
      app: longhorn-manager
  endpoints:
    - port: manager
```

## Troubleshooting

```bash
# Check Longhorn pods
kubectl -n longhorn-system get pods

# View Longhorn manager logs
kubectl -n longhorn-system logs -l app=longhorn-manager

# Check node status
kubectl get nodes.longhorn.io -n longhorn-system

# Check volumes
kubectl get volumes.longhorn.io -n longhorn-system

# Check replicas
kubectl get replicas.longhorn.io -n longhorn-system
```

## Uninstallation

```bash
# Using Helm
helm uninstall longhorn -n longhorn-system

# Using kubectl
kubectl delete -f https://raw.githubusercontent.com/longhorn/longhorn/v1.7.2/deploy/longhorn.yaml

# Clean up namespace
kubectl delete namespace longhorn-system
```

## Documentation

- [Official Documentation](https://longhorn.io/docs/)
- [GitHub Repository](https://github.com/longhorn/longhorn)
- [CNCF Sandbox Project](https://www.cncf.io/projects/longhorn/)
- [Best Practices](https://longhorn.io/docs/latest/best-practices/)
