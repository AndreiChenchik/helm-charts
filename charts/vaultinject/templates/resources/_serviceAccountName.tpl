{{- define "vaultinject.serviceAccountName" }}
{{- if or .Values.vault.app.injectSecrets.toFiles }}
serviceAccountName: {{ include "vaultinject.serviceAccount" . | quote }}
{{- end -}}
{{- end -}}
