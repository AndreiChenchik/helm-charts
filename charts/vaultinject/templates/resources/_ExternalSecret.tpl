{{- define "vaultinject.ExternalSecret" }}
{{ range $index, $secret := (((.Values.vault).app).injectSecrets).secrets }}
---
apiVersion: external-secrets.io/v1alpha1
kind: ExternalSecret
metadata:
  name: {{ include "vaultinject.defaultResourceName" $. | quote }}-{{ $index }}
  namespace: "{{ .Release.Namespace }}"
spec:
  refreshInterval: "15s"
  secretStoreRef:
    name: {{ include "vaultinject.defaultResourceName" $. | quote }}
    kind: SecretStore
  target:
    name: {{ include "vaultinject.secretName" $. | quote }}-{{ $index }}
  data:
  {{- range $field := $secret.keys }}
    - secretKey: {{ $field }}
      remoteRef:
        key: {{ $secret.path }}
        property: {{ $field }}
  {{- end }}
{{ end }}
{{- end }}
