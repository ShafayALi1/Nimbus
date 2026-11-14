{{- define "nimbus.name" -}}
{{- required "values.name is required" .Values.name -}}
{{- end -}}

{{- define "nimbus.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nimbus.name" . }}
app.kubernetes.io/part-of: nimbus
{{- end -}}

{{- define "nimbus.labels" -}}
{{ include "nimbus.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/* The pod template, shared by Deployment and Rollout. */}}
{{- define "nimbus.podTemplate" -}}
metadata:
  labels:
    {{- include "nimbus.labels" . | nindent 4 }}
spec:
  automountServiceAccountToken: false
  terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds }}
  securityContext:
    runAsNonRoot: true
    runAsUser: 10001
    runAsGroup: 10001
    seccompProfile: { type: RuntimeDefault }
  topologySpreadConstraints:          # spread replicas across nodes: one node dying doesn't take the service down
    - maxSkew: 1
      topologyKey: kubernetes.io/hostname
      whenUnsatisfiable: ScheduleAnyway
      labelSelector:
        matchLabels:
          {{- include "nimbus.selectorLabels" . | nindent 10 }}
  containers:
    - name: {{ include "nimbus.name" . }}
      image: "{{ required "image.repository is required" .Values.image.repository }}:{{ required "image.tag is required" .Values.image.tag }}"
      imagePullPolicy: {{ .Values.image.pullPolicy }}
      {{- with .Values.command }}
      command: {{ toYaml . | nindent 8 }}
      {{- end }}
      ports:
        - name: http
          containerPort: {{ .Values.port }}
      env:
        - name: APP_VERSION
          value: {{ .Values.image.tag | quote }}
        {{- with .Values.env }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      resources: {{- toYaml .Values.resources | nindent 8 }}
      {{- with .Values.startupProbe }}
      startupProbe: {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.livenessProbe }}
      livenessProbe: {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.readinessProbe }}
      readinessProbe: {{- toYaml . | nindent 8 }}
      {{- end }}
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities: { drop: [ALL] }
      volumeMounts:
        - { name: tmp, mountPath: /tmp }
  volumes:
    - name: tmp
      emptyDir: { sizeLimit: {{ .Values.tmpSizeLimit }} }
{{- end -}}
