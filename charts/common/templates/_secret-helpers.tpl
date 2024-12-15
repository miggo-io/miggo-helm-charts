
{{/*
Genearte the image pull secret if needed.
*/}}
{{- define "common.miggoRegcredSecret" -}}
{{- $values := first . -}}
{{- $defaultSecretName := index . 1 -}}

{{- $global := $values.global | default dict }}
{{- $globalImageCredentialsUsername := dig "imageCredentials" "username" "" $global }}
{{- $username := coalesce $values.imageCredentials.username $globalImageCredentialsUsername }}
{{- $globalAccessKey := dig "config" "accessKey" "" $global }}
{{- $accessKey := coalesce $values.config.accessKey $globalAccessKey }}
{{- $globalClientId := dig "config" "clientId" "" $global }}
{{- $clientId := coalesce $values.config.clientId $globalClientId }}
{{- if and (empty (index $values.imagePullSecrets 0).name) (not (empty $username)) }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ $defaultSecretName }}-miggo-regcred
type: kubernetes.io/dockerconfigjson
data:
  {{- $global := $values.global | default dict }}
  {{- $globalImageCredentialsRegistry := dig "imageCredentials" "registry" "" $global }}
  {{- $globalImageCredentialsUsername := dig "imageCredentials" "username" "" $global }}
  {{- $globalImageCredentialsPassword := dig "imageCredentials" "password" "" $global }}
  {{- $imageCredentialsRegistry := coalesce $values.imageCredentials.registry $globalImageCredentialsRegistry }}
  {{- $imageCredentialsPassword := coalesce $values.imageCredentials.password $globalImageCredentialsPassword }}
  .dockerconfigjson: {{ printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\"}}}" $imageCredentialsRegistry $username $imageCredentialsPassword | b64enc | quote }}
{{- else if not (empty ($accessKey)) -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ $defaultSecretName }}-miggo-regcred
type: kubernetes.io/dockerconfigjson
data:
  {{- $global := $values.global | default dict }}
  {{- $globalImageRegistry := dig "image" "registry" "" $global }}
  {{- $imageRegistry := coalesce $values.image.registry $globalImageRegistry }}
  .dockerconfigjson: {{ printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\"}}}" $imageRegistry $clientId $accessKey | b64enc | quote }}
{{- end }}
{{- end -}}

{{/*
Configure imagePullSecrets for a Pod if needed.
*/}}
{{- define "common.imagePullSecrets" -}}
{{- $values := first . -}}
{{- $defaultSecretName := index . 1 -}}

{{- $global := $values.global | default dict }}
{{- $emptyImagePullSecrets := list (dict "name" "") }}
{{- $globalImagePullSecrets := dig "imagePullSecrets" $emptyImagePullSecrets $global }}
{{- $globalImageCredentialsUsername := dig "imageCredentials" "username" "" $global }}
{{- $username := coalesce $values.imageCredentials.username $globalImageCredentialsUsername }}
{{- $globalAccessKey := dig "config" "accessKey" "" $global }}
{{- $accessKey := coalesce $values.config.accessKey $globalAccessKey }}
{{- if (not (empty (index $values.imagePullSecrets 0).name)) }}
imagePullSecrets:
  {{- toYaml $values.imagePullSecrets | nindent 2 }}
{{- else if (not (empty (index $globalImagePullSecrets 0).name)) }}
imagePullSecrets:
  {{- toYaml $values.global.imagePullSecrets | nindent 2 }}
{{- else if (not (empty $username)) }}
imagePullSecrets:
  - name: {{ $defaultSecretName }}-miggo-regcred
{{- else if (not (empty $accessKey)) }}
imagePullSecrets:
  - name: {{ $defaultSecretName }}-miggo-regcred
{{- end }}
{{- end -}}
