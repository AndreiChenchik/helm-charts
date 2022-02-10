{{- define "vaultlib.configure.RoleBinding" }}
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: {{ .Release.Name }}-vaultlib-rolebinding
  namespace: {{ include "vaultlib.configure.namespace" . | quote }}
  annotations:
    argocd.argoproj.io/hook: PreSync
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ .Release.Name }}-vaultlib-role
subjects:
  - kind: ServiceAccount
    name: {{ include "vaultlib.configure.serviceAccount" . | quote }}
    namespace: {{ include "vaultlib.configure.namespace" . | quote }}
{{- end }}
