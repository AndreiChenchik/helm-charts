{{- define "vaultinject.Annotations" }}
{{- if (((.Values.vault).app).injectSecrets).toFiles }}
vault.hashicorp.com/agent-inject: "true"
vault.hashicorp.com/agent-inject-status: "update"
vault.hashicorp.com/role: {{ include "vaultinject.role" . | quote }}
{{ range $index, $secret := .Values.vault.app.injectSecrets.secrets }}
vault.hashicorp.com/agent-inject-secret-{{ $index }}: {{ include "vaultinject.kvEndpoint" $ }}/{{ $secret.path }}
vault.hashicorp.com/secret-volume-path-{{ $index }}: {{ include "vaultinject.mountPath" $ | quote }}
vault.hashicorp.com/agent-inject-command-{{ $index }}: "cat {{ include "vaultinject.mountPath" $ }}/{{ $index }} | sh --"
vault.hashicorp.com/agent-inject-template-{{ $index }}: |
  {{- `
  {{- with secret "`}}{{ include "vaultinject.kvEndpoint" $ }}/data/{{ $secret.path }}{{`" -}}
  {{- range $k, $v := .Data.data }}
  echo {{ $v }} > `}}{{ include "vaultinject.mountPath" $ }}{{`/{{ $k }}
  {{- end }}{{ end }}
  rm `}}{{ include "vaultinject.mountPath" $ }}/{{ $index }}
{{ end }}
{{- end }}
{{- end }}
