{{/*
Expand the name of the chart.
*/}}
{{- define "laravel-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "laravel-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "laravel-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "laravel-app.labels" -}}
helm.sh/chart: {{ include "laravel-app.chart" . }}
{{ include "laravel-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "laravel-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "laravel-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "laravel-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "laravel-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the configmap
*/}}
{{- define "laravel-app.configMapName" -}}
{{- printf "%s-config" (include "laravel-app.fullname" .) }}
{{- end }}

{{/*
Create the name of the secret
*/}}
{{- define "laravel-app.secretName" -}}
{{- printf "%s-secret" (include "laravel-app.fullname" .) }}
{{- end }}

{{/*
Create the name of the PVC
*/}}
{{- define "laravel-app.pvcName" -}}
{{- printf "%s-storage" (include "laravel-app.fullname" .) }}
{{- end }}

{{/*
Database host helper
*/}}
{{- define "laravel-app.databaseHost" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" .Release.Name }}
{{- else if .Values.externalServices.postgresql.host }}
{{- .Values.externalServices.postgresql.host }}
{{- else }}
{{- .Values.env.DB_HOST }}
{{- end }}
{{- end }}

{{/*
Database password helper
*/}}
{{- define "laravel-app.databasePassword" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.password }}
{{- else if .Values.externalServices.postgresql.password }}
{{- .Values.externalServices.postgresql.password }}
{{- else }}
{{- .Values.env.DB_PASSWORD }}
{{- end }}
{{- end }}

{{/*
Redis host helper
*/}}
{{- define "laravel-app.redisHost" -}}
{{- if .Values.redis.enabled }}
{{- printf "%s-redis-master" .Release.Name }}
{{- else if .Values.externalServices.redis.host }}
{{- .Values.externalServices.redis.host }}
{{- else }}
{{- .Values.env.REDIS_HOST }}
{{- end }}
{{- end }}

{{/*
Redis password helper
*/}}
{{- define "laravel-app.redisPassword" -}}
{{- if .Values.redis.enabled }}
{{- .Values.redis.auth.password }}
{{- else if .Values.externalServices.redis.password }}
{{- .Values.externalServices.redis.password }}
{{- else }}
{{- .Values.env.REDIS_PASSWORD }}
{{- end }}
{{- end }}

{{/*
MinIO endpoint helper
*/}}
{{- define "laravel-app.minioEndpoint" -}}
{{- if .Values.minio.enabled }}
{{- printf "http://%s-minio:9000" .Release.Name }}
{{- else if .Values.externalServices.s3.endpoint }}
{{- .Values.externalServices.s3.endpoint }}
{{- else }}
{{- .Values.env.AWS_ENDPOINT }}
{{- end }}
{{- end }}

{{/*
MinIO access key helper
*/}}
{{- define "laravel-app.minioAccessKey" -}}
{{- if .Values.minio.enabled }}
{{- .Values.minio.auth.rootUser }}
{{- else if .Values.externalServices.s3.accessKey }}
{{- .Values.externalServices.s3.accessKey }}
{{- else }}
{{- .Values.env.AWS_ACCESS_KEY_ID }}
{{- end }}
{{- end }}

{{/*
MinIO secret key helper
*/}}
{{- define "laravel-app.minioSecretKey" -}}
{{- if .Values.minio.enabled }}
{{- .Values.minio.auth.rootPassword }}
{{- else if .Values.externalServices.s3.secretKey }}
{{- .Values.externalServices.s3.secretKey }}
{{- else }}
{{- .Values.env.AWS_SECRET_ACCESS_KEY }}
{{- end }}
{{- end }}

{{/*
Mailpit host helper
*/}}
{{- define "laravel-app.mailHost" -}}
{{- if .Values.mailpit.enabled }}
{{- printf "%s-mailpit" (include "laravel-app.fullname" .) }}
{{- else if .Values.externalServices.smtp.host }}
{{- .Values.externalServices.smtp.host }}
{{- else }}
{{- .Values.env.MAIL_HOST }}
{{- end }}
{{- end }}

{{/*
Mail port helper
*/}}
{{- define "laravel-app.mailPort" -}}
{{- if .Values.mailpit.enabled }}
{{- .Values.mailpit.service.ports.smtp | toString }}
{{- else if .Values.externalServices.smtp.port }}
{{- .Values.externalServices.smtp.port | toString }}
{{- else }}
{{- .Values.env.MAIL_PORT }}
{{- end }}
{{- end }}

{{/*
Docker image helper
*/}}
{{- define "laravel-app.image" -}}
{{- if .Values.global.imageRegistry }}
{{- printf "%s/%s:%s" .Values.global.imageRegistry .Values.image.repository .Values.image.tag }}
{{- else }}
{{- printf "%s/%s:%s" .Values.image.registry .Values.image.repository .Values.image.tag }}
{{- end }}
{{- end }}

{{/*
Generate APP_KEY if not provided
*/}}
{{- define "laravel-app.appKey" -}}
{{- if .Values.app.key }}
{{- .Values.app.key }}
{{- else }}
{{- printf "base64:%s" (randAlphaNum 32 | b64enc) }}
{{- end }}
{{- end }} 