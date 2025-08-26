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
Generate auth callback URL based on deployment mode and ingress configuration
Usage: {{ include "hoppscotch.backend.authCallbackUrl" (dict "provider" "github" "context" .) }}
*/}}
{{- define "hoppscotch.backend.authCallbackUrl" -}}
  {{- $baseUrl := (include "hoppscotch.backend.baseUrl" .context) -}}
  {{- if ne $baseUrl "" -}}
    {{- printf "%s/v1/auth/%s/callback" $baseUrl .provider -}}
  {{- end -}}
{{- end -}}

{{/*
Generate GitHub auth callback URL based on on deployment mode and ingress configuration
*/}}
{{- define "hoppscotch.backend.githubCallbackUrl" -}}
  {{- if .Values.hoppscotch.backend.auth.github.callbackUrl -}}
    {{- .Values.hoppscotch.backend.auth.github.callbackUrl -}}
  {{- else -}}
    {{- include "hoppscotch.backend.authCallbackUrl" (dict "provider" "github" "context" .) -}}
  {{- end -}}
{{- end }}

{{/*
Generate Google auth callback URL based on deployment mode and ingress configuration
*/}}
{{- define "hoppscotch.backend.googleCallbackUrl" -}}
  {{- if .Values.hoppscotch.backend.auth.google.callbackUrl -}}
    {{- .Values.hoppscotch.backend.auth.google.callbackUrl -}}
  {{- else -}}
    {{- include "hoppscotch.backend.authCallbackUrl" (dict "provider" "google" "context" .) -}}
  {{- end -}}
{{- end }}

{{/*
Backend image based on deployment mode
*/}}
{{- define "hoppscotch.backend.image" -}}
  {{- include "hoppscotch.image" (dict "component" ((eq .Values.deploymentMode "aio") | ternary .Values.aio .Values.backend) "context" .) -}}
{{- end -}}

{{/*
Backend image pull policy based on deployment mode
*/}}
{{- define "hoppscotch.backend.imagePullPolicy" -}}
  {{- (eq .Values.deploymentMode "aio") | ternary .Values.aio.image.pullPolicy .Values.backend.image.pullPolicy -}}
{{- end -}}

{{/*
Generate Microsoft auth callback URL based on deployment mode and ingress configuration
*/}}
{{- define "hoppscotch.backend.microsoftCallbackUrl" -}}
  {{- if .Values.hoppscotch.backend.auth.microsoft.callbackUrl -}}
    {{- .Values.hoppscotch.backend.auth.microsoft.callbackUrl -}}
  {{- else -}}
    {{- include "hoppscotch.backend.authCallbackUrl" (dict "provider" "microsoft" "context" .) -}}
  {{- end -}}
{{- end }}

{{/*
Generate OIDC auth callback URL based on deployment mode and ingress configuration
*/}}
{{- define "hoppscotch.backend.oidcCallbackUrl" -}}
  {{- if .Values.hoppscotch.backend.auth.oidc.callbackUrl -}}
    {{- .Values.hoppscotch.backend.auth.oidc.callbackUrl -}}
  {{- else -}}
    {{- include "hoppscotch.backend.authCallbackUrl" (dict "provider" "oidc" "context" .) -}}
  {{- end -}}
{{- end }}

{{/*
Generate SAML auth callback URL based on deployment mode and ingress configuration
*/}}
{{- define "hoppscotch.backend.samlCallbackUrl" -}}
  {{- if .Values.hoppscotch.backend.auth.saml.callbackUrl -}}
    {{- .Values.hoppscotch.backend.auth.saml.callbackUrl -}}
  {{- else -}}
    {{- include "hoppscotch.backend.authCallbackUrl" (dict "provider" "saml" "context" .) -}}
  {{- end -}}
{{- end }}

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
Generate the redirect URL for the backend based on deployment mode and ingress configuration
*/}}
{{- define "hoppscotch.backend.redirectUrl" -}}
  {{- if .Values.hoppscotch.backend.redirectUrl -}}
    {{- .Values.hoppscotch.backend.redirectUrl -}}
  {{- else -}}
    {{- include "hoppscotch.frontend.baseUrl" . -}}
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
