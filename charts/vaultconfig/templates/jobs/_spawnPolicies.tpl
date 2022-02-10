{{- define "vaultconfig.spawnPolicies.config" }}
policies.json: |
{{ .Values.vault.server.policies | indent 2 }}
{{- end }}

{{- define "vaultconfig.spawnPolicies.mounts" }}
- name: files
  mountPath: /conf/policies.json
  readOnly: true
  subPath: policies.json
{{- end }}

{{- define "vaultconfig.spawnPolicies.script" }}
sleep {{ include "vaultconfig.jobSleepSeconds" . }}

export VAULT_TOKEN=$(kubectl get secret vault-unseal-root-token -n vault -o json | jq -r '.data.root_token | @base64d')

jq -c '.[]' /conf/policies.json | while read policy; do
  policy_name=$(echo $policy | jq -r '.name')
  policy_config=$(echo $policy | jq -cr '.policy')

  echo "$policy_config" | vault policy write $policy_name -
done

echo "POLICIES SEEMS TO BE SPAWNED"
{{- end }}
