{{- define "vaultlib.inject.Annotations" }}
{{- if .Values.vault.app.injectSecrets.toFiles }}
vault.hashicorp.com/agent-inject: "true"
vault.hashicorp.com/agent-inject-status: "update"
vault.hashicorp.com/role: {{ include "vaultlib.inject.role" . | quote }}
vault.hashicorp.com/agent-inject-secret-spawn: {{ include "vaultlib.inject.fullPathToSecret" . }}
vault.hashicorp.com/secret-volume-path-spawn: {{ include "vaultlib.inject.mountPath" . | quote }}
vault.hashicorp.com/agent-inject-template-spawn: |
  {{- `
  {{- with secret "`}}{{ include "vaultlib.inject.dataPathToSecret" . }}{{`" -}}
  {{- range $k, $v := .Data.data }}
  echo {{ $v }} > `}}{{ include "vaultlib.inject.mountPath" . }}{{`/{{ $k }}
  {{- end }}{{ end }}
  rm `}}{{ include "vaultlib.inject.mountPath" . }}{{`/spawn
  `}}
vault.hashicorp.com/agent-inject-command-spawn: "cat {{ include "vaultlib.inject.mountPath" . }}/spawn | sh --"
{{- end }}
{{- end }}
