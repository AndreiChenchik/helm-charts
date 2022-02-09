{{- define "vaultlib.spawnRandomSecrets.config" }}
secrets.json: |
{{ .Values.vault.app.secrets | indent 2 }}
spawn-random-secrets.sh: |
  #!/bin/ash
  apk --update add jq curl pwgen
  curl -o /usr/local/bin/kubectl -sLO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
  chmod +x /usr/local/bin/kubectl
  
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

    vault write $secret_path @_secret.json
  done

  echo "SECRETS SEEMS TO BE SPAWNED"
{{- end }}

{{- define "vaultlib.spawnRandomSecrets.container" }}
- name: spawn-random-secrets
  image: {{ include "vaultlib.clientImage" . | quote }}
  command: ['/bin/spawn-random-secrets.sh']
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
      mountPath: /bin/spawn-random-secrets.sh
      readOnly: true
      subPath: spawn-random-secrets.sh
    - name: files
      mountPath: /conf/secrets.json
      readOnly: true
      subPath: secrets.json
{{- end }}
