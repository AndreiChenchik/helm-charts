{{- define "vaultconfig.apply" -}}
  {{- if (((.Values.vault).server).configure) }}
    {{- include "vaultconfig.ServiceAccount" . }}
    {{- include "vaultconfig.Role" . }}
    {{- include "vaultconfig.RoleBinding" . }}
    {{- include "vaultconfig.ConfigMap" . }}
    {{- include "vaultconfig.Job" . }}
  {{- end -}}

  {{- if or ((((.Values.vault).app).injectSecrets).toEnv) ((((.Values.vault).app).injectSecrets).toFiles) }}
    {{- include "vaultconfig.inject.ServiceAccount" . }}
    {{- if ((((.Values.vault).app).injectSecrets).toEnv) }}
      {{- include "vaultconfig.inject.SecretStore" . }}
      {{- include "vaultconfig.inject.ExternalSecret" . }}
    {{- end -}}
  {{- end -}}
{{- end -}}
