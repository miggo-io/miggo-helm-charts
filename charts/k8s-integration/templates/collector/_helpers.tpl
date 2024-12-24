{{/*
Common labels
*/}}
{{- define "miggo-collector.labels" -}}
helm.sh/chart: {{ include "k8s-integrations.chart" . }}
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
app.kubernetes.io/name: {{ include "k8s-integrations.name" . }}-collector
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "accessKeySecret" -}}
{{- if .Values.config.accessKeySecret -}}
{{- .Values.config.accessKeySecret -}}
{{- else if .Values.config.accessKey -}}
access-key-secret
{{- end -}}
{{- end -}}
