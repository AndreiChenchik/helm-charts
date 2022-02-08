{{- define "vaultlib.clientImage" }}
{{- ((.Values.vault.client).repository) | default "vault" }}:{{ ((.Values.vault.client).version) | default .Subcharts.vaultlib.Chart.Metadata.AppVersion }}
{{- end }}

{{- define "vaultlib.unsealSecretShares" }}
{{- .Values.vault.server.unsealSecretShares | default 5 }}
{{- end }}

{{- define "vaultlib.unsealSecretThreshold" }}
{{- .Values.vault.server.unsealSecretThreshold | default 3 }}
{{- end }}

{{- define "vaultlib.kubectlVersion" }}
{{- .Values.kubectlVersion | default "v1.21.1" }}
{{- end }}

{{- define "vaultlib.configName" }}
{{- .Release.Name }}-vault-setup-config
{{- end }}

{{- define "vaultlib.namespace" }}
{{- .Values.vault.server.namespace | default "vault" }}
{{- end }}

{{- define "vaultlib.serviceAccount" }}
{{- .Release.Name }}-vault-setup-sa
{{- end }}

{{- define "vaultlib.jobName" }}
{{- .Release.Name }}-vault-setup-job
{{- end }}