{{- define "vaultinject.envFrom" }}
{{- if ((((.Values.vault).app).injectSecrets).toEnv) }}
- secretRef:
    name: {{ include "vaultinject.secretName" . }}
{{- end }}            
{{- end }}
