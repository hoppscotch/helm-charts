{{/*
Admin service base URL based on deployment and access mode
*/}}
{{- define "hoppscotch.tests.adminServiceBaseUrl" -}}
  {{- if eq .Values.deploymentMode "aio" -}}
    {{- if .Values.hoppscotch.frontend.enableSubpathBasedAccess}}
      {{- printf "http://%s.%s.svc.%s:%d/admin" (include "hoppscotch.aio.serviceName" .) (include "hoppscotch.namespace" .) .Values.clusterDomain (.Values.aio.service.ports.http | int) -}}
    {{- else -}}
      {{- printf "http://%s.%s.svc.%s:%d" (include "hoppscotch.aio.serviceName" .) (include "hoppscotch.namespace" .) .Values.clusterDomain (.Values.aio.service.ports.admin | int) -}}
    {{- end -}}
  {{- else -}}
    {{- printf "http://%s.%s.svc.%s:%d" (include "hoppscotch.admin.serviceName" .) (include "hoppscotch.namespace" .) .Values.clusterDomain (.Values.admin.service.ports.http | int) -}}
  {{- end -}}
{{- end -}}

{{/*
Backend service base URL based on deployment and access mode
*/}}
{{- define "hoppscotch.tests.backendServiceBaseUrl" -}}
  {{- if eq .Values.deploymentMode "aio" -}}
    {{- if .Values.hoppscotch.frontend.enableSubpathBasedAccess}}
      {{- printf "http://%s.%s.svc.%s:%d/backend" (include "hoppscotch.aio.serviceName" .) (include "hoppscotch.namespace" .) .Values.clusterDomain (.Values.aio.service.ports.http | int) -}}
    {{- else -}}
      {{- printf "http://%s.%s.svc.%s:%d" (include "hoppscotch.aio.serviceName" .) (include "hoppscotch.namespace" .) .Values.clusterDomain (.Values.aio.service.ports.backend | int) -}}
    {{- end -}}
  {{- else -}}
    {{- printf "http://%s.%s.svc.%s:%d" (include "hoppscotch.backend.serviceName" .) (include "hoppscotch.namespace" .) .Values.clusterDomain (.Values.backend.service.ports.http | int) -}}
  {{- end -}}
{{- end -}}

{{/*
Frontend service base URL based on deployment and access mode
*/}}
{{- define "hoppscotch.tests.frontendServiceBaseUrl" -}}
  {{- if eq .Values.deploymentMode "aio" -}}
    {{- if .Values.hoppscotch.frontend.enableSubpathBasedAccess}}
      {{- printf "http://%s.%s.svc.%s:%d" (include "hoppscotch.aio.serviceName" .) (include "hoppscotch.namespace" .) .Values.clusterDomain (.Values.aio.service.ports.http | int) -}}
    {{- else -}}
      {{- printf "http://%s.%s.svc.%s:%d" (include "hoppscotch.aio.serviceName" .) (include "hoppscotch.namespace" .) .Values.clusterDomain (.Values.aio.service.ports.frontend | int) -}}
    {{- end -}}
  {{- else -}}
    {{- printf "http://%s.%s.svc.%s:%d" (include "hoppscotch.frontend.serviceName" .) (include "hoppscotch.namespace" .) .Values.clusterDomain (.Values.frontend.service.ports.http | int) -}}
  {{- end -}}
{{- end -}}

{{/*
Frontend web app server service base URL based on deployment and access mode
*/}}
{{- define "hoppscotch.tests.frontendWebAppServerServiceBaseUrl" -}}
  {{- if eq .Values.deploymentMode "aio" -}}
    {{- if .Values.hoppscotch.frontend.enableSubpathBasedAccess}}
      {{- printf "http://%s.%s.svc.%s:%d/desktop-app-server" (include "hoppscotch.aio.serviceName" .) (include "hoppscotch.namespace" .) .Values.clusterDomain (.Values.aio.service.ports.http | int) -}}
    {{- else -}}
      {{- printf "http://%s.%s.svc.%s:%d" (include "hoppscotch.aio.serviceName" .) (include "hoppscotch.namespace" .) .Values.clusterDomain (.Values.aio.service.ports.desktop | int) -}}
    {{- end -}}
  {{- else -}}
    {{- printf "http://%s.%s.svc.%s:%d" (include "hoppscotch.frontend.serviceName" .) (include "hoppscotch.namespace" .) .Values.clusterDomain (.Values.frontend.service.ports.http | int) -}}
  {{- end -}}
{{- end -}}
