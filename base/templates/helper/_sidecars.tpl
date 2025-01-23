{{- define "section.sidecars.tpl" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}
{{- include "helper.containerSection.tpl" (list $all $app $v "sidecars") -}}
{{- end -}}


{{- define "helper.sidecars" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}

{{- range $v.sidecars }}
  {{- $selectedSidecars := . }}
  {{- range $scar, $sv := (index $all.Values "sidecars") }}
    {{- if eq $scar $selectedSidecars }}
      {{- if kindIs "map" $sv }}
        {{- if $sv.enabled }}
        {{- $default := deepCopy (index (index $all.Values "sidecars") "mySidecar") }}
        {{- $values := mergeOverwrite $default $sv }}

{{- include "helper.merge.section" (list $all $scar $values "sidecars" ) -}}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}