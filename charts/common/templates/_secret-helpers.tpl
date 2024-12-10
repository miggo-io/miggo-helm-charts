
{{/*
Genearte the image pull secret if needed.
*/}}
{{- define "common.miggoRegcredSecret" -}}
{{- $values := first . -}}
{{- $defaultSecretName := index . 1 -}}

{{- $imageRegistry := (include "common.imageRegistry" $values) }}
{{- $imageUser := (include "common.getVal" (list $values "imageCredentials.username")) }}
{{- $imagePassword := (include "common.getVal" (list $values "imageCredentials.password")) }}
{{- $clientId := (include "common.clientId" $values) }}
{{- $accessKey := (include "common.getVal" (list $values "config.accessKey")) }}

{{- if and (empty (index $values.Values.imagePullSecrets 0).name) (not (empty $imageUser)) }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ $defaultSecretName }}-miggo-regcred
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: {{ printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\"}}}" $imageRegistry $imageUser $imagePassword | b64enc | quote }}
{{- else if not (empty ($accessKey)) -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ $defaultSecretName }}-miggo-regcred
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: {{ printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\"}}}" $imageRegistry $clientId $accessKey | b64enc | quote }}
{{- end }}
{{- end -}}

{{/*
Configure imagePullSecrets for a Pod if needed.
*/}}
{{- define "common.imagePullSecrets" -}}
{{- $values := first . -}}
{{- $defaultSecretName := index . 1 -}}

{{- $global := $values.Values.global | default dict }}
{{- $emptyImagePullSecrets := list (dict "name" "") }}
{{- $globalImagePullSecrets := dig "imagePullSecrets" $emptyImagePullSecrets $global }}
{{- $imageUser := (include "common.getVal" (list $values "imageCredentials.username")) }}
{{- $accessKey := (include "common.getVal" (list $values "config.accessKey")) }}

{{- if (not (empty (index $values.Values.imagePullSecrets 0).name)) }}
imagePullSecrets:
  {{- toYaml $values.Values.imagePullSecrets | nindent 2 }}
{{- else if (not (empty (index $globalImagePullSecrets 0).name)) }}
imagePullSecrets:
  {{- toYaml $values.Values.global.imagePullSecrets | nindent 2 }}
{{- else if (not (empty $imageUser)) }}
imagePullSecrets:
  - name: {{ $defaultSecretName }}-miggo-regcred
{{- else if (not (empty $accessKey)) }}
imagePullSecrets:
  - name: {{ $defaultSecretName }}-miggo-regcred
{{- end }}
{{- end -}}
