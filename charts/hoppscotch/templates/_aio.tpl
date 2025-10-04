{{/*
AIO service name
*/}}
{{- define "hoppscotch.aio.serviceName" -}}
  {{- include "hoppscotch.fullname" . -}}
{{- end -}}
