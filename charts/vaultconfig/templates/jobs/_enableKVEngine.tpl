{{- define "vaultconfig.enableKVEngine.config" }}
vault_kv_endpoint: {{ include "vaultconfig.kvEndpoint" . | quote }}
{{- end }}

{{- define "vaultconfig.enableKVEngine.script" }}
sleep {{ include "vaultconfig.jobSleepSeconds" . }}

export VAULT_TOKEN=$(kubectl get secret vault-unseal-root-token -n vault -o json | jq -r '.data.root_token | @base64d')

kv_endpoint=$(vault secrets list -format=json \
  | jq -r 'to_entries[]
      | select((.value.type=="kv") and (.key==$kv_path))
    ' \
    --arg kv_path "$KV_ENDPOINT/"
)

if [ "$kv_endpoint" = "" ]; then
  vault secrets enable -path=$KV_ENDPOINT kv-v2
else
  echo "KV ENGINE ALREADY CONFIGURED AT $KV_ENDPOINT/"
fi

kv_endpoint=$(vault secrets list -format=json \
  | jq -r 'to_entries[]
      | select((.value.type=="kv") and (.key==$kv_path))
    ' \
    --arg kv_path "$KV_ENDPOINT/"
)

if [ "$kv_endpoint" = "" ]; then
  echo "SOMETHING WENT WRONG, CAN'T ENABLE KV ENGINE AT $KV_ENDPOINT/"
  exit 1 
fi

echo "KV ENGINE ENABLED AT $KV_ENDPOINT/"                                                                  
{{- end }}

{{- define "vaultconfig.enableKVEngine.envs" }}
- name: KV_ENDPOINT
  valueFrom:
    configMapKeyRef:
      name: {{ include "vaultconfig.defaultResourceName" . | quote }}
      key: vault_kv_endpoint
{{- end }}
