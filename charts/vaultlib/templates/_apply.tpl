{{- define "vaultlib.apply" -}}
  {{- if (((.Values.vault).server).configure) }}
    {{- include "vaultlib.configure.ServiceAccount" . }}
    {{- include "vaultlib.configure.Role" . }}
    {{- include "vaultlib.configure.RoleBinding" . }}
    {{- include "vaultlib.configure.ConfigMap" . }}
    {{- include "vaultlib.configure.Job" . }}
  {{- end -}}

  {{- if or ((((.Values.vault).app).injectSecrets).toEnv) ((((.Values.vault).app).injectSecrets).toFiles) }}
    {{- include "vaultlib.inject.ServiceAccount" . }}
    {{- if ((((.Values.vault).app).injectSecrets).toEnv) }}
      {{- include "vaultlib.inject.SecretStore" . }}
      {{- include "vaultlib.inject.ExternalSecret" . }}
    {{- end -}}
  {{- end -}}
{{- end -}}
