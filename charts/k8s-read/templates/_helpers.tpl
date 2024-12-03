{{/*
Expand the name of the chart.
*/}}
{{- define "k8s-read.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "k8s-read.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "k8s-read.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "k8s-read.labels" -}}
helm.sh/chart: {{ include "k8s-read.chart" . }}
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
app.kubernetes.io/name: {{ include "k8s-read.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "k8s-read.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "k8s-read.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "k8s-read.configMapCacheName" -}}
{{- default (printf "%s-cache" (include "k8s-read.fullname" .)) .Values.config.cache.configMap.name }}
{{- end }}

{{- define "common.otlp.authHeader" -}}
{{- $global := .Values.global | default dict }}
{{- $globalOtlpHttpAuthHeader := dig "output" "otlp" "httpAuthHeader" "" $global }}
{{- $authHeader := coalesce .Values.output.otlp.httpAuthHeader $globalOtlpHttpAuthHeader "" }}
{{- if $authHeader }}
{{- $authHeader -}}
{{- end }}
{{- end }}

{{- define "common.otlpEndpoint" -}}
{{- $global := .Values.global | default dict -}}
{{- $globalOtlpEndpoint := dig "output" "otlp" "otlpEndpoint" "" $global -}}
{{- $otlpEndpoint := coalesce .Values.output.otlp.otlpEndpoint $globalOtlpEndpoint -}} 
{{- if $otlpEndpoint }}
{{- $otlpEndpoint -}}
{{- else -}}
http://miggo-collector.{{ .Release.Namespace }}.svc.cluster.local:4317
{{- end }}
{{- end -}}

{{- define "common.tlsSkipVerify" -}}
{{- $global := .Values.global | default dict -}}
{{- $globalTlsSkipVerify := dig "output" "otlp" "tlsSkipVerify" "" $global }}
{{- $tlsSkipVerify := default .Values.output.otlp.tlsSkipVerify $globalTlsSkipVerify -}} 
{{- $tlsSkipVerify -}}
{{- end -}}

{{- define "imagePullSecrets" -}}
{{- $emptyImagePullSecrets := list (dict "name" "") }}
{{- $global := .Values.global | default dict }}
{{- $globalImagePullSecrets := dig "imagePullSecrets" $emptyImagePullSecrets $global }}
{{- $globalImageCredentialsUsername := dig "imageCredentials" "username" "" $global }}
{{- $username := coalesce .Values.imageCredentials.username $globalImageCredentialsUsername }}
{{- $globalAccessKey := dig "config" "accessKey" "" $global }}
{{- $accessKey := coalesce .Values.config.accessKey $globalAccessKey }}
{{- if (not (empty (index .Values.imagePullSecrets 0).name)) }}
imagePullSecrets:
  {{- toYaml .Values.imagePullSecrets | nindent 2 }}
{{- else if (not (empty (index $globalImagePullSecrets 0).name)) }}
imagePullSecrets:
  {{- toYaml .Values.global.imagePullSecrets | nindent 2 }}
{{- else if (not (empty $username)) }}
imagePullSecrets:
  - name: k8s-read-miggo-regcred
{{- else if (not (empty $accessKey)) }}
imagePullSecrets:
  - name: k8s-read-miggo-regcred
{{- end }}
{{- end -}}
