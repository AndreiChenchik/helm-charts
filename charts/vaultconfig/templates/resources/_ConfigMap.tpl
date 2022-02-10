{{- define "vaultconfig.ConfigMap" }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "vaultconfig.defaultResourceName" . | quote }}
  namespace: {{ include "vaultconfig.namespace" . | quote }}
data:
  vault_addr: {{ include "vaultconfig.serverUrl" . | quote }}
  kubectl_version: {{ include "vaultconfig.container.kubectlVersion" . | quote }}
  {{- if or .Values.vault.server.configure.init .Values.vault.server.configure.unseal }} {{- include "vaultconfig.init.config" . | indent 2 }} {{- end }}
  {{- if .Values.vault.server.configure.enableGithubAuth }} {{- include "vaultconfig.enableGithubAuth.config" . | indent 2 }} {{- end }}
  {{- if .Values.vault.server.configure.enableKVEngine }} {{- include "vaultconfig.enableKVEngine.config" . | indent 2 }} {{- end }}
  {{- if .Values.vault.server.configure.enableK8sAuth }} {{- include "vaultconfig.enableK8sAuth.config" . | indent 2 }} {{- end }}
  {{- if .Values.vault.server.configure.spawnPolicies }} {{- include "vaultconfig.spawnPolicies.config" . | indent 2 }} {{- end }}
  {{- if .Values.vault.server.configure.spawnRandomSecrets }} {{- include "vaultconfig.spawnRandomSecrets.config" . | indent 2 }} {{- end }}
  vault-configure.sh: |-
    #!/bin/ash
    set -e 

    apk --update add jq curl pwgen
    curl -o /usr/local/bin/kubectl -sLO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
    chmod +x /usr/local/bin/kubectl
    
    for attempt in `seq 15`; do
      if [ "$attempt" -eq 15 ]; then
        echo "VAULT NOT REACHABLE"
        exit 1
      elif vault status; then
        echo "VAULT OK EXITING"
        break
      elif [ "$?" = "2" ]; then
        echo "VAULT SEALED"
        break
      else
        echo "sleeping for $attempt"
        sleep "$attempt"
      fi
    done

  {{- if .Values.vault.server.configure.init }} {{- include "vaultconfig.init.script" . | indent 4 }} {{- end }}
  {{- if .Values.vault.server.configure.unseal }} {{- include "vaultconfig.unseal.script" . | indent 4 }} {{- end }}
  {{- if .Values.vault.server.configure.enableGithubAuth }} {{- include "vaultconfig.enableGithubAuth.script" . | indent 4 }} {{- end }}
  {{- if .Values.vault.server.configure.enableK8sAuth }} {{- include "vaultconfig.enableK8sAuth.script" . | indent 4 }} {{- end }}
  {{- if .Values.vault.server.configure.spawnPolicies }} {{- include "vaultconfig.spawnPolicies.script" . | indent 4 }} {{- end }}
  {{- if .Values.vault.server.configure.enableKVEngine }} {{- include "vaultconfig.enableKVEngine.script" . | indent 4 }} {{- end }}
  {{- if .Values.vault.server.configure.spawnRandomSecrets }} {{- include "vaultconfig.spawnRandomSecrets.script" . | indent 4 }} {{- end }}
  {{- if .Values.vault.server.configure.cleanup }} {{- include "vaultconfig.cleanup.script" . | indent 4 }} {{- end }}
{{- end }}
