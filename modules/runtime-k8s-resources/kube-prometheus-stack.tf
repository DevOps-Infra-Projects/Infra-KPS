locals {
  prometheus_service_port = 9090
  alertmanager_auth_host = "${var.prefix_hosts}alertmanager-auth.${var.cluster_name}.galaxykube.com"
  kps_service_monitor_selector_label_release = "kps"
}





data "template_file" "kps_values" {
  template = <<EOF
namespaceOverride: ${kubernetes_namespace.kube-prometheus-stack.metadata[0].name}
kube-state-metrics:
  namespaceOverride: ${kubernetes_namespace.kube-prometheus-stack.metadata[0].name}
prometheus-node-exporter:
  namespaceOverride: ${kubernetes_namespace.kube-prometheus-stack.metadata[0].name}
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 5 #speed up rollout

#should not update the tag, rather upgrade the chart https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack#upgrading-an-existing-release-to-a-new-major-version
# prometheusOperator:
#   image:
#     tag: v0.53.0 

defaultRules:
  disabled: #disabled some warnings that recover themselves
    NodeFilesystemSpaceFillingUp: true
    NodeFilesystemFilesFillingUp: true
    KubePodNotReady: true
  #additionalRuleLabels:
  #  slack: alerts-mrissa #I get this error "vector contains metrics with the same labelset after applying rule labels" when a record is built based on a record

kubeControllerManager:
  enabled: false #don't monitor it, it's managed by EKS
kubeScheduler:
  enabled: false #it's aws managed

alertmanager:
  alertmanagerSpec:
    podMetadata:
      annotations:
        "cluster-autoscaler.kubernetes.io/safe-to-evict": "true"
    useExistingSecret: true
    # secrets:
    # - alertmanager-config-2
    alertmanagerConfigSelector:
      matchLabels:
        alertmanagerSelector: alertmanager-main
    storage: 
      volumeClaimTemplate:
        spec:
          storageClassName: ssd-retain
          resources:
            requests:
              storage: 5Gi
  ingress:
    enabled: true
    annotations: 
      kubernetes.io/ingress.class                             : "nginx"
      cert-manager.io/cluster-issuer                          : "letsencrypt"
      nginx-annotations-injector.galaxy.kubernetes.io/authelia : "yes"
    hosts: 
      - "${var.kps_alert_host}"
    pathType: "Prefix"
    paths:
      - "/"
    tls:
      - secretName: alertmanager-tls
        hosts:
        - ${var.kps_alert_host}
prometheus:
  enabled: true
  ingress:
    enabled: true
    annotations: 
      kubernetes.io/ingress.class                             : "nginx"
      cert-manager.io/cluster-issuer                          : "letsencrypt"
      nginx.ingress.kubernetes.io/rewrite-target              : "/$1"
      nginx-annotations-injector.galaxy.kubernetes.io/authelia : "yes"
    hosts: 
      - "${var.kps_prom_host}"
    pathType: "Prefix"
    paths:
      - /mrissa/(.*)
    tls:
      - secretName: prometheus-tls
        hosts:
        - ${var.kps_prom_host}
  prometheusSpec:
    externalUrl: "https://${var.kps_prom_host}/mrissa"
    podMetadata:
      annotations:
        "cluster-autoscaler.kubernetes.io/safe-to-evict": "true"
    resources:
      requests:
        cpu: ${var.kps_prom_request_cpu}
        memory: ${var.kps_prom_request_memory}
      limits:
        cpu: ${var.kps_prom_limit_cpu}
        memory: ${var.kps_prom_limit_memory}
    shards: null
    retention: ${var.kps_prom_retention}
    storageSpec: 
      volumeClaimTemplate:
        spec:
          storageClassName: ssd-retain
          resources:
            requests:
              storage: ${var.kps_prom_persistence_size}Gi
    serviceMonitorSelectorNilUsesHelmValues: true #Let Prometheus discover all ServiceMonitors within its namespace without label filtering
    serviceMonitorSelector: {}
    enableAdminAPI: true
    replicaExternalLabelNameClear: true
    prometheusExternalLabelNameClear: true
    externalLabels: 
      prometheus: mrissa
    remoteWrite:
      - url: http://vminsert-vmcluster.victoria-operator.svc.cluster.local:8480/insert/0/prometheus/api/v1/write
        queueConfig:
          capacity: 20000
          maxSamplesPerSend: 10000
          maxShards: 30
    additionalScrapeConfigs: 
    - job_name: kubernetes-pods
      kubernetes_sd_configs:
        - role: pod
      scheme: http
      tls_config:
        insecure_skip_verify: true
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      relabel_configs:
      # Example relabel to scrape only pods that have "prometheus.io/scrape: = true" annotation.
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      # ignore failed pods
      - source_labels: [__meta_kubernetes_pod_phase]
        regex: '(Failed|Succeeded)'
        action: drop
      # Example relabel to customize metric path based on pod "prometheus.io/path = <metric path>" annotation.
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scheme]
        action: replace
        target_label: __scheme__
        regex: (https?)
      # Example relabel to scrape only single, desired port for the pod based on pod "prometheus.io/port = <port>" annotation.
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__
      - action: labelmap
        regex: __meta_kubernetes_pod_label_(.+)
      - source_labels: [__meta_kubernetes_namespace]
        action: replace
        target_label: kubernetes_namespace
      - source_labels: [__meta_kubernetes_pod_name]
        action: replace
        target_label: kubernetes_pod_name

