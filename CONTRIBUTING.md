# Contributing Guide

We'd love your help!

## How to Contribute

1. Fork this repository
1. Work in a branch of your local copy
1. Develop and test your changes
1. Submit a pull request against `main`

## Technical Requirements

- Must follow [Helm chart best practices](https://helm.sh/docs/topics/chart_best_practices/)
- Must pass CI jobs for linting and unit testing (see [Running Tests Locally](#running-tests-locally))
- Any change to the chart requires a version bump — this is handled automatically by CI on merge,
  but you can bump `charts/miggo/Chart.yaml` manually if needed

Once changes are merged, the release job automatically packages and publishes the updated chart.

## Running Tests Locally

Run the unit tests:

```bash
cd charts/miggo
./run-tests.sh
```

Lint the chart:

```bash
ct lint --target-branch main
```

Lint Markdown files:

```bash
markdownlint "**/*.md"
```

If you changed any example `values.yaml` under `charts/miggo/examples/`, regenerate the rendered snapshots:

```bash
make generate-examples
```

Then verify they match:

```bash
make check-examples
```

## Versioning

The chart `version` in `Chart.yaml` follows [semver](https://semver.org/) and is bumped automatically
by CI on every merged PR. You do not need to bump it manually.

For breaking (backwards incompatible) changes:

1. Note it clearly in your PR description
1. Add an "Upgrading" section to `charts/miggo/README.md.gotmpl` describing the manual migration steps

## Immutability

Chart releases are immutable. Once a version is published it is never overwritten — every change
produces a new version.

## Examples

All charts maintain examples under `charts/chart-name/examples/`. Each example is an independent folder
containing a `values.yaml` and a `rendered/` snapshot. After changing templates or values, regenerate
with `make generate-examples` and commit both files.
