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
- ✅ Running on nodes with public IPs
- ✅ Need optimal WebRTC performance and low latency
- ✅ Want to avoid TURN relay infrastructure
- ✅ Security policies allow hostNetwork

---

## Alternative: LoadBalancer Without hostNetwork

For environments where `hostNetwork: true` is not permitted:

```yaml
networking:
  hostNetwork: false   # Use standard pod networking
  useHostPort: false   # No host port binding

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
- ❌ Cloud provider with UDP LoadBalancer support (AWS NLB, GCP, Azure Standard)
- ❌ TURN server infrastructure for NAT traversal
- ❌ Higher latency and bandwidth costs
- ❌ Additional RTCD configuration for ICE servers

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

## Alternative: NodePort Without hostNetwork

For on-premises or environments without LoadBalancer support:

```yaml
networking:
  hostNetwork: false
  useHostPort: false

service:
  type: NodePort
  externalTrafficPolicy: "Local"
  # Optionally specify NodePorts (30000-32767 range)
```

**Requirements:**
- ❌ Firewall rules to allow NodePort range
- ❌ TURN server infrastructure
- ❌ External load balancing solution
- ❌ Clients connect to `<node-ip>:<node-port>`

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
    add:
      - NET_BIND_SERVICE  # Only if binding to ports < 1024

podSecurityContext:
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault
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

### Example 2: AWS with NLB

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

| Configuration | Bandwidth Cost | Complexity | TURN Required |
|--------------|----------------|------------|---------------|
| hostNetwork + Public IP | Low | Low | No |
| LoadBalancer | High | Medium | Yes |
| NodePort + External LB | High | High | Yes |

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
- Or switch to NodePort

---

## Migration Guide

### Migrating FROM hostNetwork TO LoadBalancer

1. Deploy TURN infrastructure first
2. Update values.yaml with LoadBalancer configuration
3. Apply the changes (will cause brief downtime)
4. Get LoadBalancer external IP: `kubectl get svc`
5. Update RTCD environment variables with external IP
6. Rolling restart pods

### Migrating FROM LoadBalancer TO hostNetwork

1. Ensure nodes have public IPs
2. Update values.yaml with hostNetwork configuration
3. Remove TURN server configurations
4. Apply changes
5. Pods will restart and bind to node IPs directly

