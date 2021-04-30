{{/* vim: set filetype=mustache: */}}
{{- define "mattermost-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 50 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
The components in this chart create additional resources that expand the longest created name strings.
The longest name that gets created adds and extra 37 characters, so truncation should be 63-35=26.
*/}}
{{- define "mattermost-operator.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 26 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 26 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 26 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "mattermost-operator.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}


{{- define "mysql-operator.name" -}}
{{ .Values.mysqlOperator.appName }}-operator
{{- end }}

{{- define "mysql-operator.namespace" -}}
  {{- if .Values.mysqlOperator.namespace -}}
    {{- .Values.mysqlOperator.namespace -}}
  {{- else -}}
    {{- printf "mysql-operator" -}}
  {{- end -}}
{{- end -}}


{{- define "minio-operator.name" -}}
{{ .Values.minioOperator.appName }}-operator
{{- end }}

{{- define "minio-operator.namespace" -}}
  {{- if .Values.minioOperator.namespace -}}
    {{- .Values.minioOperator.namespace -}}
  {{- else -}}
    {{- printf "minio-operator" -}}
  {{- end -}}
{{- end -}}
