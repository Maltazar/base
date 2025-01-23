{{- define "libs.externalsecret.tpl" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}

{{- range $name, $val := $v.externalSecret }}
  {{- if kindIs "map" $val }}
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
{{ include "helper.set.labels" (list $all $app $v) | indent 2 }}
{{ include "helper.set.annotations" (list $all $app $v) | indent 2 }}
  name: {{ include "helper.set.naming" (list $all $app $v "externalSecret") }}-{{ $name }}-es

spec:
  refreshInterval: {{ $val.refreshInterval | default "720h" }}
  secretStoreRef:
    name: {{ $val.storeRefName | default "get-secret" }}
    kind: {{ $val.storeRef | default "ClusterSecretStore" }}
  target:
    name: {{ $val.secretName }}
    {{- if $val.creationPolicy }}
    creationPolicy: {{ $val.creationPolicy }}
    {{- end }}
    {{- if $val.deletionPolicy }}
    deletionPolicy: {{ $val.deletionPolicy }}
    {{- end }}
    template:
      data:
{{ toYaml $val.secretData | indent 8 }}
  data:
{{ toYaml $val.requestData | indent 4 }}
  {{- end }}
---
{{ end }}
{{- end -}}


{{- define "libs.externalsecret" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- include "helper.no.merge" (list $all $app "externalsecret" ) -}}
{{- end -}}

{{- define "libs.externalsecret.otherContainters" -}}
{{- include "helper.merge.otherContainters" (list . "externalsecret" ) -}}
{{- end -}}