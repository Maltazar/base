{{- define "libs.persistentvolumeclaim.tpl" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}

{{- range $name, $val := $v.persistentvolumeclaim }}
  {{- if kindIs "map" $val }}
    {{- if $val.enabled }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
{{ include "helper.set.labels" (list $all $app $v) | indent 2 }}
{{ include "helper.set.annotations" (list $all $app $v) | indent 2 }}
  name: {{ include "helper.set.naming" (list $all $app $v "persistentVolumeClaim")  }}-{{ $name }}
spec:
  accessModes:
    - {{ default "ReadWriteOnce" $val.accessMode | quote }}
  resources:
    requests:
      storage: {{ $val.size | quote }}
  {{- if $val.storageClassName }}
    {{- if eq "-" $val.storageClassName }}
  storageClassName: ""
    {{- else }}
  storageClassName: {{ $val.storageClassName | quote }}
    {{- end }}
  {{- end }}
  {{- if $val.spec }}
{{ toToml $val.spec | indent 2 }}
  {{- end }}
    {{- end }}
  {{- end }}
---
{{ end }}
{{- end -}}


{{- define "libs.persistentvolumeclaim" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- include "helper.merge" (list $all $app "persistentvolumeclaim" ) -}}
{{- end -}}


{{- define "libs.persistentvolumeclaim.otherContainters" -}}
{{- include "helper.merge.otherContainters" (list . "persistentvolumeclaim" ) -}}
{{- end -}}