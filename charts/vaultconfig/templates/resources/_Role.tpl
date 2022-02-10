{{- define "vaultconfig.Role" }}
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: {{ include "vaultconfig.defaultResourceName" . | quote }}
  namespace: {{ include "vaultconfig.namespace" . | quote }}
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
