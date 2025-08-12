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

#------------- redis-deployment and service ------------#
{{- /* Selector labels for the Redis Deployment */ -}}
{{- define "quote-app.redis.selectorLabels" -}}
app: {{ .Values.redis.name }}
{{- end -}}

#------------- backend-deployment ------------#
{{- define "quote-app.backend.selectorLabels" -}}
app: {{ .Values.backend.name }}
{{- end -}}

#------------- backend-service (names + generic selectors) ---------------#

{{- /* Full name for backend resources (defaults to values.backend.name, else <fullname>-backend) */ -}}
{{- define "quote-app.backend.fullname" -}}
{{- if .Values.backend.name -}}
{{- .Values.backend.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-backend" (include "quote-app.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- /* Generic selector labels used by Services to match Pods */ -}}
{{- define "quote-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "quote-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
