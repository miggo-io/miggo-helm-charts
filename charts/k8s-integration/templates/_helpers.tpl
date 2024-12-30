{{/*
Expand the name of the chart.
*/}}
{{- define "k8s-integrations.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "k8s-integrations.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "k8s-integrations.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "k8s-integrations.labels" -}}
helm.sh/chart: {{ include "k8s-integrations.chart" . }}
{{ include "k8s-integrations.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "k8s-integrations.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k8s-integrations.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "k8s-integrations.serviceAccountName" -}}
{{- default (include "k8s-integrations.fullname" .) .Values.serviceAccount.name }}
{{- end }}

{{- define "otlpEndpoint" -}}
{{- if .Values.collector.enabled -}}
http://miggo-collector.{{ .Release.Namespace }}.svc.cluster.local:4318
{{- else -}}
{{ .Values.output.otlp.otlpEndpoint }}
{{- end -}}
{{- end -}}

{{- define "otlpEndpointHealthCheckPort" -}}
{{- if .Values.collector.enabled -}}
6666
{{- else -}}
{{- 0 -}}
{{- end -}}
{{- end -}}

{{- define "otlpTlsSkipVerify" -}}
{{- if .Values.collector.enabled -}}
{{- false -}}
{{- else -}}
{{ .Values.output.otlp.tlsSkipVerify }}
{{- end -}}
{{- end -}}

{{- define "miggoImagePullSecrets" -}}
{{- if .Values.config.accessKey }}
- name: miggo-regcred
{{- end }}
{{- end -}}
