{{- define "common.imageRegistry" -}}
{{- $imageRegistry := (include "common.getVal" (list . "image.registry")) -}}
{{- if $imageRegistry -}}
{{- $imageRegistry -}}
{{- else -}}
registry.miggo.io
{{- end -}}
{{- end -}}

{{- define "common.clientId" -}}
{{- $clientId := (include "common.getVal" (list . "config.clientId")) -}}
{{- if $clientId -}}
{{- $clientId -}}
{{- else -}}
P2UjsJwOFdIeUAtW0pGTJ5SeJAlq
{{- end -}}
{{- end -}}
