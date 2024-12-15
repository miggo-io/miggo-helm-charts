{{/* 
Gets a value from .Values, falls back to .Values.global, then empty string
Usage: {{ include "common.getVal" (list . "config.output.port") }}
*/}}
{{- define "common.getVal" -}}
{{- $ctx := index . 0 -}}
{{- $path := index . 1 -}}
{{- $value := "" -}}
{{- $parts := splitList "." $path -}}
{{- $current := $ctx.Values -}}
{{- $exists := true -}}
{{- range $parts -}}
    {{- if and $exists (hasKey $current .) -}}
        {{- $current = (index $current .) -}}
    {{- else -}}
        {{- $exists = false -}}
    {{- end -}}
{{- end -}}
{{- if and $exists $current -}}
    {{- $value = $current -}}
{{- else -}}
    {{- if hasKey $ctx.Values "global" -}}
        {{- $current = $ctx.Values.global -}}
        {{- $exists = true -}}
        {{- range $parts -}}
            {{- if and $exists (hasKey $current .) -}}
                {{- $current = (index $current .) -}}
            {{- else -}}
                {{- $exists = false -}}
            {{- end -}}
        {{- end -}}
        {{- if and $exists $current -}}
            {{- $value = $current -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- $value | toString | trim -}}
{{- end -}}
