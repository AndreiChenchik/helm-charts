{{- define "vaultlib.inject.serviceAccount" }}
  {{- .Values.vault.app.injectSecrets.serviceAccount | default (print .Release.Name "-injectSecrets") }}
{{- end }}

{{- define "vaultlib.inject.policy" }}
  {{- .Values.vault.app.injectSecrets.policy | default (print .Release.Name "-injectSecrets") }}
{{- end }}

{{- define "vaultlib.inject.role" }}
  {{- .Values.vault.app.injectSecrets.role | default (print .Release.Name "-injectSecrets") }}
{{- end }}

{{- define "vaultlib.inject.secretName" }}
  {{- .Release.Name }}-injectSecret
{{- end }}

{{- define "vaultlib.inject.fullPathToSecret" }}
  {{- include "vaultlib.kvEndpoint" . }}/{{ .Values.vault.app.injectSecrets.pathToSecret }}
{{- end }}

{{- define "vaultlib.inject.dataPathToSecret" }}
  {{- include "vaultlib.kvEndpoint" . }}/data/{{ .Values.vault.app.injectSecrets.pathToSecret }}
{{- end }}

{{- define "vaultlib.inject.mountPath" }}
  {{- .Values.vault.app.injectSecrets.mountPath }}
{{- end }}
