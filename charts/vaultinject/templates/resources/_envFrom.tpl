{{- define "vaultinject.envFrom" }}
{{- if .Values.vault.app.envSecret.enabled }}
- secretRef:
    name: {{ include "vaultinject.secretName" . }}
{{- end }}            
{{- end }}
