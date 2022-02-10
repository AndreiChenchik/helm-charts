{{- define "vaultlib.configure.Job" }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "vaultlib.configure.jobName" . | quote }}
  namespace: {{ include "vaultlib.configure.namespace" . | quote }}
spec:
  ttlSecondsAfterFinished: 60
  backoffLimit: 0
  template:
    spec:
      serviceAccountName: {{ include "vaultlib.configure.serviceAccount" . | quote }}
      initContainers:
        {{- include "vaultlib.checkVaultUp.container" . | indent 7 }}
        {{- if .Values.vault.server.configure.init }}
          {{- include "vaultlib.init.container" . | indent 7 }}
        {{- end }}
        {{- if .Values.vault.server.configure.unseal }}
          {{- include "vaultlib.unseal.container" . | indent 7 }}
        {{- end }}
        {{- if .Values.vault.server.configure.enableK8sAuth }}
          {{- include "vaultlib.enableK8sAuth.container" . | indent 7 }}
        {{- end }}
        {{- if .Values.vault.server.configure.enableGithubAuth }}
          {{- include "vaultlib.enableGithubAuth.container" . | indent 7 }}
        {{- end }}
        {{- if .Values.vault.server.configure.enableKVEngine }}
          {{- include "vaultlib.enableKVEngine.container" . | indent 7 }}
        {{- end }}
        {{- if .Values.vault.server.configure.configureInjectRole }}
          {{- include "vaultlib.configureInjectRole.container" . | indent 7 }}
        {{- end }}
        {{- if .Values.vault.server.configure.spawnPolicies }}
          {{- include "vaultlib.spawnPolicies.container" . | indent 7 }}
        {{- end }}
        {{- if .Values.vault.server.configure.spawnRandomSecrets }}
          {{- include "vaultlib.spawnRandomSecrets.container" . | indent 7 }}
        {{- end }}
      containers:
        {{- include "vaultlib.cleanup.container" . | indent 7 }}
      restartPolicy: Never
      volumes:
        - name: files
          configMap:
            defaultMode: 0700
            name: {{ include "vaultlib.configure.configName" . | quote }}
{{- end }}
