{{- define "vaultinject.SecretStore" }}
---
apiVersion: external-secrets.io/v1alpha1
kind: SecretStore
metadata:
  name: {{ include "vaultinject.defaultResourceName" . | quote }}
  namespace: "{{ .Release.Namespace }}"
  annotations:
    argocd.argoproj.io/hook: PreSync
spec:
  provider:
    vault: 
      server: {{ include "vaultinject.serverUrl" . | quote }}
      path: {{ include "vaultinject.kvEndpoint" . | quote }} 
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: {{ include "vaultinject.role" . | quote }}
          serviceAccountRef:
            name: {{ include "vaultinject.serviceAccount" . | quote }}
            namespace: "{{ .Release.Namespace }}"
{{- end }}
