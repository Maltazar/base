{{- define "libs.template.tpl" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}
apiVersion: apps/v1
kind: {{ $v.template.type | default "Deployment" }}
metadata:
{{ include "helper.set.labels" . | indent 2 }}
{{ include "helper.set.annotations" . | indent 2 }}
  name: {{ include "helper.set.naming" (list $all $app $v "template") }}
spec:
  selector:
    matchLabels: 
{{ include "helper.set.selectors" . | indent 6 }}
  {{/*--------------------------Deployment--------------------------*/}}
  {{- if $v.template.zero_replicas }}
  replicas: 0
  {{- else }}
  {{- if $v.template.replicas }}
  {{- if ne ($v.template.replicas | int) 0 }}
  replicas: {{ $v.template.replicas }}
  {{- end }}
  {{- end }}
  {{- end }}
  {{ toYaml $v.template.root | nindent 2 }}
  {{- if eq $v.template.type "Deployment" }}
  strategy:
{{ toYaml $v.template.deployment.strategy | indent 4 }}
  {{- end }}
  {{/*--------------------------StatefulSet--------------------------*/}}
  {{- if eq $v.template.type "StatefulSet" }}
  serviceName: {{ include "helper.statefulset.cluster" . }}
  updateStrategy:
{{ toYaml $v.template.statefulset.updateStrategy | indent 4 }}
  podManagementPolicy: {{ $v.template.statefulset.podManagementPolicy }}
  {{- end }}
  {{/*--------------------------Pod spec--------------------------*/}}
  template:
    metadata:
{{ include "helper.set.labels" . | indent 6 }}
      annotations:
{{ include "helper.checksums" . | indent 8 }}
        {{- if $v.template.annotations }}
{{ toYaml $v.template.annotations | indent 8 }}
        {{- end }}
    spec:
{{ toYaml $v.template.spec | indent 6 }}
      {{/*--------------------------initContainers--------------------------*/}}
      initContainers:
{{ include "helper.initContainers.tpl" (list $all $app $v ) | indent 6 -}}
      {{/*--------------------------Containers--------------------------*/}}
      containers:
{{ include "helper.containerSection.tpl" (list $all $app $v "container") | indent 6 -}}

      {{/*--------------------------Sidecars--------------------------*/}}

{{ include "helper.sidecars" (list $all $app $v ) | indent 6 -}}
      {{/*--------------------------Volumes--------------------------*/}}
      volumes:
      {{- if $v.volumes }}
{{ toYaml $v.volumes | indent 6 }}
      {{- end }}

      {{- if $v.template.persistentVolumes.enabled }}
        {{- range $n, $nv := $v.template.persistentVolumes.volumes }}
          {{- if kindIs "map" $nv }}
            {{- if $nv.enabled }}
      - name: {{ include "helper.set.naming" (list $all $app $v "persistentVolumes")  }}-{{ $n }}
        persistentVolumeClaim:
          claimName: {{ include "helper.set.naming" (list $all $app $v "persistentVolumes")  }}-{{ $n }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}

      {{- range $n, $nv := $v.persistentvolumeclaim }}
        {{- if kindIs "map" $nv }}
          {{- if $nv.enabled }}
      - name: {{ include "helper.set.naming" (list $all $app $v "persistentVolumeClaim")  }}-{{ $n }}
        persistentVolumeClaim:
          claimName: {{ include "helper.set.naming" (list $all $app $v "persistentVolumeClaim")  }}-{{ $n }}
          {{- end }}
        {{- end }}
      {{- end }}
      
      {{- range $v.triggerVariables }}
        {{- $triggerItem := . }}
        {{- range $i, $iv := (index $v $triggerItem ) }}
          {{- if kindIs "map" $iv }}
            {{- if $iv.mountPath }}
      - name: {{ include "helper.set.naming" (list $all $app $v "volume")  }}-{{ $i }}
              {{- if eq $triggerItem "configMaps" }}
        configMap:
                {{- if eq "create" (default "create" $iv.action) }}
          name: {{ include "helper.set.naming" (list $all $app $v "configmaps")  }}-{{ $i }}
                {{- else }}
          name: {{ $i }}
                {{- end }}
          defaultMode: {{ $iv.defaultMode | default 0777 }}
              {{- else if eq $triggerItem "secretMaps" }}
        secret:
                {{- if eq "create" (default "create" $iv.action) }}
          secretName: {{ include "helper.set.naming" (list $all $app $v "secrets")  }}-{{ $i }}
                {{- else }}
          secretName: {{ $i }}
                {{- end }}
          defaultMode: {{ $iv.defaultMode | default 0744 }}
              {{- end }}
            {{- end }}
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
                  {{- range $v.triggerVariables }}
                  {{- $triggerItem := . }}
                    {{- range $i, $iv := (index $val $triggerItem ) }}
                      {{- if kindIs "map" $iv }}
                        {{- if $iv.mountPath }}
      - name: {{ include "helper.set.naming" (list $all $selectedOther $v "volume")  }}-{{ $i }}
                {{- if eq $triggerItem "configMaps" }}
        configMap:
                {{- if eq "create" (default "create" $iv.action) }}
          name: {{ include "helper.set.naming" (list $all $app $v "configmaps")  }}-{{ $i }}
                {{- else }}
          name: {{ $i }}
                {{- end }}
          defaultMode: {{ $iv.defaultMode | default 0777 }}
              {{- else if eq $triggerItem "secretMaps" }}
        secret:
                {{- if eq "create" (default "create" $iv.action) }}
          secretName: {{ include "helper.set.naming" (list $all $app $v "secrets")  }}-{{ $i }}
                {{- else }}
          secretName: {{ $i }}
                {{- end }}
          defaultMode: {{ $iv.defaultMode | default 0744 }}
              {{- end }}
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
  
  {{- if and (eq $v.template.type "StatefulSet") $v.template.persistentVolumes.enabled }}
  volumeClaimTemplates:
    {{- range $n, $nv := $v.template.persistentVolumes.volumes }}
      {{- if kindIs "map" $nv }}
        {{- if $nv.enabled }}
  - metadata:
      name: {{ include "helper.set.naming" (list $all $app $v "volume")  }}-{{ $n }}
    spec:
{{ toYaml $nv.volumeClaimTemplatesSpec | indent 6 }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}


{{- define "libs.template" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- include "helper.merge" (list $all $app "template" ) -}}
{{- end -}}