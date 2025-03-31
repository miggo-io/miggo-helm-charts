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

{{- define "otlpProfilesEndpoint" -}}
{{- if .Values.collector.enabled -}}
miggo-collector.{{ .Release.Namespace }}.svc.cluster.local:4317
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

{{/*
Namespace configuration flags
*/}}
{{- define "namespace.flags" -}}
- --include-system-namespaces={{ .Values.config.includeSystemNamespaces }}
{{- if .Values.config.allowedNamespaces }}
- --allowed-namespaces={{ join "," .Values.config.allowedNamespaces }}
{{- end }}
{{- if .Values.config.deniedNamespaces }}
- --denied-namespaces={{ join "," .Values.config.deniedNamespaces }}
{{- end }}
{{- end -}}

{{/*
  This helper converts the input value of memory to Bytes.
  Input needs to be a valid value as supported by k8s memory resource field.
 */}}
{{- define "convertMemToBytes" }}
  {{- $mem := lower . -}}
  {{- if hasSuffix "e" $mem -}}
    {{- $mem = mulf (trimSuffix "e" $mem | float64) 1e18 -}}
  {{- else if hasSuffix "ei" $mem -}}
    {{- $mem = mulf (trimSuffix "e" $mem | float64) 0x1p60 -}}
  {{- else if hasSuffix "p" $mem -}}
    {{- $mem = mulf (trimSuffix "p" $mem | float64) 1e15 -}}
  {{- else if hasSuffix "pi" $mem -}}
    {{- $mem = mulf (trimSuffix "pi" $mem | float64) 0x1p50 -}}
  {{- else if hasSuffix "t" $mem -}}
    {{- $mem = mulf (trimSuffix "t" $mem | float64) 1e12 -}}
  {{- else if hasSuffix "ti" $mem -}}
    {{- $mem = mulf (trimSuffix "ti" $mem | float64) 0x1p40 -}}
  {{- else if hasSuffix "g" $mem -}}
    {{- $mem = mulf (trimSuffix "g" $mem | float64) 1e9 -}}
  {{- else if hasSuffix "gi" $mem -}}
    {{- $mem = mulf (trimSuffix "gi" $mem | float64) 0x1p30 -}}
  {{- else if hasSuffix "m" $mem -}}
    {{- $mem = mulf (trimSuffix "m" $mem | float64) 1e6 -}}
  {{- else if hasSuffix "mi" $mem -}}
    {{- $mem = mulf (trimSuffix "mi" $mem | float64) 0x1p20 -}}
  {{- else if hasSuffix "k" $mem -}}
    {{- $mem = mulf (trimSuffix "k" $mem | float64) 1e3 -}}
  {{- else if hasSuffix "ki" $mem -}}
    {{- $mem = mulf (trimSuffix "ki" $mem | float64) 0x1p10 -}}
  {{- end }}
{{- $mem }}
{{- end }}

{{- define "gomemlimit" }}
{{- $memlimitBytes := include "convertMemToBytes" . | mulf 0.8 -}}
{{- printf "%dMiB" (divf $memlimitBytes 0x1p20 | floor | int64) -}}
{{- end }}
