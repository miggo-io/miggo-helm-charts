# `miggoRuntime.enableWebAppProcessExecFiltering` — exec filtering stays on with detections

**Date:** 2026-11-18
**Ticket:** [DAQ-387](https://linear.app/miggo/issue/DAQ-387/miggo-helm-charts-keep-web-app-exec-filtering-on-when-enabledetections)
**Status:** approved in chat
**Scope:** `charts/miggo` only. One new chart value, the DaemonSet flag it drives, the README and tests.

## Goal

`config.enableDetections: true` must not turn off the runtime's web app exec filtering.

`--enable-web-app-process-exec-filtering` makes the kernel drop exec, fork and tcp-connect events from processes
outside a web app's process tree (`k8s-integrations/dynamic-ebpf/bpf/main.ebpf.c`, `is_webapp_related`). With
filtering off, every process on the node reaches userspace. Build-heavy clusters flood the runtime: on dLocal
mgmt-live (2026-11-11), exec events went from about 0 to about 1.5k/s and runtime CPU rose about 8x.

Filtering on does not blind detections to app-originated payloads. `handle_copy_process`
(`dynamic-ebpf/bpf/exec/webapps.h`) adds every child of a web app process to the tree, so a shell an exploited
app spawns is still reported. What filtering drops is process trees that didn't start in a web app:
`kubectl exec` sessions, cron jobs, sidecars and build steps.

## Decisions

| Decision | Choice |
|---|---|
| Relationship to `config.enableDetections` | independent; detections no longer touches the flag |
| How the flag is set | documented `miggoRuntime.enableWebAppProcessExecFiltering`, default `true` (binary default `true`) |
| Placement | next to `miggoRuntime.enableWebAppProcessDetection`, its sibling runtime toggle |
| Render position | unchanged: before the `extraArgs` ranges, so `extraArgs` still wins (pflag is last-wins) |
| Off state | rendered explicitly, consistent with the other detections flags |

## Approaches

- **Documented value, default `true`** (chosen). This gives a supported way to see every process, for a cluster
  that wants full visibility and accepts the CPU cost, without reaching for undocumented `extraArgs`.
- **Hard-code `true` in the template.** A smaller diff, but the only off switch would be
  `miggoRuntime.extraArgs`, which the README never documents.
- **Drop the line and rely on the binary default.** This loses the explicit rendering, so the state can no longer
  be read off `kubectl get ds -o yaml`, and the chart then depends on a default that lives in another repo.

## Implementation

- `charts/miggo/values.yaml`: `miggoRuntime.enableWebAppProcessExecFiltering: true` with a helm-docs `# --`
  comment.
- `charts/miggo/templates/miggo-runtime/daemonset.yaml`:
  `--enable-web-app-process-exec-filtering={{ .Values.miggoRuntime.enableWebAppProcessExecFiltering }}`.
- `charts/miggo/README.md.gotmpl`: one sentence in the Detections section naming the value and its trade-off.
  `README.md` is regenerated with helm-docs.
- `charts/miggo/examples/default/rendered/`: regenerated with `make generate-examples`.

## Tests

`charts/miggo/tests/detections/test.yaml`:

- the detections on/off tests assert only the two remaining detections flags;
- the two full-`args` ordering tests expect `--enable-web-app-process-exec-filtering=true`;
- filtering renders `true` by default and with `config.enableDetections: true`;
- the value set to `false` renders `false`, both alone and together with detections;
- a `miggoRuntime.extraArgs` override renders after the chart's flag.

## Out of scope

- `detections-demonstration/sensor/values.yaml`. It sets the flag to `false` through `extraArgs`, and that
  setting still wins.
- The ERROR noise the runtime logs for fork events from nested cgroups, in `k8s-integrations`.
- gitops and biggo chart pins.
