{{/*
Common labels
*/}}
{{- define "sensor.labels" -}}
helm.sh/chart: {{ include "k8s-integrations.chart" . }}
{{ include "sensor.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sensor.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k8s-integrations.name" . }}-sensor
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
