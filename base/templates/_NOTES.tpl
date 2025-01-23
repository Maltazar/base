{{- define "notes" -}}
{{- $main := . -}}
{{- $global := fromYaml (include "base.defaults.tpl" "" ) -}}
{{- $all := mergeOverwrite $global $main  -}}
{{ include "notes.header" . }}
{{- $format := "%-1.1s %-21.21s %-7.7s %-3.3s %2.2s %4.4s%1s%-4.4s %4.4s%1s%-4.4s %-5.5s" }}
{{- $initconFormat := "    init    - %s" }}
{{- $sidecarFormat := "    sidecar - %s" }}
#
#  {{ printf $format " " "       Product       " "  tag  " "typ" " #" " cpu" " " "R/L " " mem" " " "R/L " "https"}}
#  {{ printf $format " " "---------------------" "-------" "---" "--" "----" "-" "----" "----" "-" "----" "-----"}}
#
{{- range ( include "helper.enabled.apps" $all | fromJsonArray ) -}}
{{- $app := . -}}
{{- if eq $app "---" }}
#
{{- end }}
{{- with (index $all.Values $app)}}
    {{- $v := mergeOverwrite $all.Values.global . -}}
    {{- $appEnabled := ternary "√" "" .enabled }}
    {{- $tag := ternary (default "latest" $v.image.tag | toString) "" .enabled }}
    {{- $template := "" }}
    {{- $numReplica := "" }}
    {{- if $v.template }}
        {{- $template = ternary (ternary "dep" "sts" (eq $v.template.type "Deployment")) "" .enabled }}
        {{- $numReplica = ternary (toString $v.template.replicas) "" .enabled }}
    {{- end }}
    {{- $slash := ternary "/" "" .enabled }}
    {{- $cpur := "" }}
    {{- $cpul := "" }}
    {{- $memr := "" }}
    {{- $meml := "" }}
    {{- if $v.container }}
        {{- if $v.container.resources }}
            {{- $cpur = ternary (toString $v.container.resources.requests.cpu) "" .enabled }}
            {{- $cpul = ternary (toString $v.container.resources.limits.cpu) "" .enabled }}
            {{- $memr = ternary (toString $v.container.resources.requests.memory) "" .enabled }}
            {{- $meml = ternary (toString $v.container.resources.limits.memory) "" .enabled }}
        {{- end }}
    {{- end }}
#  {{ printf $format $appEnabled $app $tag $template $numReplica $cpur $slash $cpul $memr $slash $meml  }}
{{- if .enabled }}
{{- range .includeInitContainers }}
{{- end }}
{{- range .includeSidecars }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
#
{{ include "notes.footer" $all }}
{{- end }}