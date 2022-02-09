{{- define "vaultlib.inject.ExternalSecret" }}
---
apiVersion: external-secrets.io/v1alpha1
kind: ExternalSecret
metadata:
  name: "{{ .Release.Name }}-injectSecret"
  namespace: "{{ .Release.Namespace }}"
spec:
  refreshInterval: "15s"
  secretStoreRef:
    name: {{ .Release.Name }}-injectSecret
    kind: SecretStore
  target:
    name: {{ include "vaultlib.inject.secretName" . }}
  data:
  {{- range $field :=  .Values.vault.app.injectSecrets.keysToInject }}
    - secretKey: {{ $field }}
      remoteRef:
        key: {{ $.Values.vault.app.injectSecrets.pathToSecret }}
        property: {{ $field }}
  {{- end }}
{{- end }}
