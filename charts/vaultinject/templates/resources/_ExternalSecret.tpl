{{- define "vaultinject.ExternalSecret" }}
---
apiVersion: external-secrets.io/v1alpha1
kind: ExternalSecret
metadata:
  name: {{ include "vaultinject.defaultResourceName" . | quote }}
  namespace: "{{ .Release.Namespace }}"
spec:
  refreshInterval: "15s"
  secretStoreRef:
    name: {{ include "vaultinject.defaultResourceName" . | quote }}
    kind: SecretStore
  target:
    name: {{ include "vaultinject.secretName" . | quote }}
  data:
  {{- range $field :=  .Values.vault.app.injectSecrets.keysToInject }}
    - secretKey: {{ $field }}
      remoteRef:
        key: {{ $.Values.vault.app.injectSecrets.pathToSecret }}
        property: {{ $field }}
  {{- end }}
{{- end }}
