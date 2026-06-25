{{/*
Common labels
*/}}
{{- define "miggoOntime.labels" -}}
helm.sh/chart: {{ include "miggo.chart" . }}
{{ include "miggoOntime.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "miggoOntime.selectorLabels" -}}
app.kubernetes.io/name: {{ include "miggo.name" . }}-ontime
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
OnTime base config (rendered into /etc/ontime/config.yaml). The structural defaults
(intervals, caches, functionalities, feature_options.detections) are fixed here; the
curated miggoOntime values feed the tunable parts. config-cm.yaml deep-merges
miggoOntime.configOverrides over this and then re-asserts the otel sink endpoint, so
the Collector wiring is always chart-controlled.
*/}}
{{- define "miggoOntime.baseConfig" -}}
run_time:
  log-level: {{ .Values.miggoOntime.logLevel }}
  profiler: false
  health: {{ .Values.miggoOntime.health.enabled }}
  metrics: true
  cardinal: true
  stdout: stdout
  stderr: stderr
intervals:
  env-vars: 6
  file-access: 6
  network-peers: 6
  network-flows: 9
caches:
  rec-tasks: 32
  tasks: 64
  cmds: 32
  args: 32
  files: 128
  dirs: 32
  bases: 64
  task-file: 256
  file-task: 256
  task-ref: 256
  flows: 128
  task-flow: 128
  flow-task: 128
  flow-ref: 128
functionalities:
  - ontime
features:
  {{- toYaml .Values.miggoOntime.features | nindent 2 }}
feature_options:
  detect:
  detections:
    builtin:
      enabled: true
    public:
      enabled: false
sinks:
  - otel
  {{- if .Values.miggoOntime.stdout }}
  - stdout
  {{- end }}
sink_options:
  otel:
    endpoint: {{ include "otlpProfilesEndpoint" . | quote }}
    service_name: {{ .Values.miggoOntime.otel.serviceName | quote }}
    {{- with .Values.miggoOntime.otel.eventsPerSec }}
    events_per_sec:
      {{- toYaml . | nindent 6 }}
    {{- end }}
events:
  {{- toYaml .Values.miggoOntime.events | nindent 2 }}
{{- end -}}
