{{- define "vaultlib.spawnPolicies.config" }}
policies.json: |
{{ .Values.vault.server.policies | indent 2 }}
spawn-policies.sh: |
  #!/bin/ash
  apk --update add jq curl
  curl -o /usr/local/bin/kubectl -sLO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
  chmod +x /usr/local/bin/kubectl
  
  export VAULT_TOKEN=$(kubectl get secret vault-unseal-root-token -n vault -o json | jq -r '.data.root_token | @base64d')

  jq -c '.[]' /conf/policies.json | while read $team_policy; do
    policy_name=$(echo $team_policy | jq -r '.name')
    policy_data=$(echo $team_policy | jq -cr '.policy')

    echo "{$policy_data}" | vault policy write $policy_name -
  done

  echo "POLICIES SEEMS TO BE SPAWNED"
{{- end }}

{{- define "vaultlib.spawnPolicies.container" }}
- name: spawn-policies
  image: {{ include "vaultlib.clientImage" . | quote }}
  command: ['/bin/spawn-policies.sh']
  env:
    - name: VAULT_ADDR
      value: {{ include "vaultlib.serverUrl" . | quote }}
    - name: KUBECTL_VERSION
      valueFrom:
        configMapKeyRef:
          name: {{ include "vaultlib.configName" . | quote }}
          key: kubectl_version
  volumeMounts:
    - name: files
      mountPath: /bin/spawn-policies.sh
      readOnly: true
      subPath: spawn-policies.sh
    - name: files
      mountPath: /conf/policies.json
      readOnly: true
      subPath: policies.json
{{- end }}
