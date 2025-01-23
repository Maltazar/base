{{- define "libs.jobs.tpl" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}
{{- range $name, $val := $v.jobs }}
  {{- if kindIs "map" $val }}
    {{- if $val.enabled }}
apiVersion: batch/v1
kind: Job
metadata:
{{ include "helper.set.labels" (list $all $app $v) | indent 2 }}
{{ include "helper.set.annotations" (list $all $app $v) | indent 2 -}}
  name: {{ include "helper.set.naming" (list $all $app $v "jobs") }}-{{ $name }}
spec:
  {{- if $val.spec }}
{{ toYaml $val.spec | indent 2 }}
  {{- end }}
  template:
    spec:
      {{- if $val.templateSpec }}
{{ toYaml $val.templateSpec | indent 6 }}
      {{- end }}
      containers:
        {{- range $cn, $cv := $val.containers }}
        - name: {{ $cn }}
{{ toYaml $cv | indent 10 }}
        {{- end }}

          volumeMounts:
          {{- if $v.container.volumeMounts }}
{{ toYaml $v.container.volumeMounts | indent 12 }}
          {{- end }}

          {{- range $v.triggerVariables }}
            {{- $triggerItem := . }}
            {{- range $i, $iv := (index $v $triggerItem ) }}
              {{- if kindIs "map" $iv }}
                {{- range $path, $b := $all.Files.Glob $iv.localPath }}
                {{- $name := base $path }}
          - name: {{ include "helper.set.naming" (list $all $app $v $triggerItem) }}-{{ $i }}
            mountPath: {{ printf "%s%s/%s" $iv.mountPath (index (regexSplit $iv.localPath (dir $path) -1 ) 1) $name }}
            subPath: {{- $name | indent 1 }}
                {{- end }}
              {{- end }}
            {{- end }}
          {{- end }}

      volumes:
      {{- if $v.volumes }}
{{ toYaml $v.volumes | indent 6 }}
      {{- end }}
      
      {{- range $v.triggerVariables }}
        {{- $triggerItem := . }}
        {{- range $i, $iv := (index $v $triggerItem ) }}
          {{- if kindIs "map" $iv }}
            {{- if $iv.mountPath }}
      - name: {{ include "helper.set.naming" (list $all $app $v "volume")  }}-{{ $i }}
      {{- if eq $triggerItem "configMaps" }}
        configMap:
      {{- else if eq $triggerItem "secretMaps" }}
        secret:
      {{- end }}
          name: {{ include "helper.set.naming" (list $all $app $v "volume")  }}-{{ $i }}
          defaultMode: {{ $iv.defaultMode | default 0777 }}
            {{- end }}
          {{- end }}
        {{- end }}

        {{- range $v.otherContainters }}
        {{- $otherType := . }}
        {{- range (index $v $otherType )  }}
          {{- $selectedOther := . }}
          {{- range $name, $val := (index $all.Values $otherType )  }}
            {{- if eq $name $selectedOther }}
              {{- if kindIs "map" $val }}
                {{- if $val.enabled }}
                  {{- range $i, $iv := (index $val $triggerItem ) }}
                    {{- if kindIs "map" $iv }}
                      {{- if $iv.mountPath }}
      - name: {{ include "helper.set.naming" (list $all $selectedOther $v "volume")  }}-{{ $i }}
      {{- if eq $triggerItem "configMaps" }}
        configMap:
      {{- else if eq $triggerItem "secretMaps" }}
        secret:
      {{- end }}
          name: {{ include "helper.set.naming" (list $all $selectedOther $v "volume")  }}-{{ $i }}
          defaultMode: {{ $iv.defaultMode | default 0777 }}
                      {{- end }}
                    {{- end }}
                  {{- end }}
                {{- end }}
              {{- end }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end -}}
      {{- end -}}

{{- end }}
{{- end }}
---
{{ end }}
{{- end -}}


{{- define "libs.jobs" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- include "helper.merge" (list $all $app "jobs" ) -}}
{{- end -}}


{{- define "libs.jobs.otherContainters" -}}
{{- include "helper.merge.otherContainters" (list . "jobs" ) -}}
{{- end -}}