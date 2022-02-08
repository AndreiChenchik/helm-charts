{{- define "vaultlib.clientImage" }}
{{- ((.Values.vault.client).repository) | default "vault" }}:{{ ((.Values.vault.client).version) | default .Subcharts.vaultlib.Chart.Metadata.AppVersion }}
{{- end }}