{{- define "libs.envmap.tpl" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}
{{- if $v.envs }}
{{ if kindIs "map" $v.envs }}
apiVersion: v1
kind: ConfigMap
metadata:
{{ include "helper.set.labels" (list $all $app $v) | indent 2 }}
{{ include "helper.set.annotations" (list $all $app $v) | indent 2 }}
  name: {{ include "helper.set.naming" (list $all $app $v "envmap") }}-env-map
data:
{{ toYaml $v.envs | indent 2 }}
{{ end }}
{{ end }}
{{- end -}}


{{- define "libs.envmap" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- include "helper.merge" (list $all $app "envmap" ) -}}
{{- end -}}

{{- define "libs.envmap.otherContainters" -}}
{{- include "helper.merge.otherContainters" (list . "envmap" ) -}}
{{- end -}}