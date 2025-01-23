{{- define "helper.containerSection.tpl" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}
{{- $type := index . 3 -}}

- name: {{ $app }}
  {{/*--------------------------Environment Variables--------------------------*/}}
{{- if $v.container.env -}}
  env:
{{ toYaml $v.container.env | indent 2 }}
{{- end }}

  {{/*--------------------------Images--------------------------*/}}
  {{- if $v.image.fullPath -}}
  image: {{ $v.image.fullPath }}
  {{- else }}
  image: {{ printf "%s/%s:%s" ($v.image.repository | default "") ($v.image.name | default $app) ($v.image.tag | default "latest") }}
  {{- end }}
  imagePullPolicy: {{ $v.image.imagePullPolicy }}

  {{/*--------------------------Commands--------------------------*/}}
  {{- if $v.container.command -}}
  command:
{{ toYaml  $v.container.command | indent 4 }}

    {{- if $v.container.args }}
  args:
{{ toYaml  $v.container.args | indent 4 }}
    {{- end }}
  {{- end -}}

  {{/*--------------------------Ports--------------------------*/}}
  {{- with $v.services -}}
  ports:
    {{- range $key, $value := . }}
      {{- if kindIs "map" $value }}
        {{- range $portName, $sv := $value.ports }}
          {{- if kindIs "map" $sv }}
  - containerPort: {{ default $sv.port $sv.containerPort }}
    name: {{ $portName }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{/*--------------------------Probes--------------------------*/}}
{{- if $v.container.probes -}}
  probes:
{{ toYaml  $v.container.probes | indent 4 }}
{{- end -}}

  {{/*--------------------------Resources--------------------------*/}}
{{- if $v.container.resources -}}
  resources: 
{{ toYaml  $v.container.resources | indent 4 }}
{{- end -}}

  {{/*--------------------------extra--------------------------*/}}
{{- if $v.container.extra -}}
{{- range $key, $value := $v.container.extra }}
{{ printf "%s:" $key | indent 2 }}
{{ toYaml $value | indent 4 }}
{{- end -}}
{{- end -}}

  {{/*--------------------------Environment Variables From--------------------------*/}}
  envFrom:
  - configMapRef:
      name: {{ printf "%s-%s" ( include "helper.set.naming" (list $all $app $v "envmap") ) "env-map" }}
      optional: true
  - configMapRef:
      name: {{ printf "%s-%s" ( include "helper.set.naming" (list $all "global" $v "envmap") ) "env-map" }}
      optional: true
  - secretRef:
      name: {{ printf "%s-%s" ( include "helper.set.naming" (list $all $app $v "envsecrets") ) "env-secret" }}
      optional: true
  - secretRef:
      name: {{ printf "%s-%s" ( include "helper.set.naming" (list $all "global" $v "envsecrets") ) "env-secret" }}
      optional: true

{{- if $v.container.envFrom }}
{{ toYaml $v.container.envFrom | indent 2 }}
{{- end }}

  {{/*--------------------------Volume Mounts --------------------------*/}}
  volumeMounts:
{{- if $v.container.volumeMounts }}
{{ toYaml $v.container.volumeMounts | indent 2 }}
{{- end }}

  {{- if $v.template.persistentVolumes.enabled }}
    {{- range $n, $nv := $v.template.persistentVolumes.volumes }}
      {{- if kindIs "map" $nv }}
        {{- if $nv.enabled }}
  - name: {{ include "helper.set.naming" (list $all $app $v "persistentVolumes")  }}-{{ $n }}
    mountPath: {{ $nv.mountPath | quote }}
          {{- if $nv.subPath }}
    subPath: {{ $nv.subPath }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{- range $n, $nv := $v.persistentvolumeclaim }}
    {{- if kindIs "map" $nv }}
      {{- if $nv.enabled }}
  - name: {{ include "helper.set.naming" (list $all $app $v "persistentVolumeClaim")  }}-{{ $n }}
    mountPath: {{ $nv.mountPath | quote }}
          {{- if $nv.subPath }}
    subPath: {{ $nv.subPath }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{- range $v.triggerVariables }}
    {{- $triggerItem := . }}
    {{- range $i, $iv := (index $v $triggerItem ) }}
      {{- if kindIs "map" $iv }}
        {{- if and $iv.localPath (eq "create" (default "create" $iv.action)) }}
          {{- $selectedItems := $all.Files.Glob $iv.localPath }}
          {{- $localpath := $iv.localPath | replace "*" ""  }}
          {{- if eq ($iv.chartFiles | default "false" | toString) "true" }}
            {{- $chartfiles := dict }}
            {{- range $cfn, $cfv := (index $all.Subcharts (default "base" $iv.subChartName)).Files }}
              {{- if contains $localpath $cfn }}
                {{- $_ := set $chartfiles $cfn $cfv }}
              {{- end }}
            {{- end }}
            {{- $selectedItems = $chartfiles }}
          {{- end }}
          {{- range $path, $b := $selectedItems }}
            {{- $name := base $path }}
            {{- $directory := $iv.localPath | replace "/**" "" | replace "/*" "" | replace $name "" }}
            {{- $mountPoint := $iv.mountPath | replace ( printf "/%s" $name ) "" }}
  - name: {{ include "helper.set.naming" (list $all $app $v "volume") }}-{{ $i }}
            {{- if ne 1 (len (regexSplit $directory (dir $path) -1 )) }}
    mountPath: {{ printf "%s%s/%s" $mountPoint (index (regexSplit $directory (dir $path) -1 ) 1) $name }}
            {{- else }}
    mountPath: {{ printf "%s/%s" $mountPoint $name }}
            {{- end }}
    subPath: {{- $name | indent 1 }}
          {{- if $iv.readOnly }}
    readOnly: {{ $iv.readOnly }}
          {{- end }}
          {{- end }}
        {{- else }}
          {{- if $iv.mountPath }}
  - name: {{ include "helper.set.naming" (list $all $app $v "volume") }}-{{ $i }}
    mountPath: {{ $iv.mountPath }}
            {{- if $iv.subPath }}
    subPath: {{ $iv.subPath }}
            {{- end }}
            {{- if $iv.readOnly }}
    readOnly: {{ $iv.readOnly }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}


{{- if $v.container.lifecycle }}
  lifecycle:
{{ toYaml $v.container.lifecycle | indent 4 }}
{{- end }}

{{- end -}}