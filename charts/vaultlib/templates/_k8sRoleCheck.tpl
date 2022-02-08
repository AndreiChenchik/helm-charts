{{- define "vaultlib.k8sRoleCheck" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: "{{ .Release.Name }}-k8s-role-config"
  namespace: "{{ .Values.vault.server.namespace | default "vault" }}"
data:
  {{- include "vaultlib.checkVaultRunning.script" . | indent 1 }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ .Release.Name }}-k8s-role-job"
  namespace: "{{ .Values.vault.server.namespace | default "vault" }}"
spec:
  backoffLimit: 0
  template:
    spec:
      initContainers:
        {{- include "vaultlib.checkVaultRunning.runner" . | indent 6 }}
      containers:
        - name: do-vault-init
          image: "{{ ((.Values.vault.client).repository) | default "vault" }}:{{ ((.Values.vault.client).version) | default .Subcharts.vaultlib.Chart.Metadata.AppVersion }}"
          command: ["/bin/check-vault-running.sh"]
          env:
            - name: VAULT_ADDR
              value: "{{ .Values.vault.server.url }}"
            {{- if ((.Values.vault.server.token).secretName) }}
            - name: VAULT_TOKEN
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.vault.server.token.secretName }}
                  key: {{ .Values.vault.server.token.secretKey }}
            {{- end }}
          volumeMounts:
            - name: scripts
              mountPath: /bin/check-vault-running.sh
              readOnly: true
              subPath: check-vault-running.sh
      restartPolicy: Never
      volumes:
        - name: scripts
          configMap:
            defaultMode: 0700
            name: "{{ .Release.Name }}-k8s-role-config"
{{- end -}}
