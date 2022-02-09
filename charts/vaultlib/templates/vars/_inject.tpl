{{- define "vaultlib.inject.defaultResourceName" }}
  {{- (print .Release.Name "-vaultlib-inject") }}
{{- end }}

{{- define "vaultlib.inject.serviceAccount" }}
  {{- .Values.vault.app.injectSecrets.serviceAccount | default (include "vaultlib.inject.defaultResourceName" . ) }}
{{- end }}

{{- define "vaultlib.inject.policy" }}
  {{- .Values.vault.app.injectSecrets.policy | default (include "vaultlib.inject.defaultResourceName" . ) }}
{{- end }}

{{- define "vaultlib.inject.role" }}
  {{- .Values.vault.app.injectSecrets.role | default (include "vaultlib.inject.defaultResourceName" . ) }}
{{- end }}

{{- define "vaultlib.inject.secretName" }}
  {{- include "vaultlib.inject.defaultResourceName" . }}
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
