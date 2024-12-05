{{- define "common.otlpEndpoint" -}}
{{- $otlpEndpoint := (include "common.getVal" (list . "output.otlp.otlpEndpoint")) -}}
{{- if $otlpEndpoint -}}
{{- $otlpEndpoint -}}
{{- else -}}
http://miggo-collector.{{ .Release.Namespace }}.svc.cluster.local:4317
{{- end -}}
{{- end -}}
