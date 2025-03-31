{{/*
Common labels
*/}}
{{- define "miggoRuntime.labels" -}}
helm.sh/chart: {{ include "miggo.chart" . }}
{{ include "miggoRuntime.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "miggoRuntime.selectorLabels" -}}
app.kubernetes.io/name: {{ include "miggo.name" . }}-runtime
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
