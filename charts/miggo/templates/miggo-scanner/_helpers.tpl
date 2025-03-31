{{/*
Common labels
*/}}
{{- define "miggo-scanner.labels" -}}
helm.sh/chart: {{ include "miggo.chart" . }}
{{ include "miggo-scanner.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "miggo-scanner.selectorLabels" -}}
app.kubernetes.io/name: {{ include "miggo.name" . }}-scanner
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "miggo-scanner.configMapCacheName" -}}
{{- default (printf "%s-cache" (include "miggo.fullname" .)) .Values.miggoScanner.config.cache.configMap.name }}
{{- end }}
