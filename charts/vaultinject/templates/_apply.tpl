{{- define "vaultconfig.apply" -}}
  {{- if or ((((.Values.vault).app).injectSecrets).toEnv) ((((.Values.vault).app).injectSecrets).toFiles) }}
    {{- include "vaultinject.ServiceAccount" . }}
    {{- if ((((.Values.vault).app).injectSecrets).toEnv) }}
      {{- include "vaultinject.SecretStore" . }}
      {{- include "vaultinject.ExternalSecret" . }}
    {{- end -}}
  {{- end -}}
{{- end -}}
