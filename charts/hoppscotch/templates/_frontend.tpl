{{/*
Frontend base URL based on deployment mode and ingress configuration
*/}}
{{- define "hoppscotch.frontend.baseUrl" -}}
  {{- if .Values.hoppscotch.frontend.baseUrl -}}
    {{- .Values.hoppscotch.frontend.baseUrl -}}
  {{- else -}}
    {{- if eq .Values.deploymentMode "aio" -}}
      {{- include "hoppscotch.ingressBaseUrl" .Values.aio.ingress -}}
    {{- else if eq .Values.deploymentMode "distributed" -}}
      {{- include "hoppscotch.ingressBaseUrl" .Values.frontend.ingress -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Frontend admin URL based on deployment mode and ingress configuration
*/}}
{{- define "hoppscotch.frontend.adminUrl" -}}
  {{- if .Values.hoppscotch.frontend.adminUrl -}}
    {{- .Values.hoppscotch.frontend.adminUrl -}}
  {{- else -}}
    {{- include "hoppscotch.admin.baseUrl" . -}}
  {{- end -}}
{{- end -}}

{{/*
Frontend backend API URL based on deployment mode and ingress configuration
*/}}
{{- define "hoppscotch.frontend.backendApiUrl" -}}
  {{- if .Values.hoppscotch.frontend.backendApiUrl -}}
    {{- .Values.hoppscotch.frontend.backendApiUrl -}}
  {{- else -}}
    {{- $url := (include "hoppscotch.backend.baseUrl" .) -}}
    {{- if ne $url "" -}}
      {{- printf "%s/v1" $url -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Frontend backend GraphQL URL based on deployment mode and ingress configuration
*/}}
{{- define "hoppscotch.frontend.backendGqlUrl" -}}
  {{- if .Values.hoppscotch.frontend.backendGqlUrl -}}
    {{- .Values.hoppscotch.frontend.backendGqlUrl -}}
  {{- else -}}
    {{- $url := (include "hoppscotch.backend.baseUrl" .) -}}
    {{- if ne $url "" -}}
      {{- printf "%s/graphql" $url -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Frontend backend WebSocket URL based on deployment mode and ingress configuration
*/}}
{{- define "hoppscotch.frontend.backendWsUrl" -}}
  {{- if .Values.hoppscotch.frontend.backendWsUrl -}}
    {{- .Values.hoppscotch.frontend.backendWsUrl -}}
  {{- else -}}
    {{- include "hoppscotch.frontend.backendGqlUrl" . | replace "http://" "ws://" | replace "https://" "wss://" -}}
  {{- end -}}
{{- end -}}

{{/*
Frontend service name
*/}}
{{- define "hoppscotch.frontend.serviceName" -}}
  {{- printf "%s-frontend" (include "hoppscotch.fullname" .) -}}
{{- end -}}

{{/*
Frontend backend WebSocket URL based on deployment mode and ingress configuration
*/}}
{{- define "hoppscotch.frontend.shortcodeBaseUrl" -}}
  {{- if .Values.hoppscotch.frontend.shortcodeBaseUrl -}}
    {{- .Values.hoppscotch.frontend.shortcodeBaseUrl -}}
  {{- else -}}
    {{- include "hoppscotch.frontend.baseUrl" . -}}
  {{- end -}}
{{- end -}}
