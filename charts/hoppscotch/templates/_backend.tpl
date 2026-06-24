{{/*
Generate backend base URL based on deployment mode and ingress configuration
*/}}
{{- define "hoppscotch.backend.baseUrl" -}}
  {{- if eq .Values.deploymentMode "aio" -}}
    {{- $baseUrl := (include "hoppscotch.ingressBaseUrl" .Values.aio.ingress) -}}
    {{- .Values.hoppscotch.frontend.enableSubpathBasedAccess | ternary (printf "%s/backend" $baseUrl) $baseUrl -}}
  {{- else if eq .Values.deploymentMode "distributed" -}}
    {{- include "hoppscotch.ingressBaseUrl" .Values.backend.ingress -}}
  {{- end -}}
{{- end -}}

{{/*
Backend image based on deployment mode. This named template is used by migrations and wait for migrations containers to
ensure the correct image is selected consistent with the deployment mode.
*/}}
{{- define "hoppscotch.backend.image" -}}
  {{- include "hoppscotch.image" (dict "component" ((eq .Values.deploymentMode "aio") | ternary .Values.aio .Values.backend) "context" .) -}}
{{- end -}}

{{/*
Backend image pull policy based on deployment mode. This named template is used by migrations and wait for migrations
containers to ensure the correct image is pulled consistent with the deployment mode.
*/}}
{{- define "hoppscotch.backend.imagePullPolicy" -}}
  {{- (eq .Values.deploymentMode "aio") | ternary .Values.aio.image.pullPolicy .Values.backend.image.pullPolicy -}}
{{- end -}}

{{/*
Generate readiness probe HTTP GET path
*/}}
{{- define "hoppscotch.backend.readinessProbePath" -}}
  {{- if eq .Values.deploymentMode "aio" -}}
    /backend/ping
  {{- else -}}
    /ping
  {{- end -}}
{{- end -}}

{{/*
Backend service name
*/}}
{{- define "hoppscotch.backend.serviceName" -}}
  {{- printf "%s-backend" (include "hoppscotch.fullname" .) -}}
{{- end -}}

{{/*
Generate whitelisted origins for the backend based on ingress configuration
*/}}
{{- define "hoppscotch.backend.whitelistedOrigins" -}}
  {{- if .Values.hoppscotch.backend.whitelistedOrigins -}}
    {{- .Values.hoppscotch.backend.whitelistedOrigins | join "," -}}
  {{- else -}}
    {{- $origins := list -}}
    {{- $frontendBaseUrl := urlParse (include "hoppscotch.frontend.baseUrl" .) -}}
    {{- if ne $frontendBaseUrl.host "" -}}
      {{- $origins = append $origins (printf "%s://%s" $frontendBaseUrl.scheme $frontendBaseUrl.host) -}}
      {{- $appHost := (regexReplaceAll "[.]" $frontendBaseUrl.host "_") -}}
      {{- $origins = append $origins (printf "app://%s" $appHost) -}}
      {{- $origins = append $origins (printf "http://app.%s" $appHost) -}}
    {{- end -}}
    {{- $backendBaseUrl := urlParse (include "hoppscotch.backend.baseUrl" .) -}}
    {{- if ne $backendBaseUrl.host "" -}}
      {{- $backendOrigin := (printf "%s://%s" $backendBaseUrl.scheme $backendBaseUrl.host) -}}
      {{- if not (has $backendOrigin $origins) -}}
        {{- $origins = append $origins $backendOrigin -}}
      {{- end -}}
    {{- end -}}
    {{- $adminBaseUrl := urlParse (include "hoppscotch.admin.baseUrl" .) -}}
    {{- if ne $adminBaseUrl.host "" -}}
      {{- $adminOrigin := (printf "%s://%s" $adminBaseUrl.scheme $adminBaseUrl.host) -}}
      {{- if not (has $adminOrigin $origins) -}}
        {{- $origins = append $origins $adminOrigin -}}
      {{- end -}}
    {{- end -}}
    {{- $origins | join "," -}}
  {{- end -}}
{{- end }}
