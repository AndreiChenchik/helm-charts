{{- define "vaultlib.configure.namespace" }}
  {{- ((.Values.vault.server).namespace) | default "vault" }}
{{- end }}

{{- define "vaultlib.configure.jobName" }}
  {{- .Release.Name }}-vaultlib-job-rev{{ .Release.Revision }}
{{- end }}

{{- define "vaultlib.configure.configName" }}
  {{- .Release.Name }}-vaultlib-config
{{- end }}

{{- define "vaultlib.configure.serviceAccount" }}
  {{- .Release.Name }}-vaultlib-sa
{{- end }}

{{- define "vaultlib.configure.container.image" }}
  {{- ((.Values.vault.client).repository) | default "vault" }}:{{ ((.Values.vault.client).version) | default .Subcharts.vaultlib.Chart.Metadata.AppVersion }}
{{- end }}

{{- define "vaultlib.configure.container.kubectlVersion" }}
  {{- .Values.kubectlVersion | default "v1.21.1" }}
{{- end }}

{{- define "vaultlib.configure.unsealSecretShares" }}
  {{- ((.Values.vault.server).unsealSecretShares) | default 5 }}
{{- end }}

{{- define "vaultlib.configure.unsealSecretThreshold" }}
  {{- ((.Values.vault.server).unsealSecretThreshold) | default 3 }}
{{- end }}
