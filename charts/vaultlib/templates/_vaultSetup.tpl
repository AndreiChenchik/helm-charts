{{- define "vaultlib.vaultSetup" -}}
kind: ServiceAccount
apiVersion: v1
metadata:
  name: {{ include "vaultlib.serviceAccount" . | quote }}
  namespace: {{ include "vaultlib.namespace" . | quote }}
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: {{ .Release.Name }}-vaultlib-role
  namespace: {{ include "vaultlib.namespace" . | quote }}
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["create", "update", "get"]
  - apiGroups: ["batch"]
    resources: ["jobs"]
    verbs: ["delete"]
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["list", "delete"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: {{ .Release.Name }}-vaultlib-rolebinding
  namespace: {{ include "vaultlib.namespace" . | quote }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ .Release.Name }}-vaultlib-role
subjects:
  - kind: ServiceAccount
    name: {{ include "vaultlib.serviceAccount" . | quote }}
    namespace: {{ include "vaultlib.namespace" . | quote }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "vaultlib.configName" . | quote }}
  namespace: {{ include "vaultlib.namespace" . | quote }}
data:
  vault_secret_shares: {{ include "vaultlib.unsealSecretShares" . | quote }}
  vault_secret_threshold: {{ include "vaultlib.unsealSecretThreshold" . | quote }}
  kubectl_version: {{ include "vaultlib.kubectlVersion" . | quote }}
  {{- include "vaultlib.checkVaultRunning.script" . | indent 2 }}
  {{- include "vaultlib.vaultInit.script" . | indent 2 }}
  {{- include "vaultlib.vaultUnseal.script" . | indent 2 }}
  {{- include "vaultlib.cleanup.script" . | indent 2 }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "vaultlib.jobName" . | quote }}
  namespace: {{ include "vaultlib.namespace" . | quote }}
spec:
  backoffLimit: 0
  template:
    spec:
      serviceAccountName: {{ include "vaultlib.serviceAccount" . | quote }}
      initContainers:
        {{- include "vaultlib.checkVaultRunning.container" . | indent 7 }}
        {{- if .Values.vault.jobs.init }}
          {{- include "vaultlib.vaultInit.container" . | indent 7 }}
        {{- end }}
        {{- if .Values.vault.jobs.unseal }}
          {{- include "vaultlib.vaultUnseal.container" . | indent 7 }}
        {{- end }}
      containers:
        {{- include "vaultlib.cleanup.runner" . | indent 7 }}
      restartPolicy: Never
      volumes:
        - name: scripts
          configMap:
            defaultMode: 0700
            name: {{ include "vaultlib.configName" . | quote }}
{{- end -}}
