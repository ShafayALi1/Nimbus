{{- define "data.securityContext" -}}
allowPrivilegeEscalation: false
readOnlyRootFilesystem: true
capabilities: { drop: [ALL] }
{{- end -}}

{{- define "data.allowClients" -}}
{{- range .Values.clients }}
- podSelector:
    matchLabels: { app.kubernetes.io/name: {{ . }} }
{{- end }}
{{- end -}}
