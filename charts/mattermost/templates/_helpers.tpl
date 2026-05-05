{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mattermost.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mattermost.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mattermost.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Create a fully qualified jobserver name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "mattermost.jobserver.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.global.features.jobserver.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress. Based on
1) Helm Version (.Capabilities has been changed in v3)
2) Kubernetes Version
*/}}
{{- define "mattermost.ingress.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.k8s.io/v1" -}}
"networking.k8s.io/v1"
{{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
"networking.k8s.io/v1beta1"
{{- else -}}
"extensions/v1beta1"
{{- end -}}
{{- end -}}

{{- define "mattermost.deployment.apiVersion" -}}
"apps/v1"
{{- end -}}

{{/*
Size presets for the Mattermost app pods.

These mirror the App-row of the operator's `Size` table
(apis/mattermost/v1alpha1/clusterinstallation_sizes.go) so users get the same
sizing UX in the chart as they do via the CRD. The chart only sizes the
Mattermost app pods - database and object storage are external.

If `mattermostApp.size` is set to one of the keys below, it derives both
`replicas` and `resources` for the app deployment. Explicit values for
`mattermostApp.replicaCount` and `mattermostApp.resources` always win.

Supported keys: 100users, 1000users, 5000users, 10000users, 25000users.
*/}}
{{- define "mattermost.app.sizes" -}}
100users:
  replicas: 1
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 2000m
      memory: 4Gi
1000users:
  replicas: 2
  resources:
    requests:
      cpu: 150m
      memory: 256Mi
    limits:
      cpu: 2000m
      memory: 4Gi
5000users:
  replicas: 2
  resources:
    requests:
      cpu: 500m
      memory: 500Mi
    limits:
      cpu: 4000m
      memory: 8Gi
10000users:
  replicas: 2
  resources:
    requests:
      cpu: 500m
      memory: 500Mi
    limits:
      cpu: 4000m
      memory: 8Gi
25000users:
  replicas: 2
  resources:
    requests:
      cpu: 1000m
      memory: 4Gi
    limits:
      cpu: 4000m
      memory: 16Gi
{{- end -}}

{{/*
Resolve the sizing preset selected by the user, or an empty dict if none.
*/}}
{{- define "mattermost.app.size" -}}
{{- $size := default "" .Values.mattermostApp.size -}}
{{- if $size -}}
{{- $sizes := fromYaml (include "mattermost.app.sizes" .) -}}
{{- $preset := index $sizes $size -}}
{{- if not $preset -}}
{{- fail (printf "mattermostApp.size %q is not a known preset. Valid keys: 100users, 1000users, 5000users, 10000users, 25000users" $size) -}}
{{- end -}}
{{- toYaml $preset -}}
{{- end -}}
{{- end -}}

{{/*
Effective replica count for the Mattermost app deployment.

Mirrors the operator's semantics: when `mattermostApp.size` is set, the
preset is authoritative and overrides `replicaCount`. To override manually,
leave `mattermostApp.size` empty and use `mattermostApp.replicaCount`.
*/}}
{{- define "mattermost.app.effectiveReplicas" -}}
{{- $preset := fromYaml (include "mattermost.app.size" .) -}}
{{- if $preset -}}
{{- $preset.replicas -}}
{{- else -}}
{{- .Values.mattermostApp.replicaCount -}}
{{- end -}}
{{- end -}}

{{/*
Effective resource requirements for the Mattermost app container.

Mirrors the operator's semantics: when `mattermostApp.size` is set, the
preset is authoritative and overrides `resources`. To override manually,
leave `mattermostApp.size` empty and use `mattermostApp.resources`.
*/}}
{{- define "mattermost.app.effectiveResources" -}}
{{- $preset := fromYaml (include "mattermost.app.size" .) -}}
{{- if $preset -}}
{{- toYaml $preset.resources -}}
{{- else -}}
{{- toYaml .Values.mattermostApp.resources -}}
{{- end -}}
{{- end -}}
