{{- define "vaultlib.enableKVEngine.config" }}
vault_kv_endpoint: {{ include "vaultlib.kvEndpoint" . | quote }}
enable-kv-engine.sh: |-
  #!/bin/ash
  apk --update add jq curl
  curl -o /usr/local/bin/kubectl -sLO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
  chmod +x /usr/local/bin/kubectl
  
  export VAULT_TOKEN=$(kubectl get secret vault-unseal-root-token -n vault -o json | jq -r '.data.root_token | @base64d')
  
  kv_endpoint=$(vault secrets list -format=json \
    | jq -r 'to_entries[]
        | select((.value.type=="kv") and (.key==$kv_path))
      ' \
      --arg kv_path "$KV_ENDPOINT/"
  )

  if [ ! "$kv_endpoint" = "" ]; then
    echo "KV ENGINE ALREADY CONFIGURED AT $KV_ENDPOINT/"
    exit 0
  fi

  vault secrets enable -path=$KV_ENDPOINT kv

  kv_endpoint=$(vault secrets list -format=json \
    | jq -r 'to_entries[]
        | select((.value.type=="kv") and (.key==$kv_path))
      ' \
      --arg kv_path "$KV_ENDPOINT/"
  )

  if [ ! "$kv_endpoint" = "" ]; then
    echo "KV ENGINE ENABLED AT $KV_ENDPOINT/"
    exit 0
  fi

  echo "SOMETHING WENT WRONG, CAN'T ENABLE KV ENGINE AT $KV_ENDPOINT/"
  exit 1                                                                   
{{- end }}

{{- define "vaultlib.enableKVEngine.container" }}
- name: enable-kv-engine
  image: {{ include "vaultlib.configure.container.image" . | quote }}
  command: ['/bin/enable-kv-engine.sh']
  env:
    - name: VAULT_ADDR
      value: {{ include "vaultlib.serverUrl" . | quote }}
    - name: KUBECTL_VERSION
      valueFrom:
        configMapKeyRef:
          name: {{ include "vaultlib.configure.configName" . | quote }}
          key: kubectl_version
    - name: KV_ENDPOINT
      valueFrom:
        configMapKeyRef:
          name: {{ include "vaultlib.configure.configName" . | quote }}
          key: vault_kv_endpoint
  volumeMounts:
    - name: files
      mountPath: /bin/enable-kv-engine.sh
      readOnly: true
      subPath: enable-kv-engine.sh
{{- end }}
