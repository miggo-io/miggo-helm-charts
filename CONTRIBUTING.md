# Contributing Guide

We'd love your help!

## How to Contribute

1. Fork this repository
1. Work in a branch of your local copy
1. Develop and test your changes locally (see [Running Tests Locally](#running-tests-locally))
1. Submit a pull request against `main`

CI will run automatically on your PR. See [What CI Checks](#what-ci-checks) for the full list.

## Local Tool Prerequisites

Install these tools before working on the chart:

- [Helm](https://helm.sh) v3+
- [chart-testing (`ct`)](https://github.com/helm/chart-testing) — used by `ct lint`
- [helm-unittest plugin](https://github.com/helm-unittest/helm-unittest) — used by `run-tests.sh`
- [helm-docs](https://github.com/norwoodj/helm-docs) — used to regenerate `charts/miggo/README.md`
- [markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli) — used to lint Markdown files

Install the helm-unittest plugin once:

```bash
helm plugin install https://github.com/helm-unittest/helm-unittest.git
```

Install helm-docs (requires Go):

```bash
go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest
```

## Running Tests Locally

**Unit tests** — render chart templates and assert the YAML output matches expectations:

```bash
cd charts/miggo
./run-tests.sh
```

**Helm lint** — validate chart structure and template syntax:

```bash
ct lint --target-branch main
```

**Markdown lint** — check all Markdown files against the project rules:

```bash
markdownlint --config .markdownlint.yaml "**/*.md"
```

**Example snapshots** — if you changed any template or `charts/miggo/examples/*/values.yaml`,
regenerate the rendered snapshots and verify they match:

```bash
make generate-examples   # re-render
make check-examples      # diff against committed snapshots (this is what CI runs)
```

**Chart README** — if you changed `charts/miggo/values.yaml` comments or `charts/miggo/README.md.gotmpl`,
regenerate the chart README (never edit `charts/miggo/README.md` directly):

```bash
helm-docs --chart-search-root charts/miggo
```

## What CI Checks

Every PR triggers the following workflows:

| Workflow | What it does |
|---|---|
| **Helm Lint** | Runs `ct lint` + `make check-examples` |
| **Markdown Lint** | Runs `markdownlint` on all `*.md` files |
| **Unit Tests** | Runs `helm unittest` via `run-tests.sh` |

All three must pass before merging.

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

Examples live under `charts/miggo/examples/`. Each example is a folder with a `values.yaml` input
and a `rendered/` directory of committed snapshot manifests. After changing templates or values,
always regenerate with `make generate-examples` and commit both the input and the snapshots.
