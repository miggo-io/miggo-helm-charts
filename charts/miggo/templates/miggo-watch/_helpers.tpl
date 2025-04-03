{{/*
Common labels
*/}}
{{- define "miggo-watch.labels" -}}
helm.sh/chart: {{ include "miggo.chart" . }}
{{ include "miggo-watch.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "miggo-watch.selectorLabels" -}}
app.kubernetes.io/name: {{ include "miggo.name" . }}-watch
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
