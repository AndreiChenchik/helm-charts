{{- define "vaultconfig.ServiceAccount" }}
---
kind: ServiceAccount
apiVersion: v1
metadata:
  name: {{ include "vaultconfig.defaultResourceName" . | quote }}
  namespace: {{ include "vaultconfig.namespace" . | quote }}
{{- end }}
