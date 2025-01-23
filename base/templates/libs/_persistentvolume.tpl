{{- define "libs.persistentvolumes.tpl" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}

{{- range $name, $val := $v.persistentVolumes }}
  {{- if kindIs "map" $val }}
    {{- if $val.enabled }}
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
{{ if $val.annotations }}
{{ toYaml $val.annotations | indent 4 }}
{{ end }}
{{- if contains "ssd" $val.storageClassName }}
    pv.kubernetes.io/provisioned-by: cluster.local/nfs-ssd-nfs-subdir-external-provisioner
{{- else if contains "hdd" $val.storageClassName }}
    pv.kubernetes.io/provisioned-by: cluster.local/nfs-hdd-nfs-subdir-external-provisioner
{{- end }}
  name: {{ include "helper.set.naming" (list $all $app $v "persistentVolumes")  }}-{{ $name }}
spec:
  accessModes:
    - {{ default "ReadWriteOnce" $val.accessMode | quote }}
  persistentVolumeReclaimPolicy: {{ default "Retain" $val.persistentVolumeReclaimPolicy | quote }}
  capacity:
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
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: {{ include "helper.set.naming" (list $all $app $v "persistentVolumes")  }}-{{ $val.pvc }}
    namespace: {{ $all.Release.Namespace }}
    {{- end }}
  {{- end }}
  volumeMode: Filesystem
  nfs:
{{- $nfspath := "" }}
{{- if contains "ssd" $val.storageClassName }}
{{- $nfspath = "/ssd/k3s" }}
{{- else if contains "hdd" $val.storageClassName }}
{{- $nfspath = "/hdd/k3s" }}
{{- else }}
{{- $nfspath = "/hdd/pvc" }}
{{- end }}
    path: {{ default ( printf "%s/%s-%s" $nfspath ( include "helper.set.naming" (list $all $app $v "persistentVolumes")) $val.pvc ) $val.serverPath }} 
    server: {{ $val.server}}

---
{{ end }}
{{- end -}}


{{- define "libs.persistentvolumes" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- include "helper.merge" (list $all $app "persistentvolumes" ) -}}
{{- end -}}


{{- define "libs.persistentvolumes.otherContainters" -}}
{{- include "helper.merge.otherContainters" (list . "persistentvolumes" ) -}}
{{- end -}}