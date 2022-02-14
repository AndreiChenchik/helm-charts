{{- define "vaultinject.serviceAccountName" }}
{{- if (((.Values.vault).app).injectSecrets).toFiles }}
serviceAccountName: {{ include "vaultinject.serviceAccount" . | quote }}
{{- end -}}
{{- end -}}
