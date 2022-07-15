{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mattermost-push-proxy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "mattermost-push-proxy.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mattermost-push-proxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "mattermost-push-proxy.ingress.apiVersion" -}}
  {{- if .Capabilities.APIVersions.Has "networking.k8s.io/v1" -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if ingress is stable.
*/}}
{{- define "mattermost-push-proxy.ingress.isStable" -}}
  {{- eq (include "mattermost-push-proxy.ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "mattermost-push-proxy.ingress.supportsPathType" -}}
  {{- or (eq (include "mattermost-push-proxy.ingress.isStable" .) "true") (and (eq (include "mattermost-push-proxy.ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18-0" .Capabilities.KubeVersion.Version)) -}}
{{- end -}}
