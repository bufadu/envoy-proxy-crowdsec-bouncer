{{/*
Expand the name of the chart.
*/}}
{{- define "envoy-proxy-bouncer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "envoy-proxy-bouncer.fullname" -}}
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
{{- define "envoy-proxy-bouncer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "envoy-proxy-bouncer.labels" -}}
helm.sh/chart: {{ include "envoy-proxy-bouncer.chart" . }}
{{ include "envoy-proxy-bouncer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "envoy-proxy-bouncer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "envoy-proxy-bouncer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "envoy-proxy-bouncer.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "envoy-proxy-bouncer.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Remove empty string values from config to allow defaults and env vars to take precedence
*/}}
{{- define "envoy-proxy-bouncer.cleanConfig" -}}
{{- $config := . -}}
{{- $result := dict -}}
{{- range $key, $value := $config -}}
  {{- if kindIs "map" $value -}}
    {{- $cleaned := include "envoy-proxy-bouncer.cleanConfig" $value | fromYaml -}}
    {{- if $cleaned -}}
      {{- $_ := set $result $key $cleaned -}}
    {{- end -}}
  {{- end -}}
  {{- if kindIs "slice" $value -}}
    {{- $_ := set $result $key $value -}}
  {{- end -}}
  {{- if or (kindIs "bool" $value) (kindIs "float64" $value) (kindIs "int" $value) (kindIs "int64" $value) -}}
    {{- $_ := set $result $key $value -}}
  {{- end -}}
  {{- if and (kindIs "string" $value) (ne $value "") -}}
    {{- $_ := set $result $key $value -}}
  {{- end -}}
{{- end -}}
{{- $result | toYaml -}}
{{- end -}}
