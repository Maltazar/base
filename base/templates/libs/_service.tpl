{{- define "libs.service.tpl" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}

{{- range $name, $val := $v.services }}
  {{- if kindIs "map" $val }}
  {{- $_ := set $val "naming" $v.naming -}}
apiVersion: v1
kind: Service
metadata:
{{ include "helper.set.labels" (list $all $app $val) | indent 2 }}
{{ include "helper.set.annotations" (list $all $app $val) | indent 2 }}
  name: {{ include "helper.set.naming" (list $all $app $v "services") }}-{{ $name }}
spec:
{{- if $val.spec }}
{{ toYaml $val.spec | indent 2 }}
{{- end }}
  ports:
  {{- range $pName, $pv := $val.ports }}
    {{- if kindIs "map" $pv }}
    - name: {{ $pName }}
      port: {{ $pv.port }}
      targetPort: {{ default $pv.port $pv.containerPort }}
      protocol: {{ $pv.protocol | default "TCP" }}
    {{- end }}
  {{- end }}
  selector:
{{ include "helper.set.selectors" (list $all $app $val) | indent 6 }}
  {{- end }}
---
{{ end }}
{{- end -}}


{{- define "libs.service" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- include "helper.no.merge" (list $all $app "service" ) -}}
{{- end -}}


{{- define "libs.service.otherContainters" -}}
{{- include "helper.merge.otherContainters" (list . "service" ) -}}
{{- end -}}