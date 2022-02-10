{{- define "vaultconfig.RoleBinding" }}
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: {{ include "vaultconfig.defaultResourceName" . | quote }}
  namespace: {{ include "vaultconfig.namespace" . | quote }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ include "vaultconfig.defaultResourceName" . | quote }}
subjects:
  - kind: ServiceAccount
    name: {{ include "vaultconfig.defaultResourceName" . | quote }}
    namespace: {{ include "vaultconfig.namespace" . | quote }}
{{- end }}
