# K8s Integration Helm Chart

![Version: 0.0.56](https://img.shields.io/badge/Version-0.0.56-informational?style=flat-square)  ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)  ![AppVersion: v25.326.1](https://img.shields.io/badge/AppVersion-v25.326.1-informational?style=flat-square)

This Helm chart deploys Miggo's Kubernetes integration components, providing comprehensive monitoring, security, and observability capabilities for your Kubernetes clusters.

## Features

- **K8s Resource Monitor**: Monitors Kubernetes resources and their changes
- **Static SBOM Analysis**: Software Bill of Materials analysis for container images
- **Dynamic eBPF Monitoring**: Runtime monitoring using eBPF technology
- **OpenTelemetry Collection**: Centralized telemetry data collection and export

## Prerequisites

- Kubernetes 1.23+
- Helm 3.9+
- Kernel 4.19+ (for eBPF support)
- Access to Miggo's container registry
- A valid Miggo platform tenant ID and project ID

## Components

The chart deploys several components that work together:

### K8s Read

Monitors Kubernetes resources and tracks changes in your cluster's configuration. Provides insights into deployments, services, and other Kubernetes objects.

### Static SBOM

Analyzes container images to generate Software Bill of Materials (SBOM), identifying dependencies and potential security vulnerabilities.

### Container Monitor

Uses eBPF technology to monitor runtime behavior of containers and system calls, providing deep visibility into container activities.

### Collector

Collects telemetry data (metrics, traces, logs) using OpenTelemetry protocol and forwards it to Miggo's platform.

## Getting Started

### Add Helm Repository

```bash
helm repo add miggo-charts https://miggo-io.github.io/miggo-helm-charts
helm repo update
```

### Installation

1. Create a values file (e.g., `my-values.yaml`):

```yaml
miggo:
  tenantId: "your-tenant-id"
  projectId: "your-project-id"
  clusterName: "your-cluster-name"

config:
  accessKey: "your-access-key"
```

2. Install the chart:

```bash
helm install k8s-integration miggo-charts/k8s-integration -f values.yaml --namespace miggo-space --create-namespace
```

## Configuration

The following table lists the configurable parameters of the k8s-integration chart and their default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Pod affinity settings for all pods |
| annotations | object | `{}` | Global annotations to add to all resources |
| collector.accessKeyMountLocation | string | `"/etc/miggo-access-key"` | An internal locaiton to mount the access key file within the container |
| collector.annotations | object | `{}` | Component-specific annotations |
| collector.config.logVerbosity | string | `"basic"` | Log verbosity level (detailed|normal|basic) |
| collector.enabled | bool | `true` | Enable Collector component |
| collector.extraEnvs | list | `[]` | Additional environment variables |
| collector.extraEnvsFrom | list | `[]` | Additional environment variables from sources |
| collector.image.fullPath | string | `nil` | Optional full image path override. If set, takes precedence over registry/repository/tag settings. Useful for local development with Minikube or when needing to specify a complete custom image path |
| collector.image.pullPolicy | string | `nil` | Image pull policy. Specifies when Kubernetes should pull the container image |
| collector.image.repository | string | `"miggoprod/miggo-infra-agent"` | Image repository |
| collector.image.tag | string | `nil` | Image tag (defaults to Chart appVersion if not set) |
| collector.initContainers | list | `[]` | InitContainers to initialize the pod |
| collector.instancePerNode | bool | `false` | Run an instance per node |
| collector.labels | object | `{}` | Component-specific labels |
| collector.podAnnotations | object | `{}` | Component-specific pod annotations |
| collector.podLabels | object | `{}` | Component-specific pod labels |
| collector.replicas | int | `1` | Number of replicas to run (relevant only if instancePerNode: false) |
| collector.resources | object | `{"limits":{"cpu":"100m","memory":"500Mi"},"requests":{"cpu":"10m","memory":"200Mi"}}` | Resource requirements |
| collector.service.annotations | object | `{}` | Service annotations |
| collector.service.labels | object | `{}` | Service labels |
| collector.service.ports | list | `[{"name":"http","port":4318,"protocol":"TCP","targetPort":4318},{"name":"grpc","port":4317,"protocol":"TCP","targetPort":4317}]` | Service ports |
| collector.service.type | string | `"ClusterIP"` | Service type |
| collector.useGOMEMLIMIT | bool | `true` | When enabled, the chart will set the GOMEMLIMIT env var to 80% of the configured resources.limits.memory. If no resources.limits.memory are defined then enabling does nothing. It is HIGHLY recommend to enable this setting and set a value for resources.limits.memory. |
| collector.volumeMounts | list | `[]` | Additional volume mounts |
| collector.volumes | list | `[]` | Additional volumes |
| config.accessKey | string | `""` | Access key for authentication (ignored when accessKeySecret is specified) |
| config.accessKeySecret | string | `""` | Name of the secret containing the access key. Leave empty to create default secrets based on config.accessKey |
| config.allowedNamespaces | string | `nil` | List of namespaces that are allowed to be processed If empty, all namespaces are included by default (before applying deniedNamespaces) Example: ["development", "staging", "production"] |
| config.clientId | string | `"P2UjsJwOFdIeUAtW0pGTJ5SeJAlq"` | Client ID for authentication |
| config.deniedNamespaces | string | `nil` | List of namespaces that should be excluded from processing Takes precedence over allowedNamespaces - if a namespace is both allowed and denied, it will be denied Example: ["test", "deprecated"] |
| config.includeSystemNamespaces | bool | `false` | When set to true, includes system namespaces like kube-system etc. When false (default), automatically adds system namespaces to deniedNamespaces It's recommended to keep this false unless you specifically need to operate on system namespaces |
| config.metrics.interval | string | `"60s"` | Interval for metrics collection |
| extraEnvs | list | `[]` | Additional environment variables for all containers |
| extraEnvsFrom | list | `[]` | Additional environment variables from sources for all containers |
| healthcheck.port | int | `6666` | Port number for health check endpoints |
| image | object | `{"pullPolicy":"IfNotPresent","registry":"registry.miggo.io"}` | Docker registry settings |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for all images |
| image.registry | string | `"registry.miggo.io"` | Registry host for all images |
| imagePullSecrets | list | `[]` |  |
| k8sRead.annotations | object | `{}` | Component-specific annotations |
| k8sRead.config.disableCompression | bool | `false` | Disable compression for data transfer |
| k8sRead.config.exclude | string | `"pod"` | Exclude those components from the report (comma separated list of persistent-volume-claim daemon-set stateful-set ingress ingress-class http-route network-policy namespace service-account persistent-volume cron-job node deployment job replica-set gateway-class pod service) |
| k8sRead.config.interval | string | `"6h"` | Interval for scanning Kubernetes resources |
| k8sRead.enabled | bool | `true` | Enable K8s Read component |
| k8sRead.extraEnvs | list | `[]` | Additional environment variables |
| k8sRead.extraEnvsFrom | list | `[]` | Additional environment variables from sources |
| k8sRead.image.fullPath | string | `nil` | Optional full image path override. If set, takes precedence over registry/repository/tag settings. Useful for local development with Minikube or when needing to specify a complete custom image path |
| k8sRead.image.pullPolicy | string | `nil` | Image pull policy. Specifies when Kubernetes should pull the container image |
| k8sRead.image.repository | string | `"miggoprod/k8s-read"` | Image repository |
| k8sRead.image.tag | string | `nil` | Image tag (defaults to Chart appVersion if not set) |
| k8sRead.labels | object | `{}` | Component-specific labels |
| k8sRead.podAnnotations | object | `{}` | Component-specific pod annotations |
| k8sRead.podLabels | object | `{}` | Component-specific pod labels |
| k8sRead.resources.limits.cpu | string | `"100m"` |  |
| k8sRead.resources.limits.memory | string | `"256Mi"` |  |
| k8sRead.resources.requests.cpu | string | `"10m"` |  |
| k8sRead.resources.requests.memory | string | `"128Mi"` |  |
| k8sRead.useGOMEMLIMIT | bool | `true` | When enabled, the chart will set the GOMEMLIMIT env var to 80% of the configured resources.limits.memory. If no resources.limits.memory are defined then enabling does nothing. It is HIGHLY recommend to enable this setting and set a value for resources.limits.memory. |
| k8sRead.volumeMounts | list | `[]` | Additional volume mounts |
| k8sRead.volumes | list | `[]` | Additional volumes |
| labels | object | `{}` | Global labels to add to all resources |
| miggo.clusterName | string | `"kubernetes-cluster"` | Name of the Kubernetes cluster |
| miggo.projectId | string | `""` | Project ID for the Miggo platform |
| miggo.tenantId | string | `""` | Tenant ID for the Miggo platform |
| nodeSelector | object | `{}` | Node selector for all pods |
| output.otlp.otlpEndpoint | string | `"https://api.miggo.io"` | OTLP endpoint URL |
| output.otlp.tlsSkipVerify | bool | `false` | Skip TLS verification |
| output.stdout | bool | `false` | Enable stdout logging (for debugging) |
| podAnnotations | object | `{}` | Pod annotations to add to all pods |
| podLabels | object | `{}` | Pod labels to add to all pods |
| podSecurityContext | object | `{}` | Pod security context for all pods |
| securityContext | object | `{}` | Container security context for all containers |
| sensor.enabled | bool | `false` | Install eBPF agent on each cluster node to provide package-level reachability analysis and other runtime insights. |
| sensor.extraEnvs | list | `[]` | Additional environment variables |
| sensor.extraEnvsFrom | list | `[]` | Additional environment variables from sources |
| sensor.hostIPC | bool | `true` | Use the host's ipc namespace. |
| sensor.hostPID | bool | `true` | Use the host's pid namespace. |
| sensor.image.fullPath | string | `nil` | Optional full image path override. If set, takes precedence over registry/repository/tag settings. Useful for local development with Minikube or when needing to specify a complete custom image path |
| sensor.image.pullPolicy | string | `nil` | Image pull policy. Specifies when Kubernetes should pull the container image |
| sensor.image.repository | string | `"miggoprod/dynamic-ebpf"` | Image repository |
| sensor.image.tag | string | `nil` | Image tag (defaults to Chart appVersion if not set) |
| sensor.kubernetesClusterDomain | string | `""` | Kubernetes cluster domain |
| sensor.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | Node selector settings |
| sensor.profiler.enabled | bool | `false` | Install profiler on each cluster node to provide function-level reachability analysis and other runtime insights. |
| sensor.profiler.image.fullPath | string | `nil` | Optional full image path override. If set, takes precedence over registry/repository/tag settings. Useful for local development with Minikube or when needing to specify a complete custom image path |
| sensor.profiler.image.pullPolicy | string | `nil` | Image pull policy. Specifies when Kubernetes should pull the container image |
| sensor.profiler.image.repository | string | `"miggoprod/miggo-profiler"` | Image repository |
| sensor.profiler.image.tag | string | `nil` | Image tag (defaults to Chart appVersion if not set) |
| sensor.profiler.monitorInterval | string | `"5s"` | Set the monitor interval in seconds. |
| sensor.profiler.offCpuThreshold | int | `1000` | If set to a value between 1 and 999 will enable off-cpu profiling: Every time an off-cpu entry point is hit, a random number between 0 and 999 is chosen. If the given threshold is greater than this random number, the off-cpu trace is collected and reported. |
| sensor.profiler.probabilisticInterval | string | `"1m0s"` | Time interval for which probabilistic profiling will be enabled or disabled. |
| sensor.profiler.probabilisticThreshold | int | `100` | If set to a value between 1 and 99 will enable probabilistic profiling: every probabilistic-interval a random number between 0 and 99 is chosen. If the given probabilistic-threshold is greater than this random number, the agent will collect profiles from this system for the duration of the interval. |
| sensor.profiler.reporterInterval | string | `"5s"` | Set the reporter's interval in seconds. |
| sensor.profiler.resources.limits.cpu | string | `"1000m"` |  |
| sensor.profiler.resources.limits.memory | string | `"1Gi"` |  |
| sensor.profiler.resources.requests.cpu | string | `"200m"` |  |
| sensor.profiler.resources.requests.memory | string | `"500Mi"` |  |
| sensor.profiler.samplesPerSecond | int | `20` | Set the frequency (in Hz) of stack trace sampling. |
| sensor.profiler.securityContext.allowPrivilegeEscalation | bool | `true` |  |
| sensor.profiler.securityContext.capabilities.add[0] | string | `"SYS_ADMIN"` |  |
| sensor.profiler.securityContext.privileged | bool | `true` |  |
| sensor.resources.limits.cpu | string | `"3000m"` |  |
| sensor.resources.limits.memory | string | `"4Gi"` |  |
| sensor.resources.requests.cpu | string | `"1000m"` |  |
| sensor.resources.requests.memory | string | `"2Gi"` |  |
| sensor.securityContext.privileged | bool | `true` |  |
| sensor.volumeMounts | list | `[]` | Additional volume mounts for all containers |
| sensor.volumes | list | `[]` |  |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `true` | Automatically mount API credentials for the service account |
| serviceAccount.name | string | `""` | Name of the service account. If not set, a name is generated |
| staticSbom.annotations | object | `{}` | Component-specific annotations |
| staticSbom.config.cache.configMap.enabled | bool | `true` | Enable persisted ConfigMap based cache |
| staticSbom.config.cache.configMap.name | string | `""` | Name of the ConfigMap (generated if not set) |
| staticSbom.config.cache.flushInterval | string | `"168h"` | Interval for cache flushing (0 to disable) |
| staticSbom.config.cache.maxEntries | int | `10000` | Maximum number of entries in cache |
| staticSbom.config.disableCompression | bool | `false` | Disable compression for data transfer |
| staticSbom.config.queueSize | int | `10000` | Max limit of the processing queue |
| staticSbom.enabled | bool | `true` | Enable Static SBOM component |
| staticSbom.extraEnvs | list | `[]` | Additional environment variables |
| staticSbom.extraEnvsFrom | list | `[]` | Additional environment variables from sources |
| staticSbom.image.fullPath | string | `nil` | Optional full image path override. If set, takes precedence over registry/repository/tag settings. Useful for local development with Minikube or when needing to specify a complete custom image path |
| staticSbom.image.pullPolicy | string | `nil` | Image pull policy. Specifies when Kubernetes should pull the container image |
| staticSbom.image.repository | string | `"miggoprod/static-sbom"` | Image repository |
| staticSbom.image.tag | string | `nil` | Image tag (defaults to Chart appVersion if not set) |
| staticSbom.labels | object | `{}` | Component-specific labels |
| staticSbom.podAnnotations | object | `{}` | Component-specific pod annotations |
| staticSbom.podLabels | object | `{}` | Component-specific pod labels |
| staticSbom.resources.limits.cpu | string | `"3000m"` |  |
| staticSbom.resources.limits.memory | string | `"4Gi"` |  |
| staticSbom.resources.requests.cpu | string | `"1000m"` |  |
| staticSbom.resources.requests.memory | string | `"2Gi"` |  |
| staticSbom.useGOMEMLIMIT | bool | `true` | When enabled, the chart will set the GOMEMLIMIT env var to 80% of the configured resources.limits.memory. If no resources.limits.memory are defined then enabling does nothing. It is HIGHLY recommend to enable this setting and set a value for resources.limits.memory. |
| staticSbom.volumeMounts | list | `[]` | Additional volume mounts |
| staticSbom.volumes | list | `[]` | Additional volumes |
| tolerations | list | `[]` | Tolerations for all pods |
| volumeMounts | list | `[]` | Additional volume mounts for all containers |
| volumes | list | `[]` | Additional volumes for all pods |

## Examples

### Basic Installation

```yaml
miggo:
  tenantId: "tenant-123"
  projectId: "project-456"
  clusterName: "prod-cluster"

config:
  accessKey: "your-access-key"
```

### Configure Resource Limits

```yaml
k8sRead:
  resources:
    limits:
      cpu: 1000m
      memory: 2Gi
    requests:
      cpu: 500m
      memory: 1Gi

staticSbom:
  resources:
    limits:
      cpu: 4000m
      memory: 6Gi
    requests:
      cpu: 2000m
      memory: 3Gi
```

### Enable/Disable Components

```yaml
k8sRead:
  enabled: true

staticSbom:
  enabled: true

sensor:
  enabled: false

collector:
  enabled: true
```

## Upgrade

To upgrade the chart:

```bash
helm upgrade k8s-integration miggo-charts/k8s-integration -f values.yaml --namespace miggo-space
```

## Uninstallation

To uninstall the chart:

```bash
helm uninstall k8s-integration --namespace miggo-space
```

## Troubleshooting

### Common Issues

1. **Image Pull Errors**
   - Verify your access key is correct
   - Check if the image pull secret is properly configured

2. **Component Startup Issues**
   - Check component logs using:
     ```bash
     kubectl -n miggo-space logs -l component=k8s-read
     kubectl -n miggo-space logs -l component=static-sbom
     kubectl -n miggo-space logs -l component=sensor
     kubectl -n miggo-space logs -l component=collector
     ```

3. **Permission Issues**
   - Verify RBAC resources are properly created
   - Check if service accounts have necessary permissions

### Health Checks

All components expose health check endpoints on the configured port (default: 6666):

```bash
kubectl -n miggo-space port-forward svc/miggo-collector 6666:6666
curl http://localhost:6666/health
```

## Security Considerations

1. **Access Key Protection**
   - Store the access key in a Kubernetes secret
   - Use `config.accessKeySecret` instead of `config.accessKey`

2. **RBAC Permissions**
   - Components use least-privilege RBAC roles
   - Review and adjust permissions as needed

3. **Network Security**
   - Configure appropriate network policies
   - Use TLS for OTLP communication

---

For more information, visit [Miggo Documentation](https://docs.miggo.io)
