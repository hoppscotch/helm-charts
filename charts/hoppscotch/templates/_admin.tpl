{{/*
Admin base URL based on deployment mode and ingress configuration
*/}}
{{- define "hoppscotch.admin.baseUrl" -}}
  {{- if eq .Values.deploymentMode "aio" -}}
    {{- $baseUrl := (include "hoppscotch.ingressBaseUrl" .Values.aio.ingress) -}}
    {{- if not $baseUrl -}}{{- $baseUrl = (include "hoppscotch.httpRouteBaseUrl" .Values.aio.httpRoute) -}}{{- end -}}
    {{- .Values.hoppscotch.frontend.enableSubpathBasedAccess | ternary (printf "%s/admin" $baseUrl) $baseUrl -}}
  {{- else if eq .Values.deploymentMode "distributed" -}}
    {{- $url := (include "hoppscotch.ingressBaseUrl" .Values.admin.ingress) -}}
    {{- if not $url -}}{{- $url = (include "hoppscotch.httpRouteBaseUrl" .Values.admin.httpRoute) -}}{{- end -}}
    {{- $url -}}
  {{- end -}}
{{- end -}}

{{/*
Admin service name
*/}}
{{- define "hoppscotch.admin.serviceName" -}}
  {{- printf "%s-admin" (include "hoppscotch.fullname" .) -}}
{{- end -}}
