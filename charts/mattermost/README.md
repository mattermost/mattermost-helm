# Mattermost Helm Chart (No Operator)

This Helm chart deploys Mattermost Enterprise Edition without the Mattermost Operator, specifically designed for environments where you want to manage database and file storage separately.

## When to Use This Chart

**Use the [Mattermost Operator](../mattermost-operator/) if possible** - it provides better lifecycle management, automated upgrades, and simplified operations.

**Use this chart if:**
- You cannot create `ClusterRole` or `ClusterRoleBinding` resources (restricted RBAC permissions)
- You need a minimal deployment without operator overhead
- You prefer direct control over Mattermost configuration

## Key Features

- **No ClusterRole required** - operates within namespace permissions only
- **External dependencies** - requires external PostgreSQL and S3-compatible storage
- **Optional components**:
  - NGINX Ingress support (not mandatory)
  - Dedicated job server for background tasks (not mandatory)
- **Minimal resource footprint** - single replica by default, scalable as needed
- **Flexible configuration** - full control via values.yaml and environment variables

To learn more about Helm charts, see the [Helm docs](https://helm.sh/docs/).

# 1. Prerequisites

## 1.1 Required External Services

Before deploying, you must have:

1. **External Database**: PostgreSQL 11+
   - Database and user created
   - Connection string ready
   
2. **External File Storage**: S3-compatible object storage (AWS S3, GCS, MinIO, etc.)
   - Bucket created
   - Access credentials ready

## 1.2 Kubernetes Cluster

You need a running Kubernetes cluster v1.19+.

## 1.3 Helm

We recommend Helm v3.x or later. See: https://helm.sh/docs/intro/install/

## 1.4 (Optional) Ingress Controller

To expose Mattermost outside your cluster, you'll need an ingress controller. For GDC deployments, use the ingress controller provided by your platform.

For other environments, we recommend [nginx-ingress](https://kubernetes.github.io/ingress-nginx/).

# 2. Configuration

Create a `values.yaml` file with your configuration. Here's a minimal example:

```yaml
global:
  siteUrl: "https://mattermost.example.com"
  mattermostLicense: "YOUR_LICENSE_KEY_HERE"
  
  features:
    database:
      driver: "postgres"
      dataSource: "postgres://user:password@hostname:5432/mattermost?sslmode=require"
    
    fileStore:
      driver: "amazons3"
      bucket: "my-mattermost-bucket"
      region: "us-east-1"
      # Option 1: Use existing secret (recommended)
      existingSecret:
        name: "mattermost-s3-creds"  # Name of your Kubernetes Secret
        accessKeyIdKey: "accessKeyId"  # Key in secret with access key ID
        secretAccessKeyKey: "secretAccessKey"  # Key in secret with secret key
      # Option 2: Provide credentials directly (not recommended for production)
      # accessKeyId: "YOUR_ACCESS_KEY"
      # secretAccessKey: "YOUR_SECRET_KEY"

mattermostApp:
  replicaCount: 2
  
  ingress:
    enabled: true
    hosts:
      - mattermost.example.com
    tls:
      - secretName: mattermost-tls
        hosts:
          - mattermost.example.com
```

## 2.1 Required Settings

**Minimum required configuration:**

1. `global.siteUrl` - URL users will access Mattermost at
2. `global.mattermostLicense` - Your Mattermost Enterprise license (optional, but recommended)
3. `global.features.database.driver` - Database type: `postgres`
4. `global.features.database.dataSource` - Database connection string
5. `global.features.fileStore.driver` - File storage driver: `amazons3` or `local`
6. `global.features.fileStore.bucket` - S3 bucket name (when using `amazons3`)

## 2.2 Database Configuration

**PostgreSQL connection string format:**
```
postgres://username:password@hostname:5432/dbname?sslmode=require
```

**Using a Kubernetes Secret for database credentials:**
```yaml
global:
  features:
    database:
      existingDatabaseSecret:
        name: mattermost-db-secret
        key: connection-string
```

## 2.3 File Storage Configuration

Configure S3-compatible storage via environment variables in `mattermostApp.extraEnv`. Create a Kubernetes secret for credentials:

```bash
kubectl create secret generic mattermost-s3-credentials \
  --from-literal=access-key-id=YOUR_ACCESS_KEY \
  --from-literal=secret-access-key=YOUR_SECRET_KEY
```

## 2.4 Ingress (Optional)

Ingress is **optional** - you can use `kubectl port-forward`, a LoadBalancer service, or NodePort instead.

To enable NGINX Ingress for external access:

```yaml
mattermostApp:
  ingress:
    enabled: true
    hosts:
      - mattermost.example.com
    tls:
      - secretName: mattermost-tls
        hosts:
          - mattermost.example.com
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/proxy-body-size: 50m
    ingressClassName: nginx  # Or leave empty for default
```

**For GDC deployments:** Adjust `annotations` and `ingressClassName` according to your platform's ingress controller.

**Alternative access methods:**
```bash
# Port forwarding (development)
kubectl port-forward svc/mattermost-app 8065:8065

# Or configure as LoadBalancer
mattermostApp:
  service:
    type: LoadBalancer
```

## 2.5 Job Server (Optional)

The job server is **optional** - by default, the main app handles all jobs.

Enable a dedicated job server for better resource isolation and scalability:

```yaml
global:
  features:
    jobserver:
      enabled: true
      replicaCount: 1
      resources:
        requests:
          cpu: 100m
          memory: 200Mi
        limits:
          cpu: 500m
          memory: 512Mi
```

When enabled, the main application pods will delegate background tasks (scheduled posts, compliance exports, data retention, etc.) to the dedicated job server pod.

# 3. Install

## 3.1 From Local Chart

Install the chart from this repository:

```bash
cd charts/mattermost
helm install mattermost . -f values.yaml
```

## 3.2 Upgrade

To upgrade an existing release:

```bash
helm upgrade mattermost . -f values.yaml
```

## 3.3 Uninstall

To remove the deployment:

```bash
helm uninstall mattermost
```

# 4. Verification

After installation, verify the deployment:

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=mattermost

# Check logs
kubectl logs -l app.kubernetes.io/name=mattermost

# Test connectivity (if using ClusterIP)
kubectl port-forward svc/mattermost-app 8065:8065
```

Then access Mattermost at http://localhost:8065 (or your configured ingress URL).

# 5. Scaling

## 5.1 Manual Scaling

To scale horizontally, increase the replica count:

```yaml
mattermostApp:
  replicaCount: 3
```

Or scale directly with kubectl:
```bash
kubectl scale deployment mattermost --replicas=5
```

**Note:** For multi-replica deployments, ensure your file storage is accessible from all pods (use S3-compatible storage, not local).

## 5.2 Horizontal Pod Autoscaler (HPA) - Optional

HPA can automatically scale replicas based on CPU/memory usage, but it requires:

**Prerequisites:**
- ✅ Kubernetes metrics-server installed in your cluster
- ✅ Resource requests/limits defined in `mattermostApp.resources`

**Check if metrics-server is available:**
```bash
kubectl get apiservice v1beta1.metrics.k8s.io
```

**Enable HPA:**
```yaml
mattermostApp:
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70
    targetMemoryUtilizationPercentage: 70
  
  # Required for HPA
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      cpu: 1000m
      memory: 1Gi
```

**Important:** Many restricted environments (like GDC) may not have metrics-server installed. If you cannot install metrics-server due to permission restrictions, use manual scaling instead.

# 6. Troubleshooting

**Database connection issues:**
- Verify the connection string is correct
- Ensure network policies allow pod-to-database communication
- Check database credentials

**File storage issues:**
- Verify S3 credentials are correct
- Ensure bucket exists and is accessible
- Check S3 endpoint and region configuration

**Pod not starting:**
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

# 7. Development

For local development and testing:

```bash
# Dry run to see generated manifests
helm install mattermost . -f values.yaml --dry-run --debug

# Use kind for local Kubernetes cluster
kind create cluster
helm install mattermost . -f values.yaml
```
