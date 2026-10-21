{{/*
Admin base URL based on deployment mode and ingress configuration
*/}}
{{- define "hoppscotch.admin.baseUrl" -}}
  {{- if eq .Values.deploymentMode "aio" -}}
    {{- $baseUrl := (include "hoppscotch.baseUrl" (dict "ingress" .Values.aio.ingress "route" .Values.aio.route)) -}}
    {{- eq (include "hoppscotch.subpathBasedAccess" .) "true" | ternary (printf "%s/admin" $baseUrl) $baseUrl -}}
  {{- else if eq .Values.deploymentMode "distributed" -}}
    {{- $frontendBaseUrl := "" -}}
    {{- if eq (include "hoppscotch.subpathBasedAccess" .) "true" -}}
      {{- $frontendBaseUrl = (include "hoppscotch.baseUrl" (dict "ingress" .Values.frontend.ingress "route" .Values.frontend.route)) -}}
    {{- end -}}
    {{- if ne $frontendBaseUrl "" -}}
      {{- printf "%s/admin" $frontendBaseUrl -}}
    {{- else -}}
      {{- include "hoppscotch.baseUrl" (dict "ingress" .Values.admin.ingress "route" .Values.admin.route) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Admin service name
*/}}
{{- define "hoppscotch.admin.serviceName" -}}
  {{- printf "%s-admin" (include "hoppscotch.fullname" .) -}}
{{- end -}}
