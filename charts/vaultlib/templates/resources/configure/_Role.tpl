{{- define "vaultlib.configure.Role" }}
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: {{ .Release.Name }}-vaultlib-role
  namespace: {{ include "vaultlib.configure.namespace" . | quote }}
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "-1"
    "helm.sh/hook-delete-policy": before-hook-creation
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
{{- end }}
