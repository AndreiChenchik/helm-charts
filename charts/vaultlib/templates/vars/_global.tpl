{{- define "vaultlib.serverUrl" }}
  {{- ((.Values.vault.server).url) | default "http://vault.vault:8200" }}
{{- end }}

{{- define "vaultlib.kvEndpoint" }}
  {{- ((.Values.vault.server).kvEndpoint) | default "secrets" }}
{{- end }}
