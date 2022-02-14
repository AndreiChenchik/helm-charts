{{- define "vaultinject.envFrom" }}
{{- if ((((.Values.vault).app).injectSecrets).toEnv) }}
{{ range $index, $secret := .Values.vault.app.injectSecrets.secrets }}
- secretRef:
    name: {{ include "vaultinject.secretName" $ }}-{{ $index }}
{{ end }}
{{- end }}            
{{- end }}
