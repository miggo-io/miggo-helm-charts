# `enableDetections` — one beta value for the sensor detections capability

**Date:** 2026-09-14
**Ticket:** [DAQ-232](https://linear.app/miggo/issue/DAQ-232/miggo-helm-charts-single-beta-enabledetections-value-for-the-sensor)
**Status:** approved in chat, implemented
**Scope:** `charts/miggo` only — one new chart value, the DaemonSet flags it drives, and the README

## Goal

Detections is entering a beta phase. A customer should turn it on with **one documented chart
value**, not by hand-setting three flags that the chart never documents.

Those three flags reach the sensor through the free-form `extraArgs` passthrough maps, which
`charts/miggo/values.yaml` never declares — so they are absent from the helm-docs-generated values
table in `README.md` and a customer only meets them by reading the templates. That stays true after
this change.

| Flag | Container | Passed via | Binary default |
|---|---|---|---|
| `enable-syscall-to-profile-correlation` | `miggo-runtime` | `miggoRuntime.extraArgs` | `false` |
| `enable-web-app-process-exec-filtering` | `miggo-runtime` | `miggoRuntime.extraArgs` | `true` |
| `load-probe` | `profiler` | `miggoRuntime.profiler.extraArgs` | `false` |

Defaults read from `k8s-integrations/dynamic-ebpf/internal/opts/opts.go` (`InitializeFlags`) and
`k8s-integrations/docs/development/build-from-source.md`. The working recipe they come from is
`detections-demo/sensor/values.yaml`.

## Decisions

| Decision | Choice |
|---|---|
| Value name and scope | `config.enableDetections`, default `false` |
| Relationship to `miggoRuntime.enabled` | independent — `enableDetections` does **not** force the runtime on |
| Off state | flags render explicitly in their off form, not omitted |
| Precedence | chart flags render *before* the `extraArgs` ranges, so `extraArgs` still wins |
| README | one values-table row marked Beta, plus a prose subsection; the three flags stay unnamed |
| Sensor code | untouched |

## Why `config` rather than `miggoRuntime.enableDetections`

Detections is a product capability, not a runtime tuning knob, so a customer enabling a beta feature
should not have to know which component implements it. `config` is the block a customer already
edits — it holds `accessKey`, `allowedNamespaces`, `deniedNamespaces` — which makes it the section
they read when deciding what the sensor does, and it keeps the capability off the component that
merely happens to carry the flags. The value sits first in `config` for that reason.

The cost is that `config.enableDetections: true` alone does nothing: the flags only reach a
container that `miggoRuntime.enabled` created. The README states that requirement, and a unit test
pins it.

## Why the off state renders explicitly

Rendering nothing when `enableDetections` is `false` would be semantically identical today, because
each off-state value equals the binary's own default. Rendering them anyway buys two things:

- **Supportability** — detections state is readable straight off `kubectl get ds -o yaml`, with no
  cross-reference to a chart version or a binary's flag defaults.
- **Durability** — the off state stops depending on a default that lives in another repo and could
  move without anyone here noticing.

The cost is a one-time DaemonSet rollout on upgrade, which a chart version bump causes anyway.
Behaviour for existing installs is unchanged.

## Why the flags render before `extraArgs`

Both flag parsers are last-wins — `spf13/pflag` on the runtime, stdlib `flag` on the profiler — so
argument order decides precedence. Emitting the chart's flags *before* the existing
`range $key, $value := ... .extraArgs` blocks keeps `extraArgs` an override rather than a conflict.

That matters immediately: `detections-demo/sensor/values.yaml` sets all three through `extraArgs`
today and keeps working untouched on the new chart. It also leaves `extraArgs` available as the
internal escape hatch for a one-off combination the single value cannot express.

Two unit tests assert the ordering directly, since the property is invisible in a set-membership
assertion.

## Implementation

`charts/miggo/values.yaml` — first entry in the `config` block:

```yaml
config:
  # -- Enable the detections capability (Beta). Requires miggoRuntime.enabled.
  enableDetections: false
```

The `(Beta)` marker sits inside the sentence rather than leading the comment: helm-docs reads a
leading `# -- (word)` as a **type override**, which renders the values table's Type column as
`Beta` instead of `bool`.

`charts/miggo/templates/miggo-runtime/daemonset.yaml` — in the `miggo-runtime` container, after
`--pprof-port` / `namespace.flags` and before the `extraArgs` range:

```yaml
- --enable-syscall-to-profile-correlation={{ .Values.config.enableDetections }}
- --enable-web-app-process-exec-filtering={{ not .Values.config.enableDetections }}
```

and in the `profiler` container, after `-tracers=` / `-pprof=` and before its `extraArgs` range:

```yaml
- --load-probe={{ .Values.config.enableDetections }}
```

`charts/miggo/README.md.gotmpl` — a `## Detections (Beta)` section. It stays out of the Features
list, which enumerates components. `README.md` is regenerated with helm-docs, never hand-edited.

## Tests

New suite `charts/miggo/tests/detections/`:

- the three flags render in their off form by default;
- they render inverted when `config.enableDetections: true`;
- `miggoRuntime.extraArgs` overrides the runtime flag, and the chart's flag precedes it in `args`;
- `miggoRuntime.profiler.extraArgs` overrides the profiler flag, same ordering assertion;
- `config.enableDetections: true` with `miggoRuntime.enabled: false` renders no DaemonSet.

Existing `charts/miggo/tests/runtime-profiler/test.yaml` full-`args` assertions gain the new entries
in render order. Committed example snapshots under `charts/miggo/examples/default/rendered/` are
regenerated with `make generate-examples`.

## Chart version bump (discovered during implementation)

`Chart.yaml` is bumped to `0.0.239` in this change even though `CONTRIBUTING.md` says CI bumps it
for you. The committed example snapshots embed `helm.sh/chart: miggo-<version>`, and CI's job order
is `verify-and-bump` → `helm-lint` → `make check-examples`: the bump lands on the PR branch *before*
the snapshots are checked, so snapshots rendered against the pre-bump version never match. Bumping
in the PR makes `verify-and-bump` see a version that already differs from base and skip, leaving the
snapshots valid.

`make check-examples` fails on `origin/main` today for this reason — `update-miggo-app-version.yaml`
pushes `Chart.yaml` bumps straight to `main` without regenerating the snapshots, so they had drifted
to `0.0.231` against a `0.0.238` chart. Regenerating here clears that backlog as a side effect.

## Out of scope

- Sensor code in `k8s-integrations`, including the flag defaults themselves.
- Migrating `detections-demo/sensor/values.yaml` off `extraArgs` onto `enableDetections`.
- Any gitops change — nothing is rolled out by this work.
- Making `config.enableDetections` imply `miggoRuntime.enabled`.

## Open question

Whether `config.enableDetections` should eventually imply `miggoRuntime.enabled: true` once detections
leaves beta. Deferred: today the runtime is a separately-priced capability that customers enable on
its own for package-level reachability, and folding the two together would change what an existing
`miggoRuntime.enabled: false` install gets.
