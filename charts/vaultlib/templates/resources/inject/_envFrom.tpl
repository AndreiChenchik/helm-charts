{{- define "vaultlib.inject.envFrom" }}
{{- if .Values.vault.app.envSecret.enabled }}
- secretRef:
    name: {{ .Release.Name }}-vault-secret
{{- end }}            
{{- end }}
