# Collector per node by default

**Date:** 2026-10-24
**Ticket:** [DAQ-315](https://linear.app/miggo/issue/DAQ-315/miggo-chart-default-miggocollectorinstancepernode-to-true-collector-as)
**Status:** approved in chat, implemented
**Scope:** `charts/miggo` only — the `miggoCollector.instancePerNode` default, the README row, the rendered example, and the unit tests

## Goal

A default install runs the collector as a DaemonSet (one pod per node, Service
`internalTrafficPolicy: Local`). A single-replica Deployment cannot carry a large runtime install:
on ~77–86 node clusters it restarts and its egress stalls, so heartbeats and profiles arrive late or
not at all. Large installs that run well already set `instancePerNode: true`.

## Decisions

| Decision | Choice |
|---|---|
| Default | `miggoCollector.instancePerNode: true` |
| Global collector | still available with `instancePerNode: false`; `replicas` applies only there |
| Scanner cache | default installs now get `--cache-generation=collector-daemonset`, so each one rescans its images once on upgrade |
| Tests | default-case tests in `tests/collector-per-node` (DaemonSet, Local Service, scanner cache generation); suites that only meant "the collector" assert the DaemonSet; the pprof Deployment-mode test sets `instancePerNode: false` |
| Example | `examples/default` re-rendered with helm v4.2.0, as CI runs it |

## Open questions

- **Tolerations parity.** The runtime accepts `miggoRuntime.tolerations`; the collector reads only the
  global `tolerations`. On a node tainted for the runtime alone there is no local collector, and the
  `Local` Service drops that runtime's traffic. Not in this change.
- **Sensor status rows.** `deployment-type` becomes `daemonset`, so the collector's sensor rows are keyed
  by node; the node-less row from the Deployment goes stale after upgrade. Not in this change.
