# 2.3.13
- fix for template.zero_replicas, to set a 0 replica

# 2.3.12
- added template.zero_replicas, to set a 0 replica

# 2.3.11
- bad fix for sts 0 replicas

# 2.3.10
- added examples
- added selector for application to labels

# 2.3.9
- fix labels indentations
- fix selectors

# 2.3.8
- added option to inject yaml directly into the root of the spec of the template
- added revisionHistoryLimit as default value in the chart with global.template.root
- fix option to set replicas to none or 0, for HPA to take over

# 2.3.7
- fix volumemount when when mountPath is none

# 2.3.6
- fix tls key type

# 2.3.5
- added option to autogenerate cert keys in the secretMaps

# 2.3.4
- added initial readme documentation for this helm chart
