{{- define "libs.envsecret.tpl" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}
{{- if $v.envSecrets }}
apiVersion: v1
kind: Secret
metadata:
{{ include "helper.set.labels" (list $all $app $v) | indent 2 }}
{{ include "helper.set.annotations" (list $all $app $v) | indent 2 }}
  name: {{ include "helper.set.naming" (list $all $app $v "envsecrets") }}-env-secret
data:
{{- range $k, $sv := $v.envSecrets }}
{{- $k | indent 2 }}{{ print ": " }}{{ $sv | b64enc }}
{{- end }}
{{- end }}
{{- end -}}


{{- define "libs.envsecret" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- include "helper.merge" (list $all $app "envsecret" ) -}}
{{- end -}}


{{- define "libs.envsecret.otherContainters" -}}
{{- include "helper.merge.otherContainters" (list . "envsecret" ) -}}
{{- end -}}