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
  
  {{- include "vaultlib.checkVaultUp.script" . | indent 2 }}
  
  {{- if .Values.vault.jobs.init }}
    {{- include "vaultlib.init.script" . | indent 2 }}
  {{- end }}
  
  {{- if .Values.vault.jobs.unseal }}
    {{- include "vaultlib.unseal.script" . | indent 2 }}
  {{- end }}

  {{- if .Values.vault.jobs.enableK8sAuth }}
    {{- include "vaultlib.enableK8sAuth.script" . | indent 2 }}
  {{- end }}

  {{- if .Values.vault.jobs.configureK8sRole }}
  vault_role: {{ include "vaultlib.appRole" . | quote }}
  vault_serviceaccount: {{ include "vaultlib.appSA" . | quote }}
  vault_serviceaccount_namespace: {{ include "vaultlib.appSANamespace" . | quote }}
    {{- include "vaultlib.configureK8sRole.script" . | indent 2 }}
  {{- end }}

  {{- include "vaultlib.cleanup.script" . | indent 2 }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "vaultlib.jobName" . | quote }}
  namespace: {{ include "vaultlib.namespace" . | quote }}
  annotations:
    "helm.sh/hook": post-install,post-upgrade
    "helm.sh/hook-delete-policy": before-hook-creation
spec:
  backoffLimit: 0
  template:
    spec:
      serviceAccountName: {{ include "vaultlib.serviceAccount" . | quote }}
      initContainers:
        {{- include "vaultlib.checkVaultUp.container" . | indent 7 }}
        {{- if .Values.vault.jobs.init }}
          {{- include "vaultlib.init.container" . | indent 7 }}
        {{- end }}
        {{- if .Values.vault.jobs.unseal }}
          {{- include "vaultlib.unseal.container" . | indent 7 }}
        {{- end }}
        {{- if .Values.vault.jobs.enableK8sAuth }}
          {{- include "vaultlib.enableK8sAuth.container" . | indent 7 }}
        {{- end }}
        {{- if .Values.vault.jobs.configureK8sRole }}
          {{- include "vaultlib.configureK8sRole.container" . | indent 7 }}
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
