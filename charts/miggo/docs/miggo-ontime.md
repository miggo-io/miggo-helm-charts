# MiggoOnTime — chart configuration

MiggoOnTime is a standalone runtime-detection DaemonSet (gated by `miggoOntime.enabled`,
default `false`). It depends only on the Collector, so it is configured and lifecycled
independently of `miggoRuntime`.

## How the OnTime config is produced

OnTime is configured by a YAML file passed as `ontime --config /etc/ontime/config.yaml`.
The chart builds that file in three steps:

1. **Base config** — assembled from the curated `miggoOntime.*` values (log level,
   features, events, otel service name / rates) plus fixed structural defaults
   (intervals, caches, functionalities, `feature_options.detections`). See
   `templates/miggo-ontime/_helpers.tpl` → `miggoOntime.baseConfig`.
2. **Overrides** — `miggoOntime.configOverrides` is **deep-merged** over the base.
3. **Endpoint re-assert** — the chart always sets the `otel` sink endpoint to the
   in-cluster Collector (OTLP gRPC `:4317`). Overriding it has no effect.

Merge semantics (Helm `mergeOverwrite`): **maps merge recursively, lists replace
wholesale.** So overriding `intervals` changes only the keys you set; overriding
`events` or `features` replaces the entire list.

> ⚠️ OnTime decodes the config with strict unknown-field checking — a typo'd or
> non-existent key makes the agent fail at startup. Only use real OnTime config fields
> (see `ontime/etc/config/standalone.yaml` in the miggo-ontime repo).

## Curated values (first-class)

| Value | Purpose |
|---|---|
| `miggoOntime.logLevel` | `info` / `debug` / `warn` / `error` |
| `miggoOntime.features` | feature list (default: `hold, procfs, detect, detections, enricher`) |
| `miggoOntime.events` | enabled detection recipes (default includes `cloud_meta_probe`) |
| `miggoOntime.otel.serviceName` | `service.name` on emitted OTel records |
| `miggoOntime.otel.eventsPerSec` | per-second caps for high-frequency events |
| `miggoOntime.health.enabled` | run the health server + exec probe (default `true`) |
| `miggoOntime.stdout` | also emit to the stdout sink (debugging; default `false`) |
| `miggoOntime.configOverrides` | escape hatch — see below |

## `configOverrides` examples

### 1. Tune intervals / caches under heavy process churn

*Why:* on very busy nodes, short-lived processes can be evicted from the eBPF maps
before their file/exec refs are correlated. Shorter intervals + bigger caches help.

```yaml
miggoOntime:
  configOverrides:
    intervals:
      file-access: 3
      env-vars: 3
    caches:
      task-file: 512
      file-task: 512
```

### 2. Try the firewall feature (detection → active enforcement)

*Why:* `firewall` is an internal-only feature, not enabled by default, but you can
trial enforcement in a test cluster. Add it to `features` and supply a policy.

```yaml
miggoOntime:
  features: [hold, procfs, detect, detections, enricher, firewall]
  configOverrides:
    firewall_policy:
      policy: allow
      deny:
        - example.com
```

### 3. Try AI inference (event / noise reduction)

*Why:* `inference` is internal-only; experiment by enabling the feature and pointing it
at an endpoint.

```yaml
miggoOntime:
  features: [hold, procfs, detect, detections, enricher, inference]
  configOverrides:
    feature_options:
      inference:
        enabled: true
        url: "http://my-inference:8080/api/v1/chat/completions"
        model: "XAI.grok-4.3"
        mode: score
```

### 4. Enable the scoring pipeline / in-memory retainer

*Why:* internal-only experimentation with event scoring / retention.

```yaml
miggoOntime:
  features: [hold, procfs, detect, detections, enricher, pipeline, retainer]
  configOverrides:
    feature_options:
      pipeline:
        scoring: true
      retainer:
        inmemory: true
```

### 5. Add the stdout sink for debugging

*Why:* see raw events in the pod logs. Prefer the dedicated toggle:

```yaml
miggoOntime:
  stdout: true
```

…which is equivalent to overriding the sink list (note: lists replace, so include
`otel` too):

```yaml
miggoOntime:
  configOverrides:
    sinks: [otel, stdout]
```

### 6. Enable extra detection recipes

*Why:* turn on more detections than the default set. OnTime has no compile-time block
list, so any listed recipe is enabled.

```yaml
miggoOntime:
  events:
    - cloud_meta_probe
    - net_flow
    - fw_drop
    - badware_domain
    - ld_preload_abuse
```

## What you cannot override

- **`sink_options.otel.endpoint`** — always set by the chart to the in-cluster
  Collector. (Service name and rates *are* overridable.)
