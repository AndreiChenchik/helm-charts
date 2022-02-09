{{- define "vaultlib.inject.ServiceAccount" }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "vaultlib.inject.serviceAccount" . | quote }}
  namespace: "{{ .Release.Namespace }}"
{{- end }}
