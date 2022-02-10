{{- define "vaultconfig.spawnRandomSecrets.config" }}
secrets.json: |
{{ .Values.vault.server.randomSecrets | indent 2 }}
{{- end }}

{{- define "vaultconfig.spawnRandomSecrets.mounts" }}
- name: files
  mountPath: /conf/secrets.json
  readOnly: true
  subPath: secrets.json
{{- end }}

{{- define "vaultconfig.spawnRandomSecrets.script" }}
sleep {{ include "vaultconfig.jobSleepSeconds" . }}

export VAULT_TOKEN=$(kubectl get secret vault-unseal-root-token -n vault -o json | jq -r '.data.root_token | @base64d')

jq -c '.[]' /conf/secrets.json | while read secret; do
  secret_path=$(echo $secret | jq -r '.path')
  secret_keys=$(echo $secret | jq -cr '.keys')

  echo '{' > secret.json
  echo $secret_keys | jq -c '.[]' | while read key; do
    echo $key':"'$(pwgen 25 1)'"' >> secret.json
    echo , >> secret.json
  done

  cat secret.json | sed \$d > _secret.json
  echo '}' >> _secret.json

  vault kv put $secret_path @_secret.json
done

echo "SECRETS SEEMS TO BE SPAWNED"
{{- end }}
