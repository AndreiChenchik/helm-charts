{{- define "vaultlib.configure.ServiceAccount" }}
---
kind: ServiceAccount
apiVersion: v1
metadata:
  name: {{ include "vaultlib.configure.serviceAccount" . | quote }}
  namespace: {{ include "vaultlib.configure.namespace" . | quote }}
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-delete-policy": before-hook-creation
{{- end }}
