# Miggo Helm Chart

![Version: 0.0.47](https://img.shields.io/badge/Version-0.0.47-informational?style=flat-square)  ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)  ![AppVersion: v25.706.1](https://img.shields.io/badge/AppVersion-v25.706.1-informational?style=flat-square)

This Helm chart deploys Miggo's components, providing comprehensive monitoring, security, and observability capabilities for your Kubernetes clusters.

## Features

- **Miggo Watch**: Monitors Kubernetes resources and their changes
- **Miggo Scanner**: Software Bill of Materials analysis for container images
- **Miggo Runtime**: Runtime monitoring using eBPF technology
- **Miggo Collector**: Centralized telemetry data collection and export

## Prerequisites

- Kubernetes 1.23+
- Helm 3.9+
- Kernel 4.19+ (for eBPF support)
- Access to Miggo's container registry
- A valid Miggo platform tenant ID and project ID

## Components

The chart deploys several components that work together:

### Miggo Watch

Monitors Kubernetes resources and tracks changes in your cluster's configuration. Provides insights into deployments, services, and other Kubernetes objects.

### Miggo Scanner

Analyzes container images to generate Software Bill of Materials (SBOM), identifying dependencies and potential security vulnerabilities.

### Miggo Runtime

Uses eBPF technology to monitor runtime behavior of containers and system calls, providing deep visibility into container activities.

### Miggo Collector

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
  clusterName: "your-cluster-name"

config:
  accessKey: "your-access-key"
```

2. Install the chart:

```bash
helm install miggo miggo-charts/miggo -f values.yaml --namespace miggo-space --create-namespace
```

## Configuration

The following table lists the configurable parameters of the miggo chart and their default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Pod affinity settings for all pods |
| annotations | object | `{}` | Global annotations to add to all resources |
| config.accessKey | string | `""` | Access key for authentication (ignored when accessKeySecret is specified) |
| config.accessKeySecret | string | `""` | Name of the secret containing the access key. Leave empty to create default secrets based on config.accessKey |
| config.allowedNamespaces | string | `nil` | List of namespaces that are allowed to be processed If empty, all namespaces are included by default (before applying deniedNamespaces) Example: ["development", "staging", "production"] |
| config.clientId | string | `"P2UjsJwOFdIeUAtW0pGTJ5SeJAlq"` | Client ID for authentication |
| config.deniedNamespaces | string | `nil` | List of namespaces that should be excluded from processing Takes precedence over allowedNamespaces - if a namespace is both allowed and denied, it will be denied Example: ["test", "deprecated"] |
| config.includeSystemNamespaces | bool | `false` | When set to true, includes system namespaces like kube-system etc. When false (default), automatically adds system namespaces to deniedNamespaces It's recommended to keep this false unless you specifically need to operate on system namespaces |
| config.metrics.interval | string | `"60s"` | Interval for metrics collection |
| config.platform | string | `""` | The Kubernetes platform acronym. Allowed values are: - gke: Google Kubernetes Engine - openshift: Red Hat OpenShift/OCP |
| extraEnvs | list | `[]` | Additional environment variables for all containers |
| extraEnvsFrom | list | `[]` | Additional environment variables from sources for all containers |
| healthcheck.port | int | `6666` | Port number for health check endpoints |
| image | object | `{"pullPolicy":"IfNotPresent","registry":"registry.miggo.io"}` | Docker registry settings |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for all images |
| image.registry | string | `"registry.miggo.io"` | Registry host for all images |
| imagePullSecrets | list | `[]` |  |
| labels | object | `{}` | Global labels to add to all resources |
| miggo.clusterName | string | `"kubernetes-cluster"` | Name of the Kubernetes cluster |
| miggoCollector.accessKeyMountLocation | string | `"/etc/miggo-access-key"` | An internal locaiton to mount the access key file within the container |
| miggoCollector.annotations | object | `{}` | Component-specific annotations |
| miggoCollector.config.logVerbosity | string | `"basic"` | Log verbosity level (detailed|normal|basic) |
| miggoCollector.enabled | bool | `true` | Enable Collector component |
| miggoCollector.extraEnvs | list | `[]` | Additional environment variables |
| miggoCollector.extraEnvsFrom | list | `[]` | Additional environment variables from sources |
| miggoCollector.image.fullPath | string | `nil` | Optional full image path override. If set, takes precedence over registry/repository/tag settings. Useful for local development with Minikube or when needing to specify a complete custom image path |
| miggoCollector.image.pullPolicy | string | `nil` | Image pull policy. Specifies when Kubernetes should pull the container image |
| miggoCollector.image.repository | string | `"miggo/miggo-collector"` | Image repository |
| miggoCollector.image.tag | string | `nil` | Image tag (defaults to Chart appVersion if not set) |
| miggoCollector.initContainers | list | `[]` | InitContainers to initialize the pod |
| miggoCollector.instancePerNode | bool | `false` | Run an instance per node |
| miggoCollector.labels | object | `{}` | Component-specific labels |
| miggoCollector.podAnnotations | object | `{}` | Component-specific pod annotations |
| miggoCollector.podLabels | object | `{}` | Component-specific pod labels |
| miggoCollector.replicas | int | `1` | Number of replicas to run (relevant only if instancePerNode: false) |
| miggoCollector.resources | object | `{"limits":{"cpu":"100m","memory":"500Mi"},"requests":{"cpu":"10m","memory":"200Mi"}}` | Resource requirements |
| miggoCollector.service.annotations | object | `{}` | Service annotations |
| miggoCollector.service.labels | object | `{}` | Service labels |
| miggoCollector.service.ports | list | `[{"name":"http","port":4318,"protocol":"TCP","targetPort":4318},{"name":"grpc","port":4317,"protocol":"TCP","targetPort":4317}]` | Service ports |
| miggoCollector.service.type | string | `"ClusterIP"` | Service type |
| miggoCollector.useGOMEMLIMIT | bool | `true` | When enabled, the chart will set the GOMEMLIMIT env var to 80% of the configured resources.limits.memory. If no resources.limits.memory are defined then enabling does nothing. It is HIGHLY recommend to enable this setting and set a value for resources.limits.memory. |
| miggoCollector.volumeMounts | list | `[]` | Additional volume mounts |
| miggoCollector.volumes | list | `[]` | Additional volumes |
| miggoRuntime.analyzer.enabled | bool | `false` | Install analyzer on each cluster node to provide endpoint URL to functions mapping and other runtime insights. |
| miggoRuntime.analyzer.healthcheck.port | int | `6667` | Port number for health check endpoints |
| miggoRuntime.analyzer.image.fullPath | string | `nil` | Optional full image path override. If set, takes precedence over registry/repository/tag settings. Useful for local development with Minikube or when needing to specify a complete custom image path |
| miggoRuntime.analyzer.image.pullPolicy | string | `nil` | Image pull policy. Specifies when Kubernetes should pull the container image |
| miggoRuntime.analyzer.image.repository | string | `"miggo/miggo-analyzer"` | Image repository |
| miggoRuntime.analyzer.image.tag | string | `nil` | Image tag (defaults to Chart appVersion if not set) |
| miggoRuntime.analyzer.resources.limits.cpu | string | `"500m"` |  |
| miggoRuntime.analyzer.resources.limits.memory | string | `"512Mi"` |  |
| miggoRuntime.analyzer.resources.requests.cpu | string | `"100m"` |  |
| miggoRuntime.analyzer.resources.requests.memory | string | `"256Mi"` |  |
| miggoRuntime.analyzer.securityContext.privileged | bool | `true` |  |
| miggoRuntime.enableFileAccessTracing | bool | `false` | Enable tracing file access. |
| miggoRuntime.enableNetworkTracing | bool | `false` | Enable tracing network connections. |
| miggoRuntime.enabled | bool | `false` | Install eBPF agent on each cluster node to provide package-level reachability analysis and other runtime insights. |
| miggoRuntime.extraEnvs | list | `[]` | Additional environment variables |
| miggoRuntime.extraEnvsFrom | list | `[]` | Additional environment variables from sources |
| miggoRuntime.hostIPC | bool | `true` | Use the host's ipc namespace. |
| miggoRuntime.hostPID | bool | `true` | Use the host's pid namespace. |
| miggoRuntime.image.fullPath | string | `nil` | Optional full image path override. If set, takes precedence over registry/repository/tag settings. Useful for local development with Minikube or when needing to specify a complete custom image path |
| miggoRuntime.image.pullPolicy | string | `nil` | Image pull policy. Specifies when Kubernetes should pull the container image |
| miggoRuntime.image.repository | string | `"miggo/miggo-runtime"` | Image repository |
| miggoRuntime.image.tag | string | `nil` | Image tag (defaults to Chart appVersion if not set) |
| miggoRuntime.kubernetesClusterDomain | string | `""` | Kubernetes cluster domain |
| miggoRuntime.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | Node selector settings |
| miggoRuntime.profiler.enabled | bool | `false` | Install profiler on each cluster node to provide function-level reachability analysis and other runtime insights. |
| miggoRuntime.profiler.image.fullPath | string | `nil` | Optional full image path override. If set, takes precedence over registry/repository/tag settings. Useful for local development with Minikube or when needing to specify a complete custom image path |
| miggoRuntime.profiler.image.pullPolicy | string | `nil` | Image pull policy. Specifies when Kubernetes should pull the container image |
| miggoRuntime.profiler.image.repository | string | `"miggo/miggo-profiler"` | Image repository |
| miggoRuntime.profiler.image.tag | string | `nil` | Image tag (defaults to Chart appVersion if not set) |
| miggoRuntime.profiler.monitorInterval | string | `"5s"` | Set the monitor interval in seconds. |
| miggoRuntime.profiler.offCpuThreshold | int | `1000` | If set to a value between 1 and 999 will enable off-cpu profiling: Every time an off-cpu entry point is hit, a random number between 0 and 999 is chosen. If the given threshold is greater than this random number, the off-cpu trace is collected and reported. |
| miggoRuntime.profiler.probabilisticInterval | string | `"1m0s"` | Time interval for which probabilistic profiling will be enabled or disabled. |
| miggoRuntime.profiler.probabilisticThreshold | int | `100` | If set to a value between 1 and 99 will enable probabilistic profiling: every probabilistic-interval a random number between 0 and 99 is chosen. If the given probabilistic-threshold is greater than this random number, the agent will collect profiles from this system for the duration of the interval. |
| miggoRuntime.profiler.reporterInterval | string | `"5s"` | Set the reporter's interval in seconds. |
| miggoRuntime.profiler.resources.limits.cpu | string | `"500m"` |  |
| miggoRuntime.profiler.resources.limits.memory | string | `"500Mi"` |  |
| miggoRuntime.profiler.resources.requests.cpu | string | `"200m"` |  |
| miggoRuntime.profiler.resources.requests.memory | string | `"256Mi"` |  |
| miggoRuntime.profiler.samplesPerSecond | int | `20` | Set the frequency (in Hz) of stack trace sampling. |
| miggoRuntime.profiler.securityContext.allowPrivilegeEscalation | bool | `true` |  |
| miggoRuntime.profiler.securityContext.capabilities.add[0] | string | `"SYS_ADMIN"` |  |
| miggoRuntime.profiler.securityContext.privileged | bool | `true` |  |
| miggoRuntime.resources.limits.cpu | string | `"500m"` |  |
| miggoRuntime.resources.limits.memory | string | `"512Mi"` |  |
| miggoRuntime.resources.requests.cpu | string | `"100m"` |  |
| miggoRuntime.resources.requests.memory | string | `"256Mi"` |  |
| miggoRuntime.securityContext.privileged | bool | `true` |  |
| miggoRuntime.volumeMounts | list | `[]` | Additional volume mounts for all containers |
| miggoRuntime.volumes | list | `[]` |  |
| miggoScanner.annotations | object | `{}` | Component-specific annotations |
| miggoScanner.config.cache.configMap.enabled | bool | `true` | Enable persisted ConfigMap based cache |
| miggoScanner.config.cache.configMap.name | string | `""` | Name of the ConfigMap (generated if not set) |
| miggoScanner.config.cache.flushInterval | string | `"168h"` | Interval for cache flushing (0 to disable) |
| miggoScanner.config.cache.maxEntries | int | `10000` | Maximum number of entries in cache |
| miggoScanner.config.disableCompression | bool | `false` | Disable compression for data transfer |
| miggoScanner.config.queueSize | int | `10000` | Max limit of the processing queue |
| miggoScanner.enabled | bool | `true` | Enable Miggo Scanner component |
| miggoScanner.extraEnvs | list | `[]` | Additional environment variables |
| miggoScanner.extraEnvsFrom | list | `[]` | Additional environment variables from sources |
| miggoScanner.image.fullPath | string | `nil` | Optional full image path override. If set, takes precedence over registry/repository/tag settings. Useful for local development with Minikube or when needing to specify a complete custom image path |
| miggoScanner.image.pullPolicy | string | `nil` | Image pull policy. Specifies when Kubernetes should pull the container image |
| miggoScanner.image.repository | string | `"miggo/miggo-scanner"` | Image repository |
| miggoScanner.image.tag | string | `nil` | Image tag (defaults to Chart appVersion if not set) |
| miggoScanner.labels | object | `{}` | Component-specific labels |
| miggoScanner.podAnnotations | object | `{}` | Component-specific pod annotations |
| miggoScanner.podLabels | object | `{}` | Component-specific pod labels |
| miggoScanner.resources.limits.cpu | string | `"3000m"` |  |
| miggoScanner.resources.limits.memory | string | `"4Gi"` |  |
| miggoScanner.resources.requests.cpu | string | `"1000m"` |  |
| miggoScanner.resources.requests.memory | string | `"2Gi"` |  |
| miggoScanner.useGOMEMLIMIT | bool | `true` | When enabled, the chart will set the GOMEMLIMIT env var to 80% of the configured resources.limits.memory. If no resources.limits.memory are defined then enabling does nothing. It is HIGHLY recommend to enable this setting and set a value for resources.limits.memory. |
| miggoScanner.volumeMounts | list | `[]` | Additional volume mounts |
| miggoScanner.volumes | list | `[]` | Additional volumes |
| miggoWatch.annotations | object | `{}` | Component-specific annotations |
| miggoWatch.config.disableCompression | bool | `false` | Disable compression for data transfer |
| miggoWatch.config.exclude | string | `"pod,replica-set"` | Exclude those components from the report (comma separated list of persistent-volume-claim daemon-set stateful-set ingress ingress-class http-route network-policy namespace service-account persistent-volume cron-job node deployment job replica-set gateway-class pod service) |
| miggoWatch.config.interval | string | `"6h"` | Interval for scanning Kubernetes resources |
| miggoWatch.enabled | bool | `true` | Enable Miggo Watch component |
| miggoWatch.extraEnvs | list | `[]` | Additional environment variables |
| miggoWatch.extraEnvsFrom | list | `[]` | Additional environment variables from sources |
| miggoWatch.image.fullPath | string | `nil` | Optional full image path override. If set, takes precedence over registry/repository/tag settings. Useful for local development with Minikube or when needing to specify a complete custom image path |
| miggoWatch.image.pullPolicy | string | `nil` | Image pull policy. Specifies when Kubernetes should pull the container image |
| miggoWatch.image.repository | string | `"miggo/miggo-watch"` | Image repository |
| miggoWatch.image.tag | string | `nil` | Image tag (defaults to Chart appVersion if not set) |
| miggoWatch.labels | object | `{}` | Component-specific labels |
| miggoWatch.podAnnotations | object | `{}` | Component-specific pod annotations |
| miggoWatch.podLabels | object | `{}` | Component-specific pod labels |
| miggoWatch.resources.limits.cpu | string | `"100m"` |  |
| miggoWatch.resources.limits.memory | string | `"256Mi"` |  |
| miggoWatch.resources.requests.cpu | string | `"10m"` |  |
| miggoWatch.resources.requests.memory | string | `"128Mi"` |  |
| miggoWatch.useGOMEMLIMIT | bool | `true` | When enabled, the chart will set the GOMEMLIMIT env var to 80% of the configured resources.limits.memory. If no resources.limits.memory are defined then enabling does nothing. It is HIGHLY recommend to enable this setting and set a value for resources.limits.memory. |
| miggoWatch.volumeMounts | list | `[]` | Additional volume mounts |
| miggoWatch.volumes | list | `[]` | Additional volumes |
| nodeSelector | object | `{}` | Node selector for all pods |
| output.api.apiEndpoint | string | `""` | Miggo Api endpoint (defaults to otlp endpoint) |
| output.api.enabled | bool | `true` | Decide whether to communicate with Miggo Api |
| output.otlp.otlpEndpoint | string | `"https://api.miggo.io"` | OTLP endpoint URL |
| output.otlp.tlsSkipVerify | bool | `false` | Skip TLS verification |
| output.stdout | bool | `false` | Enable stdout logging (for debugging) |
| podAnnotations | object | `{}` | Pod annotations to add to all pods |
| podLabels | object | `{}` | Pod labels to add to all pods |
| podSecurityContext | object | `{}` | Pod security context for all pods |
| securityContext | object | `{}` | Container security context for all containers |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `true` | Automatically mount API credentials for the service account |
| serviceAccount.name | string | `""` | Name of the service account. If not set, a name is generated |
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
miggoWatch:
  resources:
    limits:
      cpu: 1000m
      memory: 2Gi
    requests:
      cpu: 500m
      memory: 1Gi

miggoScanner:
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
miggoWatch:
  enabled: true

miggoScanner:
  enabled: true

miggoRuntime:
  enabled: false

miggoCollector:
  enabled: true
```

## Upgrade

To upgrade the chart:

```bash
helm upgrade miggo miggo-charts/miggo -f values.yaml --namespace miggo-space
```

## Uninstallation

To uninstall the chart:

```bash
helm uninstall miggo --namespace miggo-space
```

## Troubleshooting

### Common Issues

1. **Image Pull Errors**
   - Verify your access key is correct
   - Check if the image pull secret is properly configured

2. **Component Startup Issues**
   - Check component logs using:
     ```bash
     kubectl -n miggo-space logs -l component=miggo-watch
     kubectl -n miggo-space logs -l component=miggo-scanner
     kubectl -n miggo-space logs -l component=miggo-runtime
     kubectl -n miggo-space logs -l component=miggo-collector
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
