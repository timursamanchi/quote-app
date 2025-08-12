#------------- redis-pvc ------------#
{{- /* Return the chart name */ -}}
{{- define "quote-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- /* Create a fullname, optionally overridden */ -}}
{{- define "quote-app.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "quote-app.name" . | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end }}

{{- /* Common labels (kept minimal) */ -}}
{{- define "quote-app.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "quote-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

#------------- redis-deployment ------------#
{{- /* Selector labels for the Redis Deployment */ -}}
{{- define "quote-app.redis.selectorLabels" -}}
app: {{ .Values.redis.name }}
{{- end -}}

#------------- redis-service ------------#