{{- define "libs.secret.tpl" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}

{{- range $name, $val := $v.secretMaps }}
  {{- if kindIs "map" $val }}
  {{- if eq "create" (default "create" $val.action) }}
apiVersion: v1
kind: Secret
metadata:
{{ include "helper.set.labels" (list $all $app $v) | indent 2 }}
{{ include "helper.set.annotations" (list $all $app $v) | indent 2 }}
  name: {{ include "helper.set.naming" (list $all $app $v "secrets") }}-{{ $name }}
      {{- if $val.tlsType }}
type: kubernetes.io/tls
      {{- end }}
data:
    {{- if $val.keys }}
      {{- range $val.keys }}
    {{- $cert := genSelfSignedCertWithKey (default "" (default .name .hostname)) (list) (list) 3650 (genPrivateKey "rsa") }}
{{ printf "%s.crt: |-" .name | indent 2}}
{{ $cert.Cert | b64enc | nindent 4}}
{{ printf "%s.key: |-" .name | indent 2}}
{{ $cert.Key | b64enc | nindent 4}}
      {{- end }}
    {{- else }}
      {{- range $p, $b := $all.Files.Glob $val.localPath }}
      {{- $itemName := base $p }}
{{ printf "%s: |-" $itemName | indent 2 }}
{{ tpl ( $all.Files.Get $p ) $all | b64enc | indent 4 }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- end }}
---
{{ end }}
{{- end -}}


{{- define "libs.secret" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- include "helper.no.merge" (list $all $app "secret" ) -}}
{{- end -}}


{{- define "libs.secret.otherContainters" -}}
{{- include "helper.merge.otherContainters" (list . "secret" ) -}}
{{- end -}}