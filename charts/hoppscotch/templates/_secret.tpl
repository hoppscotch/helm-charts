{{/*
Return the secret name to use for environment variables.
*/}}
{{- define "hoppscotch.secretName" -}}
  {{- if .Values.existingSecret -}}
    {{- .Values.existingSecret -}}
  {{- else -}}
    {{- include "hoppscotch.fullname" . -}}
  {{- end -}}
{{- end -}}


{{/*
Return the ClickHouse host based on the ClickHouse chart or external ClickHouse settings
*/}}
{{- define "hoppscotch.secret.clickhouseHost" -}}
  {{- $defaultPort := 8123 -}}
  {{- if .Values.clickhouse.enabled -}}
    {{- $namespace := include "hoppscotch.namespace" . -}}
    {{- printf "%s-clickhouse.%s.svc.%s:%d" .Release.Name $namespace .Values.clusterDomain $defaultPort -}}
  {{- else if .Values.externalClickhouse.host -}}
    {{- $port := .Values.externalClickhouse.port | default $defaultPort | int -}}
    {{- printf "%s:%d" .Values.externalClickhouse.host $port -}}
  {{- end -}}
{{- end -}}

{{/*
Return the ClickHouse password based on the ClickHouse chart or external ClickHouse settings
*/}}
{{- define "hoppscotch.secret.clickhousePassword" -}}
  {{- $namespace := include "hoppscotch.namespace" . -}}
  {{- if .Values.clickhouse.enabled -}}
    {{- $password := .Values.clickhouse.auth.password -}}
    {{- if not $password -}}
      {{- $secretName := .Values.clickhouse.auth.existingSecret | default (printf "%s-clickhouse" .Release.Name) -}}
      {{- $secretKey := .Values.clickhouse.auth.existingSecretKey | default "admin-password" -}}
      {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" $secretName "namespace" $namespace "key" $secretKey) -}}
    {{- end -}}
    {{- $password -}}
  {{- else -}}
    {{- $password := .Values.externalClickhouse.password -}}
    {{- if and (not $password) .Values.externalClickhouse.existingSecret -}}
      {{- $secretKey := .Values.externalClickhouse.existingSecretPasswordKey | default "password" -}}
      {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" .Values.externalClickhouse.existingSecret "namespace" $namespace "key" $secretKey) -}}
    {{- end -}}
  {{- $password -}}
  {{- end -}}
{{- end -}}

{{/*
Return the ClickHouse user based on the ClickHouse chart or external ClickHouse settings
*/}}
{{- define "hoppscotch.secret.clickhouseUser" -}}
  {{- if .Values.clickhouse.enabled -}}
    {{- .Values.clickhouse.auth.username -}}
  {{- else -}}
    {{- .Values.externalClickhouse.user -}}
  {{- end -}}
{{- end -}}


{{/*
Return the database URL based on the PostgreSQL chart or external database settings.
*/}}
{{- define "hoppscotch.secret.databaseUrl" -}}
  {{- $defaultPort := 5432 -}}
  {{- $defaultSecretKey := "password" -}}
  {{- $namespace := include "hoppscotch.namespace" . -}}
  {{- if .Values.postgresql.enabled -}}
    {{- $host := printf "%s-postgresql.%s.svc.%s" .Release.Name $namespace .Values.clusterDomain -}}
    {{- $user := .Values.postgresql.auth.username -}}
    {{- $database := .Values.postgresql.auth.database -}}
    {{- $password := .Values.postgresql.auth.password -}}
    {{- if not $password -}}
      {{- if .Values.postgresql.auth.existingSecret -}}
        {{- $secretKey := .Values.postgresql.auth.secretKeys.userPasswordKey | default $defaultSecretKey -}}
        {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" .Values.postgresql.auth.existingSecret "namespace" $namespace "key" $secretKey) -}}
      {{- else -}}
        {{- $secretName := printf "%s-postgresql" .Release.Name -}}
        {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" $secretName "namespace" $namespace "key" $defaultSecretKey) -}}
      {{- end -}}
    {{- end -}}
    {{- include "hoppscotch.secret.formatPostgresUrl" (dict "host" $host "port" $defaultPort "user" $user "password" $password "database" $database) -}}
  {{- else if .Values.externalDatabase.sqlConnection -}}
    {{- .Values.externalDatabase.sqlConnection -}}
  {{- else if and .Values.externalDatabase.existingSecret .Values.externalDatabase.existingSecretSqlConnectionKey -}}
    {{- include "hoppscotch.secret.lookupValue" (dict "name" .Values.externalDatabase.existingSecret "namespace" $namespace "key" .Values.externalDatabase.existingSecretSqlConnectionKey) -}}
  {{- else -}}
    {{- $host := .Values.externalDatabase.host -}}
    {{- $port := .Values.externalDatabase.port | default $defaultPort | int -}}
    {{- $user := .Values.externalDatabase.user -}}
    {{- $database := .Values.externalDatabase.database -}}
    {{- $password := .Values.externalDatabase.password -}}
    {{- if and (not $password) .Values.externalDatabase.existingSecret -}}
      {{- $secretKey := .Values.externalDatabase.existingSecretPasswordKey | default $defaultSecretKey -}}
      {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" .Values.externalDatabase.existingSecret "namespace" $namespace "key" $secretKey) -}}
    {{- end -}}
    {{- include "hoppscotch.secret.formatPostgresUrl" (dict "host" $host "port" $port "user" $user "password" $password "database" $database) -}}
  {{- end -}}
{{- end -}}

{{/*
Generate a secure data encryption key that persists across upgrades
*/}}
{{- define "hoppscotch.secret.dataEncryptionKey" -}}
  {{- $secretName := include "hoppscotch.fullname" . -}}
  {{- $existingSecret := include "hoppscotch.secret.lookupValue" (dict "namespace" .Release.Namespace "name" $secretName "key" "DATA_ENCRYPTION_KEY") -}}
  {{- if $existingSecret -}}
    {{- $existingSecret -}}
  {{- else if .Values.hoppscotch.backend.dataEncryptionKey -}}
    {{- .Values.hoppscotch.backend.dataEncryptionKey -}}
  {{- else -}}
    {{- randAlphaNum 32 -}}
  {{- end -}}
{{- end -}}

{{/*
Format a database URL for use in configuration files.
Usage: {{- include "hoppscotch.secret.formatPostgresUrl" (dict "host" $host "port" $port "user" $user "password" $password "database" $database "params" $params) -}}
*/}}
{{- define "hoppscotch.secret.formatPostgresUrl" -}}
  {{- $userspec := "" -}}
  {{- $hostspec := .host -}}
  {{- $dbname := "" -}}
  {{- $paramspec := "" -}}
  {{- if and .user .password -}}
    {{- $userspec = printf "%s:%s@" .user .password -}}
  {{- else if .user -}}
    {{- $userspec = printf "%s@" .user -}}
  {{- end -}}
  {{- if .port -}}
    {{- $hostspec = printf "%s:%d" .host .port -}}
  {{- end -}}
  {{- if .database -}}
    {{- $dbname = printf "/%s" .database -}}
  {{- end -}}
  {{- if .params -}}
    {{- $paramspec = printf "?%s" .params -}}
  {{- end -}}
  {{- printf "postgres://%s%s%s%s" $userspec $hostspec $dbname $paramspec -}}
{{- end -}}

{{/*
Format a Redis URL for use in configuration files.
Usage: {{- include "hoppscotch.secret.formatRedisUrl" (dict "host" $host "port" $port "password" $password) -}}
*/}}
{{- define "hoppscotch.secret.formatRedisUrl" -}}
  {{- $authspec := "" -}}
  {{- $hostspec := .host -}}
  {{- if .password -}}
    {{- $authspec = printf ":%s@" .password -}}
  {{- end -}}
  {{- if .port -}}
    {{- $hostspec = printf "%s:%d" .host .port -}}
  {{- end -}}
  {{- printf "redis://%s%s" $authspec $hostspec -}}
{{- end -}}

{{/*
Generate a secure JWT secret that persists across upgrades
*/}}
{{- define "hoppscotch.secret.jwtSecret" -}}
  {{- $secretName := include "hoppscotch.fullname" . -}}
  {{- $existingSecret := include "hoppscotch.secret.lookupValue" (dict "namespace" .Release.Namespace "name" $secretName "key" "JWT_SECRET") -}}
  {{- if $existingSecret -}}
    {{- $existingSecret -}}
  {{- else if .Values.hoppscotch.backend.authToken.jwtSecret -}}
    {{- .Values.hoppscotch.backend.authToken.jwtSecret -}}
  {{- else -}}
    {{- randAlphaNum 64 -}}
  {{- end -}}
{{- end -}}

{{/*
Return the value of a secret key. An empty string is returned if the key is not found.
Usage: {{- include "hoppscotch.secret.lookupValue" (dict "name" "my-secret" "namespace" "my-namespace" "key" "my-key") -}}
*/}}
{{- define "hoppscotch.secret.lookupValue" -}}
  {{- $secret := (lookup "v1" "Secret" .namespace .name) -}}
  {{- if and $secret $secret.data (hasKey $secret.data .key) -}}
    {{- index $secret.data .key | b64dec | trimAll "\n" -}}
  {{- end -}}
{{- end }}


{{/*
Return the Redis URL based on the Redis chart or external Redis settings
*/}}
{{- define "hoppscotch.secret.redisUrl" -}}
  {{- $defaultPort := 6379 -}}
  {{- $defaultSecretKey := "redis-password" -}}
  {{- $namespace := include "hoppscotch.namespace" . -}}
  {{- if .Values.redis.enabled -}}
    {{- $host := printf "%s-redis-master.%s.svc.%s" .Release.Name $namespace .Values.clusterDomain -}}
    {{- $password := .Values.redis.auth.password -}}
    {{- if not $password -}}
      {{- if .Values.redis.auth.existingSecret -}}
        {{- $secretKey := .Values.redis.auth.existingSecretPasswordKey | default $defaultSecretKey -}}
        {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" .Values.redis.auth.existingSecret "namespace" $namespace "key" $secretKey) -}}
      {{- else -}}
        {{- $secretName := printf "%s-redis" .Release.Name -}}
        {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" $secretName "namespace" $namespace "key" $defaultSecretKey) -}}
      {{- end -}}
    {{- end -}}
    {{- include "hoppscotch.secret.formatRedisUrl" (dict "host" $host "port" $defaultPort "password" $password) -}}
  {{- else -}}
    {{- $host := .Values.externalRedis.host -}}
    {{- $port := .Values.externalRedis.port | default $defaultPort | int -}}
    {{- $password := .Values.externalRedis.password -}}
    {{- if and (not $password) .Values.externalRedis.existingSecret -}}
      {{- $secretKey := .Values.externalRedis.existingSecretPasswordKey | default $defaultSecretKey -}}
      {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" .Values.externalRedis.existingSecret "namespace" $namespace "key" $secretKey) -}}
    {{- end -}}
    {{- include "hoppscotch.secret.formatRedisUrl" (dict "host" $host "port" $port "password" $password) -}}
  {{- end -}}
{{- end -}}

{{/*
Generate a secure session secret that persists across upgrades
*/}}
{{- define "hoppscotch.secret.sessionSecret" -}}
  {{- $secretName := include "hoppscotch.fullname" . -}}
  {{- $existingSecret := include "hoppscotch.secret.lookupValue" (dict "namespace" .Release.Namespace "name" $secretName "key" "SESSION_SECRET") -}}
  {{- if $existingSecret -}}
    {{- $existingSecret -}}
  {{- else if .Values.hoppscotch.backend.authToken.sessionSecret -}}
    {{- .Values.hoppscotch.backend.authToken.sessionSecret -}}
  {{- else -}}
    {{- randAlphaNum 64 -}}
  {{- end -}}
{{- end -}}
