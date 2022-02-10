{{- define "vaultinject.envFrom" }}
{{- if .Values.vault.app.envSecret.enabled }}
- secretRef:
    name: {{ include "vaultconfig.inject.secretName" . }}
{{- end }}            
{{- end }}
