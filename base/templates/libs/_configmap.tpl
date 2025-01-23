{{- define "libs.configmap.tpl" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}

{{ range $name, $val := $v.configMaps }}
  {{ if kindIs "map" $val }}
  
apiVersion: v1
kind: ConfigMap
metadata:
{{ include "helper.set.labels" (list $all $app $v) | indent 2 }}
{{ include "helper.set.annotations" (list $all $app $v) | indent 2 }}
  name: {{ include "helper.set.naming" (list $all $app $v "configmaps") }}-{{ $name }}
    {{- if eq ( default "data" $val.dataType) "data" }}
data:
  
      {{- if eq ($val.chartFiles | default "false" | toString) "true" }}
        {{- $localpath := $val.localPath | replace "*" "" }}
        {{- range $cfn, $cfv := (index $all.Subcharts (default "base" $val.subChartName)).Files }}
          {{- if contains $localpath $cfn }}
            {{- $itemName := base $cfn }}
{{ printf "%s: |-" $itemName | indent 2 }}
{{ print ( tpl ( $cfv | toString ) $all ) | indent 4 }}            
          {{- end }}
        {{- end }}
      {{- else }}
      
        {{- range $p, $b := $all.Files.Glob $val.localPath }}
          {{- $itemName := base $p }}
{{ printf "%s: |-" $itemName | indent 2 }}
{{ print ( tpl ( $all.Files.Get $p ) $all ) | indent 4 }}
        {{- end }}
      {{- end }}
    {{- else if eq $val.dataType "binaryData" }}
binaryData:
      {{- range $p, $b := $all.Files.Glob $val.localPath }}
        {{- $itemName := base $p }}
{{ printf "%s: |-" $itemName | indent 2 }}
{{ $all.Files.Get $p | b64enc | indent 4 }}
      {{- end }}
    {{- end }}
  {{- end }}
---
{{ end }}
{{- end -}}


{{- define "libs.configmap" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- include "helper.no.merge" (list $all $app "configmap" ) -}}
{{- end -}}


{{- define "libs.configmap.otherContainters" -}}
{{- include "helper.merge.otherContainters" (list . "configmap" ) -}}
{{- end -}}