%{ if var.kps_prom_scrape_blocket_endpoints }
    - job_name: blackbox_blocket-endpoints
      kubernetes_sd_configs:
      - role: service
      metrics_path: /probe
      params:
        module:
        - tcp_connect
      relabel_configs:
      - action: keep
        regex: true
        source_labels:
        - __meta_kubernetes_service_annotation_prometheus_io_probe
      - source_labels:
        - __address__
        target_label: __param_target
      - replacement: blackbox-prometheus-blackbox-exporter.kube-prometheus-stack.svc:9115  # Blackbox hostname:port
        target_label: __address__
      - source_labels:
        - __param_target
        target_label: instance
      - action: labelmap
        regex: __meta_kubernetes_service_label_(.+)
      - source_labels:
        - __meta_kubernetes_namespace
        target_label: kubernetes_namespace
      - source_labels:
        - __meta_kubernetes_service_name
        target_label: kubernetes_name
%{ endif }

%{ if var.kps_prom_scrape_pagespeed }
    - job_name: pagespeed_exporter_probe
      metrics_path: '/probe'  
      scrape_interval: 300s
      scrape_timeout: 300s
      relabel_configs:
        - source_labels: [__address__]        
          target_label: __param_target
        - source_labels: [__param_target]
          target_label: instance        
        - target_label: __address__     
          replacement: "pagespeed-exporter.pagespeed.svc:9271"
      static_configs:
        - targets:
            - 'https://www.myorg'
            - 'https://www.myorg/fr/maroc'    
            - 'https://www.myorg/auto/neuf/'
            - 'https://immoneuf.myorg/fr/'
%{ endif }
          

grafana:
  enabled: true
  namespaceOverride: ${kubernetes_namespace.kube-prometheus-stack.metadata[0].name}
  deploymentStrategy:
    type: Recreate
  image:
    tag: 10.2.0
  serviceMonitor:
    labels:
      release: ${local.kps_service_monitor_selector_label_release}
  defaultDashboardsEnabled: true
  adminPassword: admin
  podAnnotations:
    "cluster-autoscaler.kubernetes.io/safe-to-evict": "true"
%{ if var.platform == "aws" }
  hostAliases:
    - ip: "10.3.0.109"
      hostnames:
        - "vmselect-vmcluster.victoria-operator.applications.internal.galaxykube.com"
%{ endif }
  sidecar:
    dashboards:
      searchNamespace: "ALL"
      folderAnnotation: "sidecar.grafana.com/dashboard-folder"
      resource: configmap
      label: grafana_dashboard
      labelValue: '1'
      provider:
        foldersFromFilesStructure: true
      annotations:
        "sidecar.grafana.com/dashboard-folder": "${local.repo}-KPS"
    datasources:
      enabled: true
      searchNamespace: "ALL"
      resource: configmap
      label: grafana_datasource
      labelValue: '1'
      defaultDatasourceEnabled: false

  ingress:
    enabled: ${var.kps_grafana_ingress_enabled}
    annotations: 
      kubernetes.io/ingress.class                             : "nginx"
      cert-manager.io/cluster-issuer                          : "letsencrypt"
      nginx.ingress.kubernetes.io/auth-method                 : "GET"
      nginx-annotations-injector.galaxy.kubernetes.io/authelia : "yes"
    hosts: 
      - "${var.kps_grafana_host}"
    tls:
      - secretName: grafana-tls
        hosts:
        - ${var.kps_grafana_host}
  persistence:
    type: pvc
    enabled: true
    storageClassName: ssd-retain
    accessModes:
      - ReadWriteOnce
    size: 5Gi
  additionalDataSources:
    - name: Prometheus-mrissa
      access: proxy
      editable: true
      default: false
      type: prometheus
      url: http://kps-kube-prometheus-stack-prometheus.${kubernetes_namespace.kube-prometheus-stack.metadata[0].name}:${local.prometheus_service_port}
      manageAlerts: false
  plugins:
    - grafana-piechart-panel
    - grafana-clickhouse-datasource 4.0.2
  envFromSecret: "grafana-secrets" #this secret is managed manually
  adminPassword: "admin"
  grafana.ini:
    server:
      root_url: "https://${var.kps_grafana_host}"
    auth.generic_oauth:
      enabled: true
      name: Authelia
      icon: signin
      client_id: ${var.kps_grafana_authelia_oauth_client_id}
      #client_secret: will be pulled from env var
      scopes: openid profile email groups
      empty_scopes: false
      auth_url: https://authelia.myorg/api/oidc/authorization
      token_url: https://authelia.myorg/api/oidc/token
      api_url: https://authelia.myorg/api/oidc/userinfo
      use_pkce: true
      login_attribute_path: preferred_username
      name_attribute_path: name
      groups_attribute_path: groups #used only in grafana entreprise for team sync
      email_attribute_path: email
      role_attribute_path: contains(groups[*], 'galaxy_infra') && 'GrafanaAdmin' || contains(groups[*], 'galaxy_backend') && 'Editor' || contains(groups[*], 'galaxy_backend_intern') && 'Editor' || contains(groups[*], 'galaxy_data')  && 'Editor' || contains(groups[*], 'galaxy_frontend')  && 'Editor' || contains(groups[*], 'galaxy_qa')  && 'Editor' || 'Viewer'
      allow_assign_grafana_admin: true
      oauth_skip_org_role_update_sync: false
      skip_org_role_sync: false

    users:
      viewers_can_edit: false
      auto_assign_org_role: Viewer
    auth:
      disable_login_form: true
      oauth_allow_insecure_email_lookup: true
EOF


}



resource "helm_release" "kube-prometheus-stack" {
  name       = "kps"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "52.1.0"
  namespace  = kubernetes_namespace.kube-prometheus-stack.metadata[0].name

  # Default values
  # https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml
  # https://github.com/grafana/helm-charts/blob/main/charts/grafana/values.yaml
  values      = [data.template_file.kps_values.rendered]
  max_history = 5
}



















