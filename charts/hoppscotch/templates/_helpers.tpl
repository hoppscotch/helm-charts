{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hoppscotch.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified name that includes the release name and chart name.
*/}}
{{- define "hoppscotch.fullname" -}}
  {{- if .Values.fullnameOverride -}}
    {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- $name := default .Chart.Name .Values.nameOverride -}}
    {{- $releaseName := regexReplaceAll "(-?[^a-z\\d\\-])+-?" (lower .Release.Name) "-" -}}
    {{- if contains $name $releaseName -}}
      {{- $releaseName | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
      {{- printf "%s-%s" $releaseName $name | trunc 63 | trimSuffix "-" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Checks if annotations include cert-manager requests
Usage: {{ include "hoppscotch.hasCertManagerRequest" ( dict "annotations" .Values.aio.ingress.annotations ) }}
*/}}
{{- define "hoppscotch.hasCertManagerRequest" -}}
  {{ if or (hasKey .annotations "cert-manager.io/cluster-issuer") (hasKey .annotations "cert-manager.io/issuer") (hasKey .annotations "kubernetes.io/tls-acme") }}
    {{- true -}}
  {{- end -}}
{{- end -}}

{{/*
Return the Hoppscotch container image name with tag. Chart app version is used as a default tag if not specified. This
helper is intended to be used for Hoppscotch components only. For all other components use `hoppscotch.images.image`.
Usage: {{ include "hoppscotch.image" (dict "component" .Values.frontend "context" .) }}
*/}}
{{- define "hoppscotch.image" -}}
  {{- $componentWithTag := .component -}}
  {{- if not .component.image.tag -}}
    {{- $componentWithTag = mergeOverwrite (deepCopy .component) (dict "image" (dict "tag" .context.Chart.AppVersion)) -}}
  {{- end -}}
  {{- include "hoppscotch.images.image" (dict "component" $componentWithTag "context" .context) -}}
{{- end -}}

{{/*
Return the container image name. The global image registry is used if specified. If no tag is provided, only the image
name is returned without a tag defaulting to `latest`.
Usage: {{ include "hoppscotch.images.image" (dict "component" .Values.frontend "context" .) }}
*/}}
{{- define "hoppscotch.images.image" -}}
  {{- $registry := .component.image.registry | default .context.Values.global.imageRegistry -}}
  {{- $repository := .component.image.repository -}}
  {{- $tag := .component.image.tag -}}
  {{- if $registry -}}
    {{- if $tag -}}
      {{- printf "%s/%s:%s" $registry $repository $tag -}}
    {{- else -}}
      {{- printf "%s/%s" $registry $repository -}}
    {{- end -}}
  {{- else -}}
    {{- if $tag -}}
      {{- printf "%s:%s" $repository $tag -}}
    {{- else -}}
      {{- $repository -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Generate base URL from ingress resource
Usage: {{ include "hoppscotch.ingressBaseUrl" .Values.aio.ingress }}
*/}}
{{- define "hoppscotch.ingressBaseUrl" -}}
  {{- .enabled | ternary (urlJoin (dict "scheme" (.tls | ternary "https" "http") "host" .hostname "path" (.path | trimSuffix "/"))) "" -}}
{{- end -}}

{{/*
Return common labels for all resources.
*/}}
{{- define "hoppscotch.labels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ include "hoppscotch.name" . }}
app.kubernetes.io/part-of: {{ template "hoppscotch.name" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
helm.sh/chart: {{ include "hoppscotch.chart" . }}
{{- if .Values.commonLabels}}
{{ toYaml .Values.commonLabels }}
{{- end -}}
{{- end -}}

{{/*
Allow the chart name to be overridden.
*/}}
{{- define "hoppscotch.name" -}}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Allow the release namespace to be overridden.
*/}}
{{- define "hoppscotch.namespace" -}}
  {{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the appropriate resource configuration based on resources preset or custom resources
Usage: {{ include "hoppscotch.resources" (dict "preset" .Values.aio.resourcesPreset "resources" .Values.aio.resources) }}
*/}}
{{- define "hoppscotch.resources" -}}
  {{- $preset := .preset -}}
  {{- $resources := .resources -}}
  {{- if $resources -}}
    {{- toYaml $resources -}}
  {{- else if $preset -}}
    {{- include "hoppscotch.resourcesPreset" (dict "preset" $preset) -}}
  {{- end -}}
{{- end -}}

{{/*
Return predefined resource configurations based on preset name
Usage: {{ include "hoppscotch.resourcesPreset" (dict "preset" .Values.aio.resourcesPreset) }}
*/}}
{{- define "hoppscotch.resourcesPreset" -}}
{{- $preset := .preset -}}
{{- if eq $preset "nano" -}}
limits:
  cpu: 150m
  ephemeral-storage: 2Gi
  memory: 192Mi
requests:
  cpu: 100m
  ephemeral-storage: 50Mi
  memory: 128Mi
{{- else if eq $preset "micro" -}}
limits:
  cpu: 250m
  ephemeral-storage: 2Gi
  memory: 256Mi
requests:
  cpu: 125m
  ephemeral-storage: 50Mi
  memory: 192Mi
{{- else if eq $preset "small" -}}
limits:
  cpu: 500m
  ephemeral-storage: 2Gi
  memory: 512Mi
requests:
  cpu: 250m
  ephemeral-storage: 50Mi
  memory: 256Mi
{{- else if eq $preset "medium" -}}
limits:
  cpu: 1000m
  ephemeral-storage: 2Gi
  memory: 1Gi
requests:
  cpu: 500m
  ephemeral-storage: 50Mi
  memory: 512Mi
{{- else if eq $preset "large" -}}
limits:
  cpu: 2000m
  ephemeral-storage: 4Gi
  memory: 2Gi
requests:
  cpu: 1000m
  ephemeral-storage: 50Mi
  memory: 1Gi
{{- else if eq $preset "xlarge" -}}
limits:
  cpu: 4000m
  ephemeral-storage: 8Gi
  memory: 4Gi
requests:
  cpu: 2000m
  ephemeral-storage: 50Mi
  memory: 2Gi
{{- else if eq $preset "2xlarge" -}}
limits:
  cpu: 8000m
  ephemeral-storage: 16Gi
  memory: 8Gi
requests:
  cpu: 4000m
  ephemeral-storage: 50Mi
  memory: 4Gi
{{- else -}}
limits:
  cpu: 150m
  ephemeral-storage: 2Gi
  memory: 192Mi
requests:
  cpu: 100m
  ephemeral-storage: 50Mi
  memory: 128Mi
{{- end -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "hoppscotch.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/name: {{ include "hoppscotch.name" . }}
{{- end -}}

{{/*
Return the service account name to use.
*/}}
{{- define "hoppscotch.serviceAccountName" -}}
  {{- if .Values.serviceAccount.create -}}
    {{- default (include "hoppscotch.fullname" .) .Values.serviceAccount.name -}}
  {{- else -}}
    {{- default "default" .Values.serviceAccount.name -}}
  {{- end -}}
{{- end -}}
