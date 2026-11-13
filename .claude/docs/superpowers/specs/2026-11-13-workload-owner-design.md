# Runtime reads Jobs to name a CronJob pod's owner

**Date:** 2026-11-13
**Ticket:** [DAQ-381](https://linear.app/miggo/issue/DAQ-381/key-runtime-signals-on-the-sensors-workload-owner-not-the-pod-name)
**Status:** approved in chat, implemented
**Scope:** `charts/miggo` only — one rule on the `miggo-runtime` ClusterRole, its unit test and the rendered example

## Goal

The runtime stamps every event and profile sample with its workload owner (`workload` /
`k8s.workload`, `<kind>/<name>`). The backend hashes the bare owner name into the service id, so
the runtime must name a pod's owner exactly as the watch and the scanner do. For a pod created by
a CronJob that owner is the CronJob, which only the pod's Job records: the runtime has to `get`
the Job.

## Decisions

| Decision | Choice |
|---|---|
| Rule | `apiGroups: [batch]`, `resources: [jobs]`, `verbs: [get]` on the existing `pod-watcher-cr` ClusterRole |
| Verbs | `get` only — the runtime looks up one Job per Job-owned pod and caches it; no list or watch |
| Toggle | none — the rule lives inside the existing `miggoRuntime.enabled` block |
| Ordering with the sensor release | free — without the grant the runtime reports `job/<job>`, today's value |

## Out of scope

- The sensor code (k8s-integrations, same ticket).
- Linux-host packages: no Kubernetes RBAC there.
