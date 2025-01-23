{{- define "helper.initContainers.tpl" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}

{{- range $v.initContainers }}
  {{- $selectedInitContainer := . }}
  {{- range $initContainer, $iv := (index $all.Values "initContainers") }}
    {{- if eq $initContainer $selectedInitContainer }}
      {{- if kindIs "map" $iv }}
        {{- if $iv.enabled }}
        {{- $default := deepCopy (index (index $all.Values "initContainers") "myInit") }}
        {{- $values := mergeOverwrite $default $iv }}
{{- include "helper.containerSection.tpl" (list $all $initContainer $values "initContainer") }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

{{- end -}}