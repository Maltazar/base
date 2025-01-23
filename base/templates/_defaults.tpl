{{- define "base.defaults.tpl" -}}
Values:
  global:
    image:
      # fullPath:       # Full URL path
      # repository:     # Repository to download image from     - default ""
      # name:           # Image name to download                - default $app
      # tag:            # Image tag                             - default latests
      imagePullPolicy: IfNotPresent

    template:
      type: Deployment
      replicas: 1

      deployment:
        strategy:
          type: Recreate

      statefulset:
        updateStrategy:
          type: RollingUpdate
        podManagementPolicy: OrderedReady

      annotations: []

      root:
        revisionHistoryLimit: 2
      spec:
        terminationGracePeriodSeconds: 30

      persistentVolumes:
        enabled: false
      
        
    container:
      env: []
      command: []
      args: []
      envFrom: []
      probes: []
      resources: []
      extra: []
      volumeMounts: []

    envs: []

    noneAppVars: [ "global" ]
    otherContainters: ["sidecars", "initContainers"]
    triggerVariables: [ "configMaps", "secretMaps" ]

    naming:
      addReleaseName: releaseOnly
      excludedTypes: ["sidecars", "initContainers", "envsecrets", "envmap", "jobs"]

    defaultDomain: mydomain.local

  sidecars:
    mySidecar:
      enabled: false

      container:
        env: []
        command: []
        args: []
        envFrom: []
        probes: []
        resources: []
        extra: []
        volumeMounts: []

      naming:
        addReleaseName: releaseOnly

      template:
        type: sidecars
        annotations: []
        persistentVolumes:
          enabled: false


  initContainers:
    myInit:
      enabled: false

      container:
        env: []
        command: []
        args: []
        envFrom: []
        probes: []
        resources: []
        extra: []
        volumeMounts: []

      naming:
        addReleaseName: releaseOnly

      template:
        type: initContainer
        annotations: []
        persistentVolumes:
          enabled: false

{{ end }}