{{- define "helper.merge" -}}
  {{- $all := index . 0 -}}
  {{- $app := index . 1 -}}
  {{- $item := index . 2 -}}

  {{- $global := deepCopy $all.Values.global -}}
  {{- $appdata := deepCopy (index $all.Values $app) | default dict -}}
  {{- $v := mergeOverwrite $global $appdata -}}

  {{- if $v.enabled -}}
    {{- $valuesList := list $all $app $v -}}
    {{- $template := printf "libs.%s.tpl" $item -}}
    {{- $loadedYaml := (include $template $valuesList) | default dict -}}
    {{- if $loadedYaml -}}
      {{- printf "\n---\n%s" ($loadedYaml | indent 0) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{- define "helper.merge.otherContainters" -}}
  {{- $all := index . 0 -}}
  {{- $item := index . 1 -}}
  {{- $global := deepCopy $all.Values.global -}}

  {{- range $all.Values.global.otherContainters -}}
    {{- $oc := . -}}
    {{- range $app, $value := (index $all.Values $oc) -}}
      {{- if kindIs "map" $value -}}
        {{- if $value.enabled -}}
          {{- $sectiondata := deepCopy (index $all.Values $oc $app)  | default dict -}}
          {{- $valueMerged := mergeOverwrite $global $sectiondata -}}
          {{- $valuesList := list $all $app $valueMerged -}}
          {{- $template := printf "libs.%s.tpl" $item -}}
          {{- $loadedYaml := (include $template $valuesList) | default dict -}}
          {{- if $loadedYaml -}}
            {{- printf "\n---\n%s" ($loadedYaml | indent 0) -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{- define "helper.merge.section" -}}
  {{- $all := index . 0 -}}
  {{- $sectionapp := index . 1 -}}
  {{- $v := index . 2 -}}
  {{- $item := index . 3 -}}

  {{- $global := deepCopy $all.Values.global -}}
  {{- $sectiondata := deepCopy (index $all.Values $item $sectionapp)  | default dict -}}
  {{- $valueMerged := mergeOverwrite $global $sectiondata -}}
  
  {{- if kindIs "map" $valueMerged -}}
    {{- if $valueMerged.enabled -}}
      {{- $valuesList := list $all $sectionapp $valueMerged -}}
      {{- $template := printf "section.%s.tpl" $item -}}
      {{- $loadedYaml := (include $template $valuesList) | default dict -}}
      {{- if $loadedYaml -}}
        {{- printf "%s" ( $loadedYaml | indent 0) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "helper.no.merge" -}}
  {{- $all := index . 0 -}}
  {{- $app := index . 1 -}}
  {{- $item := index . 2 -}}

  {{- $v := deepCopy (index $all.Values $app) | default dict -}}
  {{- if eq $app "global" -}}
  {{ $_ := set $v "enabled" "true" }}
  {{- end -}}
  {{- if not $v.naming -}}
  {{ $_ := set $v "naming" $all.Values.global.naming }}
  {{- end -}}

  {{- if $v.enabled -}}
    {{- $valuesList := list $all $app $v -}}
    {{- $template := printf "libs.%s.tpl" $item -}}
    {{- $loadedYaml := (include $template $valuesList) | default dict -}}
    {{- if $loadedYaml -}}
      {{- printf "\n---\n%s" ($loadedYaml | indent 0) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}