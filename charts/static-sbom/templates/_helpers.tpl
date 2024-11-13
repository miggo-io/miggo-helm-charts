{{/*
Expand the name of the chart.
*/}}
{{- define "static-sbom.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "static-sbom.fullname" -}}
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
{{- define "static-sbom.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "static-sbom.labels" -}}
helm.sh/chart: {{ include "static-sbom.chart" . }}
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
app.kubernetes.io/name: {{ include "static-sbom.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "static-sbom.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "static-sbom.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "imagePullSecrets" -}}
{{- $emptyImagePullSecrets := list (dict "name" "") }}
{{- $global := .Values.global | default dict }}
{{- $globalImagePullSecrets := dig "global" "imagePullSecrets" $emptyImagePullSecrets $global }}
{{- if (not (empty (index .Values.imagePullSecrets 0).name)) }}
imagePullSecrets:
  {{- toYaml .Values.imagePullSecrets | nindent 2 }}
{{- else if (not (empty (index $globalImagePullSecrets 0).name)) }}
imagePullSecrets:
  {{- toYaml .Values.global.imagePullSecrets | nindent 2 }}
{{- else }}
imagePullSecrets:
  - name: static-sbom-miggo-regcred
{{- end }}
{{- end -}}

{{- define "static-sbom.configMapCacheName" -}}
{{- default (printf "%s-cache" (include "static-sbom.fullname" .)) .Values.config.cache.configMap.name }}
{{- end }}
