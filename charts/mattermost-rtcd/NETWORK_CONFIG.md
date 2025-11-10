# RTCD Network Configuration Options

This chart now supports flexible networking configurations to accommodate different security requirements and infrastructure setups.

## Default Configuration (Recommended)

By default, the chart uses **hostNetwork with hostPort** for optimal WebRTC performance:

```yaml
networking:
  hostNetwork: true    # Pods use host network namespace
  useHostPort: true    # Bind ports directly to node ports

service:
  type: ClusterIP
  clusterIP: "None"    # Headless service
```

**Use this when:**
- Running on nodes with public IPs
- Need optimal WebRTC performance and low latency
- Want to avoid TURN relay infrastructure
- Security policies allow hostNetwork

---

## Alternative: LoadBalancer Without hostNetwork

⚠️ **CRITICAL LIMITATION**: LoadBalancer mode **only supports a SINGLE RTCD instance**. Multiple instances behind a LoadBalancer will cause call failures.

### Why Multiple Instances Don't Work:

When a call starts, Mattermost selects **one specific RTCD instance** to host that call. All participants must connect to that same instance. With a LoadBalancer:
- The LoadBalancer distributes connections across all RTCD backends
- Different clients in the same call get routed to different RTCD instances
- **Result**: Call participants cannot communicate with each other

**Use LoadBalancer only if:**
- Running a **single RTCD instance** (no scaling)
- Development/testing environments

For environments where `hostNetwork: true` is not permitted:

```yaml
networking:
  hostNetwork: false   # Use standard pod networking
  useHostPort: false   # No host port binding

configuration:
  replicas: 1          # ⚠️ MUST be 1 - multiple instances don't work with LoadBalancer

service:
  type: LoadBalancer
  clusterIP: ""        # Normal ClusterIP (not headless)
  externalTrafficPolicy: "Local"
  annotations:
    # AWS NLB (supports UDP)
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    # Or GCP
    # cloud.google.com/load-balancer-type: "External"
    # Or Azure
    # service.beta.kubernetes.io/azure-load-balancer-sku: "standard"
```

**Requirements:**
- Cloud provider with UDP LoadBalancer support (AWS NLB, GCP, Azure Standard)
- TURN server infrastructure for NAT traversal
- Additional RTCD configuration for ICE servers

**RTCD Configuration needed:**

```yaml
configuration:
  environmentVariables:
    # Point to your TURN servers
    RTCD_RTC_ICESERVERS: '[{"urls":["turn:your-turn-server.com:3478"],"username":"user","credential":"pass"}]'
    # Set to your LoadBalancer's external IP
    RTCD_RTC_ICEHOSTOVERRIDE: "YOUR_LOADBALANCER_EXTERNAL_IP"
```

---

## Security Considerations with hostNetwork

If security is a concern but hostNetwork is needed, apply these mitigations:

```yaml
# Use dedicated node pool
nodeSelector:
  workload: rtcd

# Apply Network Policies
# (create separately to restrict pod communication)

# Run as non-root with minimal capabilities
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  capabilities:
    drop:
      - ALL


podSecurityContext:
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault
```

---

## Mattermost Integration Configuration

Regardless of networking approach, Mattermost needs to be configured to communicate with RTCD.

### Configuration Location

**Via System Console**: System Console → Plugins → Calls → RTCD Service URL

**Via config.json**:
```json
{
  "PluginSettings": {
    "Plugins": {
      "com.mattermost.calls": {
        "rtcdserviceurl": "https://YOUR_RTCD_URL:PORT",
        "rtcdenabled": true
      }
    }
  }
}
```

### URL Configuration by Deployment Type:

#### With hostNetwork (Default - Internal Service)

```json
{
  "rtcdserviceurl": "https://mattermost-rtcd.mattermost.svc.cluster.local:8045"
}
```

**Pros:**
- Uses Kubernetes internal DNS
- No external dependencies
- Automatic service discovery
- Works across namespace if FQDN used

**Note**: Clients still connect directly to node public IPs for WebRTC media. The Mattermost server uses internal service for API calls only.

#### With hostNetwork (Mattermost Outside Cluster)

If Mattermost is running **outside** the Kubernetes cluster, you have two options:

**Option A: Use Ingress/External Load Balancer (Recommended)**

```json
{
  "rtcdserviceurl": "https://calls.example.com:8045"
}
```

Deploy an Ingress or external load balancer in front of the RTCD service for API access. 

