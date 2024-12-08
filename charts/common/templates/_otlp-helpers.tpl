{{- define "common.otlpEndpoint" -}}
{{- $otlpEndpoint := (include "common.getVal" (list . "output.otlp.otlpEndpoint")) -}}
{{- if $otlpEndpoint -}}
{{- $otlpEndpoint -}}
{{- else -}}
http://miggo-collector.{{ .Release.Namespace }}.svc.cluster.local:4318
{{- end -}}
{{- end -}}

{{- define "common.otlp.authHeader" -}}
{{- $global := .Values.global | default dict }}
{{- $globalOtlpHttpAuthHeader := dig "output" "otlp" "httpAuthHeader" "" $global }}
{{- $authHeader := coalesce .Values.output.otlp.httpAuthHeader $globalOtlpHttpAuthHeader "" }}
{{- if $authHeader }}
{{- $authHeader -}}
{{- end }}
{{- end }}
