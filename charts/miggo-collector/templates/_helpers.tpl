{{/*
Expand the name of the chart.
*/}}
{{- define "miggo-collector.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "miggo-collector.fullname" -}}
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
{{- define "miggo-collector.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "miggo-collector.labels" -}}
helm.sh/chart: {{ include "miggo-collector.chart" . }}
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
app.kubernetes.io/name: {{ include "miggo-collector.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "miggo-collector.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "miggo-collector.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

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
  - name: collector-miggo-regcred
{{- else if (not (empty $accessKey)) }}
imagePullSecrets:
  - name: collector-miggo-regcred
{{- end }}
{{- end -}}

{{- define "accessKeySecret" -}}
{{- $global := .Values.global | default dict }}
{{- $globalAccessKey := dig "config" "accessKey" "" $global }}
{{- $globalAccessKeySecret := dig "config" "accessKeySecret" "" $global }}
{{- $accessKey := coalesce .Values.config.accessKey $globalAccessKey }}
{{- $accessKeySecret := coalesce .Values.config.accessKeySecret $globalAccessKeySecret }}
{{- if and (empty $accessKeySecret) (not (empty $accessKey)) -}}
collector-access-key-secret
{{- else if (not (empty ($accessKeySecret))) -}}
{{ $accessKeySecret }}
{{- end -}}
{{- end -}}