**Important**: The Ingress/LB is **only for API discovery** (Mattermost server querying which RTCD instances are available). WebRTC media traffic from clients will still go **directly to node public IPs**, bypassing the Ingress. Mattermost performs the load distribution by selecting the appropriate RTCD instance per call.

**Option B: Use Single Node IP (Dev/Testing Only)**

```json
{
  "rtcdserviceurl": "https://rtcd-node-1.example.com:8045"
}
```

⚠️ **Not recommended for production**: If the pod reschedules to a different node, this URL will break. No automatic failover.

#### With Cloud LoadBalancer

```json
{
  "rtcdserviceurl": "https://a1b2c3d4.us-east-1.elb.amazonaws.com:8045"
}
```

**Important**: 
- Get external IP: `kubectl get svc mattermost-rtcd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'`
- Update `RTCD_RTC_ICEHOSTOVERRIDE` with same address
- Clients and Mattermost use same LoadBalancer endpoint

### Health Check

Verify RTCD connectivity from Mattermost:

```bash
# From within Mattermost pod
curl https://mattermost-rtcd.mattermost.svc.cluster.local:8045/version

# Expected response:
{"version":"v0.x.x","buildHash":"...","buildDate":"..."}
```

---

## Configuration Examples

### Example 1: Default (hostNetwork + Public IPs)

```yaml
# values.yaml
networking:
  hostNetwork: true
  useHostPort: true

service:
  type: ClusterIP
  clusterIP: "None"
  APIport: 8045
  RTCport: 8443

deploymentType: deployment
configuration:
  replicas: 2
```

### Example 2: AWS with NLB (Single Instance Only)

⚠️ **Note**: This configuration only works with a single RTCD instance. For production scaling, use hostNetwork approach.

```yaml
# values.yaml
networking:
  hostNetwork: false
  useHostPort: false

service:
  type: LoadBalancer
  clusterIP: ""
  externalTrafficPolicy: "Local"
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
  APIport: 8045
  RTCport: 8443

configuration:
  replicas: 1  # ⚠️ CRITICAL - must be 1 with LoadBalancer
  environmentVariables:
    RTCD_RTC_ICESERVERS: '[{"urls":["stun:stun.global.calls.mattermost.com:3478"]}]'
    # Set after LoadBalancer is created and external IP is assigned
    # RTCD_RTC_ICEHOSTOVERRIDE: "a1b2c3d4.us-east-1.elb.amazonaws.com"
```

### Example 3: Dedicated Secure Node Pool

```yaml
# values.yaml
networking:
  hostNetwork: true
  useHostPort: true

nodeSelector:
  node.kubernetes.io/workload: rtcd
  node.kubernetes.io/network: public

tolerations:
  - key: "workload"
    operator: "Equal"
    value: "rtcd"
    effect: "NoSchedule"

securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  capabilities:
    drop:
      - ALL

service:
  type: ClusterIP
  clusterIP: "None"
```

---

## Performance Comparison

| Configuration | Latency | Bandwidth Cost | Complexity | TURN Required | Scaling |
|--------------|---------|----------------|------------|---------------|---------|
| hostNetwork + Public IP | 5-20ms | Low | Low | No | ✅ Multiple instances |
| LoadBalancer | 50-150ms | High | Medium | Yes | ❌ Single instance only |

---

## Troubleshooting

### Issue: Pods fail to start with "address already in use"

**Cause:** Multiple pods scheduled on same node with hostPort enabled.

**Solution:** 
- Ensure pod anti-affinity is configured (default in values.yaml)
- Use DaemonSet instead of Deployment for one pod per node
- Or disable hostPort if not using hostNetwork

### Issue: WebRTC connections fail without hostNetwork

**Cause:** NAT traversal issues without TURN servers.

**Solution:**
- Configure TURN servers in `RTCD_RTC_ICESERVERS`
- Set `RTCD_RTC_ICEHOSTOVERRIDE` to LoadBalancer external IP
- Verify UDP ports are accessible through LoadBalancer

### Issue: Service shows no external IP (LoadBalancer pending)

**Cause:** Cloud provider doesn't support UDP LoadBalancers or quota exceeded.

**Solution:**
- Check cloud provider documentation for UDP support
- Verify LoadBalancer quota
- Consider using separate LoadBalancers for TCP and UDP
- If UDP LoadBalancer is not available, use hostNetwork approach instead
