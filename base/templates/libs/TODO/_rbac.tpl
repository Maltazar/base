{{- define "libs.rbac.tpl" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}

{{- end -}}


{{- define "libs.rbac" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- include "helper.merge" (list $all $app "rbac" ) -}}
{{- end -}}