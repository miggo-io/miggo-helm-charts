{{/*
Common labels
*/}}
{{- define "static-sbom.labels" -}}
helm.sh/chart: {{ include "k8s-integrations.chart" . }}
{{ include "static-sbom.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "static-sbom.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k8s-integrations.name" . }}-static-sbom
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "static-sbom.configMapCacheName" -}}
{{- default (printf "%s-cache" (include "k8s-integrations.fullname" .)) .Values.staticSbom.config.cache.configMap.name }}
{{- end }}
