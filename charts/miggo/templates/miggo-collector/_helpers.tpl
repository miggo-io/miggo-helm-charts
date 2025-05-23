{{/*
Common labels
*/}}
{{- define "miggo-collector.labels" -}}
helm.sh/chart: {{ include "miggo.chart" . }}
{{ include "miggo-collector.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "miggo-collector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "miggo.name" . }}-collector
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
