{{- define "vaultconfig.apply" -}}
  {{- if (((.Values.vault).server).configure) }}
    {{- include "vaultconfig.ServiceAccount" . }}
    {{- include "vaultconfig.Role" . }}
    {{- include "vaultconfig.RoleBinding" . }}
    {{- include "vaultconfig.ConfigMap" . }}
    {{- include "vaultconfig.Job" . }}
  {{- end -}}
{{- end -}}
