{{/*
Admin base URL based on deployment mode and ingress configuration
*/}}
{{- define "hoppscotch.admin.baseUrl" -}}
  {{- if eq .Values.deploymentMode "aio" -}}
    {{- $baseUrl := (include "hoppscotch.ingressBaseUrl" .Values.aio.ingress) -}}
    {{- .Values.hoppscotch.frontend.enableSubpathBasedAccess | ternary (printf "%s/admin" $baseUrl) $baseUrl -}}
  {{- else if eq .Values.deploymentMode "distributed" -}}
    {{- include "hoppscotch.ingressBaseUrl" .Values.admin.ingress -}}
  {{- end -}}
{{- end -}}

{{/*
Admin service name
*/}}
{{- define "hoppscotch.admin.serviceName" -}}
  {{- printf "%s-admin" (include "hoppscotch.fullname" .) -}}
{{- end -}}
