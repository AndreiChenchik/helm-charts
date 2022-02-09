{{- define "vaultlib.inject.serviceAccountName" }}
{{- if or .Values.vault.app.injectSecrets.toFiles }}
serviceAccountName: {{ include "vaultlib.inject.serviceAccount" . | quote }}
{{- end -}}
{{- end -}}