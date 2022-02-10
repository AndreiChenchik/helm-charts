{{- define "vaultinject.Annotations" }}
{{- if .Values.vault.app.injectSecrets.toFiles }}
vault.hashicorp.com/agent-inject: "true"
vault.hashicorp.com/agent-inject-status: "update"
vault.hashicorp.com/role: {{ include "vaultinject.role" . | quote }}
vault.hashicorp.com/agent-inject-secret-spawn: {{ include "vaultinject.fullPathToSecret" . }}
vault.hashicorp.com/secret-volume-path-spawn: {{ include "vaultinject.mountPath" . | quote }}
vault.hashicorp.com/agent-inject-template-spawn: |
  {{- `
  {{- with secret "`}}{{ include "vaultinject.dataPathToSecret" . }}{{`" -}}
  {{- range $k, $v := .Data.data }}
  echo {{ $v }} > `}}{{ include "vaultinject.mountPath" . }}{{`/{{ $k }}
  {{- end }}{{ end }}
  rm `}}{{ include "vaultinject.mountPath" . }}{{`/spawn
  `}}
vault.hashicorp.com/agent-inject-command-spawn: "cat {{ include "vaultinject.mountPath" . }}/spawn | sh --"
{{- end }}
{{- end }}
