This chart has been moved from `miggo-helm-charts/k8s-integration` to [miggo-helm-chart/miggo](https://github.com/miggo-io/miggo-helm-charts/tree/main/charts/miggo). 

# Migration Guide

The chart has undergone significant changes beyond just relocation. Component names have been modified, making the old `values.yaml` incompatible with the new version. For a smooth transition, we recommend uninstalling the old chart and installing the new one.

## Uninstalling the Old Chart

You can uninstall the old chart using the following command:
```sh
helm -n miggo-space uninstall k8s-integration
```

## Installing the New Chart
To install the new chart, please refer to the official [documentation here](https://docs.miggo.io/deployments/native-sensor/kubernetes/).

## Migrating Existing Configuration

If you have an existing `values.yaml` file, the following property mappings will help you update your configuration:

| Old Property Name | New Property Name |
|-------------------|-------------------|
| `k8sRead`         | `miggoWatch`      |
| `staticSbom`      | `miggoScanner`    |
| `sensor`          | `miggoRuntime`    |
| `collector`       | `miggoCollector`  |

Example of configuration mapping:

```yaml
# Old configuration
collector:
  # collector-specific values

# New configuration
miggoCollector:
  # same collector-specific values
```

Repeat this pattern for all affected components when creating your new configuration file.
