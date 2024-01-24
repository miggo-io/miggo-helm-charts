# Miggo Helm Charts

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 

This repository contains [Helm](https://helm.sh/) charts for installing Miggo Helm charts, based onOpenTelemetry project.

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```console
$ helm repo add miggo-charts https://miggo-io.github.io/miggo-helm-charts
$ helm repo update
```

## Helm Charts

You can then run `helm search repo miggo-helm-charts` to see the charts.

### Miggo Operator

The chart can be used to install [Miggo Operator](https://miggo-io.github.io/miggo-helm-charts/miggo-operator)
in a Kubernetes cluster. More detailed documentation can be found in
[Miggo Operator chart directory](./charts/Miggo-operator).

## Acknowledgements

This project is built upon or includes modifications of opentelemetry-operator, an open-source project available under the Apache 2.0. We are thankful to the contributors of opentelemetry-operator for their work, which has significantly aided the development of our project.
The original project can be found at: [OpenTelemtry Helm Charts Github repo](https://github.com/open-telemetry/opentelemetry-operator)

## Contribution

See Original contribution doc of OpenTelemtry [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

[Apache 2.0 License](./LICENSE).
