{{- define "root.syncPolicy" -}}
syncPolicy:
  automated:
    prune: true        # delete what was removed from Git
    selfHeal: true     # undo manual changes made with kubectl
  retry:
    limit: 10
    backoff: { duration: 10s, factor: 2, maxDuration: 3m }
  syncOptions:
    - CreateNamespace=true
    {{- if .serverSideApply }}
    - ServerSideApply=true
    {{- end }}
{{- end -}}
