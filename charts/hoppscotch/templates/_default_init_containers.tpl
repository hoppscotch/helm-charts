{{/*
Default init container that waits for the database to be ready.
*/}}
{{- define "hoppscotch.defaultInitContainers.waitForDatabase" -}}
- name: wait-for-db
  image: {{ include "hoppscotch.images.image" (dict "component" .Values.defaultInitContainers.waitForDatabase "context" .) }}
  imagePullPolicy: {{ .Values.defaultInitContainers.waitForDatabase.image.pullPolicy }}
  command:
    - /bin/sh
  args:
    - -c
    - until pg_isready -d $DATABASE_URL; do sleep 3; done
  {{- if .Values.defaultInitContainers.waitForDatabase.extraEnvVars }}
  env:
    {{- toYaml .Values.defaultInitContainers.waitForDatabase.extraEnvVars | nindent 12 }}
  {{- end }}
  envFrom:
    - secretRef:
        name: {{ include "hoppscotch.secretName" . }}
    {{- if .Values.migrations.extraEnvVarsCM }}
    - configMapRef:
        name: {{ .Values.defaultInitContainers.waitForDatabase.extraEnvVarsCM }}
    {{- end }}
    {{- if .Values.defaultInitContainers.waitForDatabase.extraEnvVarsSecret }}
    - secretRef:
        name: {{ .Values.defaultInitContainers.waitForDatabase.extraEnvVarsSecret }}
    {{- end }}
{{- end -}}

{{/*
Default init container that waits for the database migrations to be complete.
*/}}
{{- define "hoppscotch.defaultInitContainers.waitForMigrations" -}}
- name: wait-for-migrations
  image: {{ include "hoppscotch.backend.image" . }}
  imagePullPolicy: {{ include "hoppscotch.backend.imagePullPolicy" . }}
  command:
    - /bin/sh
  args:
    - -c
    - until ./node_modules/.bin/prisma migrate status; do sleep 2; done
  {{- if .Values.defaultInitContainers.waitForMigrations.extraEnvVars }}
  env:
    {{- toYaml .Values.defaultInitContainers.waitForMigrations.extraEnvVars | nindent 12 }}
  {{- end }}
  envFrom:
    - secretRef:
        name: {{ include "hoppscotch.secretName" . }}
    {{- if .Values.migrations.extraEnvVarsCM }}
    - configMapRef:
        name: {{ .Values.defaultInitContainers.waitForMigrations.extraEnvVarsCM }}
    {{- end }}
    {{- if .Values.defaultInitContainers.waitForMigrations.extraEnvVarsSecret }}
    - secretRef:
        name: {{ .Values.defaultInitContainers.waitForMigrations.extraEnvVarsSecret }}
    {{- end }}
{{- end -}}
