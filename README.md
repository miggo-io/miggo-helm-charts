# Miggo Helm Charts

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

This repository contains the Helm chart for deploying Miggo's Kubernetes monitoring components into a cluster.

## What gets installed

The [`miggo`](./charts/miggo) chart deploys the following components:

| Component | Kind | Description |
|-----------|------|-------------|
| `miggo-watch` | Deployment | Observes Kubernetes objects and sends telemetry |
| `miggo-scanner` | Deployment | Analyses container images (SBOM/insights) |
| `miggo-runtime` | DaemonSet | eBPF agent running on every node |
| `miggo-profiler` | Sidecar in runtime Pod | Collects continuous profiling data per node |
| `miggo-collector` | Deployment or DaemonSet | In-cluster OTel collector that forwards data to the Miggo backend |
| `fluent-bit` | Sidecar in runtime Pod | Reads profiler logs and exports them via OTLP |

All telemetry is exported via OTLP. When `miggoCollector.enabled=true` (the default), components
send data to the in-cluster collector, which forwards it to `config.collectorUrl`. When disabled,
components send directly to `config.collectorUrl`.

## Prerequisites

- [Helm](https://helm.sh) v3+
- A running Kubernetes cluster
- A Miggo access key (`config.accessKey`)

## Usage

Add the Helm repository:

```console
helm repo add miggo-charts https://miggo-io.github.io/miggo-helm-charts
helm repo update
```

Create a `values.yaml`:

```yaml
miggo:
  clusterName: my-cluster

config:
  accessKey: "your-access-key"

miggoWatch:
  enabled: true

miggoScanner:
  enabled: true

miggoRuntime:
  enabled: true
  profiler:
    enabled: true

miggoCollector:
  enabled: true
```

Install the chart:

```console
helm install miggo miggo-charts/miggo -f values.yaml --namespace miggo-space --create-namespace
```

For full configuration options see the [chart documentation](./charts/miggo/README.md).

## Acknowledgements

The `miggo-collector` component is built upon the [OpenTelemetry Collector](https://github.com/open-telemetry/opentelemetry-collector) and the [OpenTelemetry Operator](https://github.com/open-telemetry/opentelemetry-operator), both open-source projects available under the Apache 2.0 license. We are thankful to their contributors for their work.

## Contribution

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

[Apache 2.0 License](./LICENSE).
