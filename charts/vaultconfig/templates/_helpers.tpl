{{- define "vaultconfig.defaultResourceName" }}
  {{- (print .Release.Name "-vaultconfig") }}
{{- end }}

{{- define "vaultconfig.serverUrl" }}
  {{- ((.Values.vault.server).url) | default "http://vault.vault:8200" }}
{{- end }}

{{- define "vaultconfig.kvEndpoint" }}
  {{- ((.Values.vault.server).kvEndpoint) | default "secrets" }}
{{- end }}

{{- define "vaultconfig.namespace" }}
  {{- ((.Values.vault.server).namespace) | default "vault" }}
{{- end }}

{{- define "vaultconfig.container.image" }}
  {{- ((.Values.vault.client).repository) | default "vault" }}:{{ ((.Values.vault.client).version) | default .Subcharts.vaultconfig.Chart.Metadata.AppVersion }}
{{- end }}

{{- define "vaultconfig.container.kubectlVersion" }}
  {{- .Values.kubectlVersion | default "v1.21.1" }}
{{- end }}

{{- define "vaultconfig.unsealSecretShares" }}
  {{- ((.Values.vault.server).unsealSecretShares) | default 5 }}
{{- end }}

{{- define "vaultconfig.unsealSecretThreshold" }}
  {{- ((.Values.vault.server).unsealSecretThreshold) | default 3 }}
{{- end }}

{{- define "vaultconfig.jobSleepSeconds" -}}
5
{{- end }}
