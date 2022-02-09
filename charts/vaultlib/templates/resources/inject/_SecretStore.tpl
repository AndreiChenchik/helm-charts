{{- define "vaultlib.inject.SecretStore" }}
---
apiVersion: external-secrets.io/v1alpha1
kind: SecretStore
metadata:
  name: {{ .Release.Name }}-injectSecrets
  namespace: "{{ .Release.Namespace }}"
spec:
  provider:
    vault: 
      server: {{ include "vaultlib.serverUrl" . | quote }}
      path: {{ include "vaultlib.kvEndpoint" . | quote }} 
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: {{ include "vaultlib.inject.role" . | quote }}
          serviceAccountRef:
            name: {{ include "vaultlib.inject.serviceAccount" . | quote }}
            namespace: "{{ .Release.Namespace }}"
{{- end }}
