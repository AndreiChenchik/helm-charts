{{- define "vaultconfig.apply" -}}
  {{- if or ((((.Values.vault).app).injectSecrets).toEnv) ((((.Values.vault).app).injectSecrets).toFiles) }}
    {{- include "vaultconfig.inject.ServiceAccount" . }}
    {{- if ((((.Values.vault).app).injectSecrets).toEnv) }}
      {{- include "vaultconfig.inject.SecretStore" . }}
      {{- include "vaultconfig.inject.ExternalSecret" . }}
    {{- end -}}
  {{- end -}}
{{- end -}}
