{{/*
Use by this
{{- template "helper.mega.var_dump" $variable }}
*/}}
{{- define "helper.mega.var_dump" -}}
{{- . | mustToPrettyJson | printf "\nThe JSON output of the dumped var is: \n%s" | fail -}}
{{- end -}}

{{/*

*/}}
{{- define "helper.enabled.apps" -}}
  {{- $all := . -}}
  {{- $app := list -}}
  {{- range $key, $value := $all.Values -}}
    {{- $valid := "true" -}}
    {{- range $all.Values.global.noneAppVars -}}
      {{- if eq . $key -}}
        {{- $valid = "false" -}}
      {{- end -}}
    {{- end -}}

    {{- if eq $valid "true" -}}
      {{- if kindIs "map" $value -}}
        {{- if (index $all.Values $key).enabled -}}
          {{- if kindIs "string" $app -}}
          {{- $app = $key -}}
          {{- else -}}
          {{- $app = append $app $key -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{ toJson $app }}
{{- end -}}


{{- define "helper.chart" -}}
{{- $all := index . 0 -}}
{{- printf "%s-%s" $all.Chart.Name $all.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "helper.set.naming" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}
{{- $type := index . 3 -}}
{{- if not $v.naming -}}
{{ $_ := set $v "naming" $all.Values.global.naming }}
{{- end -}}
{{- if eq ($v.naming.addReleaseName | default $all.Values.global.naming.addReleaseName ) "prepend" -}}
  {{- printf "%s-%s" $all.Release.Name $app | trunc 63 | trimSuffix "-" -}}
{{- else if eq ($v.naming.addReleaseName | default $all.Values.global.naming.addReleaseName ) "append" -}}
  {{- printf "%s-%s" $app $all.Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else if eq ($v.naming.addReleaseName | default $all.Values.global.naming.addReleaseName ) "releaseOnly" -}}
  {{- $isExcluded := "false" -}}
  {{- range ($v.naming.excludedTypes | default $all.Values.global.naming.excludedTypes ) -}}
    {{- if eq . $type -}}
      {{- $isExcluded = "true" -}}
    {{- end -}}
  {{- end -}}
  {{- if eq "true" $isExcluded -}}
    {{- printf "%s-%s" $all.Release.Name $app | trunc 63 | trimSuffix "-" | indent 0 -}}
  {{- else -}}
    {{- printf "%s" $all.Release.Name | trunc 63 | trimSuffix "-" | indent 0 -}}
  {{- end -}}
{{- else if eq ($v.naming.addReleaseName | default $all.Values.global.naming.addReleaseName ) "appPrefix" -}}
  {{- $isExcluded := "false" -}}
  {{- range ($v.naming.excludedTypes | default $all.Values.global.naming.excludedTypes ) -}}
    {{- if eq . $type -}}
      {{- $isExcluded = "true" -}}
    {{- end -}}
  {{- end -}}
  {{- if eq "true" $isExcluded -}}
    {{- printf "%s-%s" $v.naming.prefix $app | trunc 63 | trimSuffix "-" | indent 0 -}}
  {{- else -}}
    {{- printf "%s" $v.naming.prefix | trunc 63 | trimSuffix "-" | indent 0 -}}
  {{- end -}}
{{- else -}}
  {{- printf "%s" $app | trunc 63 | trimSuffix "-" | indent 0 -}}
{{- end -}}
{{- end -}}


{{- define "helper.set.labels" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}
labels:
  helm.sh/chart: {{ include "helper.chart" . }}
  app.kubernetes.io/managed-by: {{ $all.Release.Service }}
{{ include "helper.set.selectors" . | indent 2 }}
{{ if $v.labels }}
{{ toYaml $v.labels | nindent 2 }}
{{ end }}
{{- end -}}


{{- define "helper.set.selectors" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}
app.kubernetes.io/name: {{ include "helper.set.naming" (list $all $app $v "selectors") }}
app.kubernetes.io/instance: {{ $all.Release.Name }}
app: {{ $app }}
{{ if $v.selectors }}
{{ toYaml $v.selectors }}
{{ end }}
{{- end -}}


{{- define "helper.set.annotations" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}
{{- if $v.annotations }}
annotations:
{{ toYaml $v.annotations | indent 2 }}
{{- end }}
{{- end -}}

{{- define "helper.statefulset.cluster" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}
{{- printf "%s-cluster" (include "helper.set.naming" (list $all $app $v "cluster")) -}}
{{- end -}}

{{- define "helper.checksums" -}}
{{- $all := index . 0 -}}
{{- $app := index . 1 -}}
{{- $v := index . 2 -}}

checksum/configmaps: {{ include "libs.configmap.tpl" (list $all $app $v) | sha256sum }}
checksum/configmaps_global: {{ include "libs.configmap.tpl" (list $all "global" $v) | sha256sum }}

checksum/envmaps: {{ include "libs.envmap.tpl" (list $all $app $v) | sha256sum }}
checksum/envmaps_global: {{ include "libs.envmap.tpl" (list $all "global" $v) | sha256sum }}

checksum/envsecret: {{ include "libs.envsecret.tpl" (list $all $app $v) | sha256sum }}
checksum/envsecret_global: {{ include "libs.envsecret.tpl" (list $all "global" $v) | sha256sum }}

checksum/certificate: {{ include "libs.certificate.tpl" (list $all $app $v) | sha256sum }}
checksum/certificate_global: {{ include "libs.certificate.tpl" (list $all "global" $v) | sha256sum }}

checksum/secretsmaps: {{ include "libs.secret.tpl" (list $all $app $v) | sha256sum }}
checksum/secretsmaps_global: {{ include "libs.secret.tpl" (list $all "global" $v) | sha256sum }}

checksum/externalsecret: {{ include "libs.externalsecret.tpl" (list $all $app $v) | sha256sum }}
checksum/externalsecret_global: {{ include "libs.externalsecret.tpl" (list $all "global" $v) | sha256sum }}
{{- end -}}
