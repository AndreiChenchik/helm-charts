{{- define "vaultinject.serverUrl" }}
  {{- ((.Values.vault.server).url) | default "http://vault.vault:8200" }}
{{- end }}

{{- define "vaultinject.kvEndpoint" }}
  {{- ((.Values.vault.server).kvEndpoint) | default "secrets" }}
{{- end }}

{{- define "vaultinject.defaultResourceName" }}
  {{- (print .Release.Name "-vaultinject") }}
{{- end }}

{{- define "vaultinject.serviceAccount" }}
  {{- .Values.vault.app.injectSecrets.serviceAccount | default (include "vaultinject.defaultResourceName" . ) }}
{{- end }}

{{- define "vaultinject.policy" }}
  {{- .Values.vault.app.injectSecrets.policy | default (include "vaultinject.defaultResourceName" . ) }}
{{- end }}

{{- define "vaultinject.role" }}
  {{- .Values.vault.app.injectSecrets.role | default (include "vaultinject.defaultResourceName" . ) }}
{{- end }}

{{- define "vaultinject.secretName" }}
  {{- include "vaultinject.defaultResourceName" . }}
{{- end }}

{{- define "vaultinject.fullPathToSecret" }}
  {{- include "vaultinject.kvEndpoint" . }}/{{ .Values.vault.app.injectSecrets.pathToSecret }}
{{- end }}

{{- define "vaultinject.dataPathToSecret" }}
  {{- include "vaultinject.kvEndpoint" . }}/data/{{ .Values.vault.app.injectSecrets.pathToSecret }}
{{- end }}

{{- define "vaultinject.mountPath" }}
  {{- .Values.vault.app.injectSecrets.mountPath }}
{{- end }}
