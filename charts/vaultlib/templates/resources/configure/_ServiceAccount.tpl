{{- define "vaultlib.configure.ServiceAccount" }}
---
kind: ServiceAccount
apiVersion: v1
metadata:
  name: {{ include "vaultlib.configure.serviceAccount" . | quote }}
  namespace: {{ include "vaultlib.configure.namespace" . | quote }}
  annotations:
    argocd.argoproj.io/hook: PreSync
{{- end }}
