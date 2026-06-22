resource "kubernetes_secret" "alertmanager_config" {
  metadata {
    name = "alertmanager-kps-kube-prometheus-stack-alertmanager"
    namespace  = kubernetes_namespace.kube-prometheus-stack.metadata[0].name
  }
  data = {
    "alertmanager.yaml" = <<YAML
global:
  resolve_timeout: 15m

${var.kps_alert_routes}

receivers:
- name: "null"
%{ if var.kps_alert_add_opsgenie }
- name: 'opsgenie'
  opsgenie_configs:
    - send_resolved: true
      api_key: xxxxxxxxxxxxxxxxxxxxxxxxx
      api_url: 'https://api.opsgenie.com/v2/alerts'
      responders:
        - type: "team"
          name: "galaxy_on-call_Prometheus"
%{ endif }

${var.kps_alert_slack_receivers}

mute_time_intervals:
  - name: "out-of-business-hours"
    time_intervals:
     - weekdays: ['Saturday','Sunday']
     - times:
       - start_time: '00:00'
         end_time: '08:00'
       - start_time: '17:30'
         end_time: '24:00'
  - name: "business-hours"
    time_intervals:
     - weekdays: ['Monday:Friday']
     - times:
       - start_time: '08:00'
         end_time: '17:30'
templates:
- /etc/alertmanager/config/*.tmpl
YAML

    "default.tmpl" = <<YAML
{{ define "slack.default.iconurl" }}https://avatars3.githubusercontent.com/u/3380462{{ end }}
{{ define "slack.default.icon_url" }}https://avatars3.githubusercontent.com/u/3380462{{ end }}
{{ define "slack.default.title" }}[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .CommonLabels.alertname }}{{ end }}
{{ define "slack.default.text" }}
{{ range .Alerts -}} *Alert:* {{ .Annotations.summary }}
  *Description:* {{ .Annotations.description }} 
  *Details:*
  {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
  {{ end }}
{{ end }}
{{- end }}
YAML
  }
}




