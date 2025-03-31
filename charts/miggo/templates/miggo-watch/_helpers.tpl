{{/*
Common labels
*/}}
{{- define "k8s-read.labels" -}}
helm.sh/chart: {{ include "k8s-integrations.chart" . }}
{{ include "k8s-read.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "k8s-read.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k8s-integrations.name" . }}-k8s-read
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
