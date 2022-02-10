{{- define "vaultconfig.inject.Annotations" }}
{{- if .Values.vault.app.injectSecrets.toFiles }}
vault.hashicorp.com/agent-inject: "true"
vault.hashicorp.com/agent-inject-status: "update"
vault.hashicorp.com/role: {{ include "vaultconfig.inject.role" . | quote }}
vault.hashicorp.com/agent-inject-secret-spawn: {{ include "vaultconfig.inject.fullPathToSecret" . }}
vault.hashicorp.com/secret-volume-path-spawn: {{ include "vaultconfig.inject.mountPath" . | quote }}
vault.hashicorp.com/agent-inject-template-spawn: |
  {{- `
  {{- with secret "`}}{{ include "vaultconfig.inject.dataPathToSecret" . }}{{`" -}}
  {{- range $k, $v := .Data.data }}
  echo {{ $v }} > `}}{{ include "vaultconfig.inject.mountPath" . }}{{`/{{ $k }}
  {{- end }}{{ end }}
  rm `}}{{ include "vaultconfig.inject.mountPath" . }}{{`/spawn
  `}}
vault.hashicorp.com/agent-inject-command-spawn: "cat {{ include "vaultconfig.inject.mountPath" . }}/spawn | sh --"
{{- end }}
{{- end }}
