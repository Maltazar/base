{{- define "base.tpl" -}}

{{- $main := . -}}
{{- $global := fromYaml (include "base.defaults.tpl" "" ) -}}
{{- $all := mergeOverwrite $global $main  -}}
{{/*
Main variable
*/}}

{{/*
Non main container includes
*/}}

{{- include "libs.configmap.otherContainters" $all -}}
{{- include "libs.secret.otherContainters" $all -}}
{{- include "libs.envmap.otherContainters" $all -}}
{{- include "libs.envsecret.otherContainters" $all -}}
{{- include "libs.externalsecret.otherContainters" $all -}}
{{- include "libs.service.otherContainters" $all -}}
{{- include "libs.ingress.otherContainters" $all -}}
{{- include "libs.jobs.otherContainters" $all -}}
{{- include "libs.persistentvolumes.otherContainters" $all -}}
{{- include "libs.persistentvolumeclaim.otherContainters" $all -}}


{{/*
Global includes
*/}}
{{- include "libs.configmap" ( list $all "global" ) -}}
{{- include "libs.envmap" ( list $all "global" ) -}}
{{- include "libs.envsecret" ( list $all "global" ) -}}
{{- include "libs.externalsecret" ( list $all "global" ) -}}
{{- include "libs.persistentvolumes" ( list $all "global" ) -}}
{{- include "libs.persistentvolumeclaim" ( list $all "global" ) -}}
{{- include "libs.service" ( list $all "global" ) -}}
{{- include "libs.ingress" ( list $all "global" ) -}}
{{- include "libs.secret" ( list $all "global" ) -}}

{{/*
Application range
*/}}

{{- range ( include "helper.enabled.apps" $all | fromJsonArray ) -}}
{{- $app := . -}}

{{- include "libs.configmap" ( list $all $app ) -}}
{{- include "libs.envmap" ( list $all $app ) -}}
{{- include "libs.envsecret" ( list $all $app ) -}}
{{- include "libs.externalsecret" ( list $all $app ) -}}
{{- include "libs.secret" ( list $all $app ) -}}
{{- include "libs.template" ( list $all $app ) -}}
{{- include "libs.service" ( list $all $app ) -}}
{{- include "libs.ingress" ( list $all $app ) -}}
{{- include "libs.jobs" ( list $all $app ) -}}
{{- include "libs.persistentvolumes" ( list $all $app ) -}}
{{- include "libs.persistentvolumeclaim" ( list $all $app ) -}}


{{- end -}}

{{- end -}}