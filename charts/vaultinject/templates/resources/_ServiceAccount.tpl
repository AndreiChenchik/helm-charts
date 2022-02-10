{{- define "vaultinject.ServiceAccount" }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "vaultinject.serviceAccount" . | quote }}
  namespace: "{{ .Release.Namespace }}"
  annotations:
    argocd.argoproj.io/hook: PreSync
{{- end }}
