{{- define "vaultlib.configure.ConfigMap" }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "vaultlib.configure.configName" . | quote }}
  namespace: {{ include "vaultlib.configure.namespace" . | quote }}
data:
  vault_secret_shares: {{ include "vaultlib.configure.unsealSecretShares" . | quote }}
  vault_secret_threshold: {{ include "vaultlib.configure.unsealSecretThreshold" . | quote }}
  kubectl_version: {{ include "vaultlib.configure.container.kubectlVersion" . | quote }}  
  {{- include "vaultlib.checkVaultUp.config" . | indent 2 }}
  {{- if .Values.vault.server.configure.init }}
    {{- include "vaultlib.init.config" . | indent 2 }}
  {{- end }}
  {{- if .Values.vault.server.configure.unseal }}
    {{- include "vaultlib.unseal.config" . | indent 2 }}
  {{- end }}
  {{- if .Values.vault.server.configure.enableK8sAuth }}
    {{- include "vaultlib.enableK8sAuth.config" . | indent 2 }}
  {{- end }}
  {{- if .Values.vault.server.configure.enableGithubAuth }}
    {{- include "vaultlib.enableGithubAuth.config" . | indent 2 }}
  {{- end }}
  {{- if .Values.vault.server.configure.enableKVEngine }}
    {{- include "vaultlib.enableKVEngine.config" . | indent 2 }}
  {{- end }}
  {{- if .Values.vault.server.configure.configureInjectRole }}
    {{- include "vaultlib.configureInjectRole.config" . | indent 2 }}
  {{- end }}
  {{- if .Values.vault.server.configure.spawnPolicies }}
    {{- include "vaultlib.spawnPolicies.config" . | indent 2 }}
  {{- end }}
  {{- if .Values.vault.server.configure.spawnRandomSecrets }}
    {{- include "vaultlib.spawnRandomSecrets.config" . | indent 2 }}
  {{- end }}
  {{- include "vaultlib.cleanup.config" . | indent 2 }}
{{- end }}
