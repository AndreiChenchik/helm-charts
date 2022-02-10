{{- define "vaultconfig.inject.serviceAccountName" }}
{{- if or .Values.vault.app.injectSecrets.toFiles }}
serviceAccountName: {{ include "vaultconfig.inject.serviceAccount" . | quote }}
{{- end -}}
{{- end -}}
