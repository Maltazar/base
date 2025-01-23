{{- define "libs.ingress.tpl" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}

{{- range $name, $val := $v.ingress }}
  {{- if kindIs "map" $val }}
    {{- if $val.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "helper.set.naming" (list $all $app $v "ingress") }}-{{ $name }}
  annotations: {{ toYaml $val.annotations  | nindent 4 }}
{{ include "helper.set.annotations" (list $all $app $v) | indent 2 }}
{{ include "helper.set.labels" (list $all $app $v) | indent 2 }}
spec:
  ingressClassName: {{ $val.ingressClassName | default "nginx" }}
  tls:
    {{- range $val.tls }}
    - hosts:
{{ toYaml .hosts | indent 6 }}
      {{- if .secretName }}
      secretName: {{ tpl .secretName $all | quote }}
      {{- end }}
    {{- end }}
  rules:
    {{- range $val.rules }}
    - http:
        paths:
{{ toYaml .paths | indent 8 }}
      host: {{ default ( printf "%s.%s" $name $v.defaultDomain ) .host | quote }}
    {{- end }}

    {{- range $serviceName, $values := $val.serviceNames }}
    - http:
        paths:
        - backend:
            service:
              name: {{ include "helper.set.naming" (list $all $app $v "services") }}-{{ $serviceName }}
              port:
                {{ if $values.port }}
                number: {{ $values.port }}
                {{ end }}
                {{ if $values.name }}
                name: {{ $values.name }}
                {{ end }}
          path: {{ $values.path | default "/" }}
          pathType: {{ $values.pathType | default "Prefix" }}
      host: {{ default ( printf "%s.%s" $name $v.defaultDomain ) $values.host | quote }}
    {{- end }}
    
    {{- end }}
  {{- end }}
---
{{ end }}
{{- end -}}


{{- define "libs.ingress" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- include "helper.no.merge" (list $all $app "ingress" ) -}}
{{- end -}}

{{- define "libs.ingress.otherContainters" -}}
{{- include "helper.merge.otherContainters" (list . "ingress" ) -}}
{{- end -}}