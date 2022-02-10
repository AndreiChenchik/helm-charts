{{- define "vaultconfig.inject.ServiceAccount" }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "vaultconfig.inject.serviceAccount" . | quote }}
  namespace: "{{ .Release.Namespace }}"
{{- end }}
