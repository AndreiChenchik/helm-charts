{{- define "vaultconfig.Job" }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "vaultconfig.defaultResourceName" . | quote }}
  namespace: {{ include "vaultconfig.namespace" . | quote }}
  annotations:
    argocd.argoproj.io/hook: Sync
    argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
spec:
  backoffLimit: 0
  template:
    spec:
      serviceAccountName: {{ include "vaultconfig.defaultResourceName" . | quote }}
      containers:
        - name: vault-configure
          image: {{ include "vaultconfig.container.image" . | quote }}
          # command: ["/bin/vault-configure.sh"]
          command: [ "/bin/bash", "-c", "--" ]
          args: [ "while true; do sleep 30; done;" ]
          env:
            - name: VAULT_ADDR
              valueFrom:
                configMapKeyRef:
                  name: {{ include "vaultconfig.defaultResourceName" . | quote }}
                  key: vault_addr
            - name: KUBECTL_VERSION
              valueFrom:
                configMapKeyRef:
                  name: {{ include "vaultconfig.defaultResourceName" . | quote }}
                  key: kubectl_version
            {{- if or .Values.vault.server.configure.init .Values.vault.server.configure.unseal }} {{- include "vaultconfig.init.envs" . | indent 12 }} {{- end }}
            {{- if .Values.vault.server.configure.enableGithubAuth }} {{- include "vaultconfig.enableGithubAuth.envs" . | indent 12 }} {{- end }}
            {{- if .Values.vault.server.configure.enableKVEngine }} {{- include "vaultconfig.enableKVEngine.envs" . | indent 12 }} {{- end }}
          volumeMounts:
            - name: files
              mountPath: /bin/vault-configure.sh
              readOnly: true
              subPath: vault-configure.sh
            {{- if .Values.vault.server.configure.enableGithubAuth }} {{- include "vaultconfig.enableGithubAuth.mounts" . | indent 12 }} {{- end }}
            {{- if .Values.vault.server.configure.enableK8sAuth }} {{- include "vaultconfig.enableK8sAuth.mounts" . | indent 12 }} {{- end }}
            {{- if .Values.vault.server.configure.spawnPolicies }} {{- include "vaultconfig.spawnPolicies.mounts" . | indent 12 }} {{- end }}
            {{- if .Values.vault.server.configure.spawnRandomSecrets }} {{- include "vaultconfig.spawnRandomSecrets.mounts" . | indent 12 }} {{- end }}
      restartPolicy: Never
      volumes:
        - name: files
          configMap:
            defaultMode: 0700
            name: {{ include "vaultconfig.defaultResourceName" . | quote }}
{{- end }}
