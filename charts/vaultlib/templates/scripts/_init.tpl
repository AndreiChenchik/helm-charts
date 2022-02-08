{{- define "vaultlib.init.script" }}
vault-init.sh: |-
  #!/bin/ash
  apk --update add jq curl
  if [ $(vault status -format=json | jq '.initialized') = "true" ]; then
    echo "VAULT ALREADY INITIALIZED"
  else
    echo "VAULT INITIALIZING START"
    vault operator init -key-shares=$VAULT_SECRET_SHARES -key-threshold=$VAULT_SECRET_THRESHOLD -format=json | tee vault-init.json
    curl -o /usr/local/bin/kubectl -sLO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
    chmod +x /usr/local/bin/kubectl
    kubectl create secret generic vault-unseal-root-token --from-literal=root_token=$(cat vault-init.json | jq -r '.root_token')
    for key in `seq 0 $(($VAULT_SECRET_SHARES-1))`; do
      kubectl create secret generic vault-unseal-key-"$key" --from-literal=unseal_key_"$key"=$(cat vault-init.json | jq -r '.unseal_keys_b64['$key']')
    done
  fi
{{- end }}

{{- define "vaultlib.init.container" }}
- name: vault-init
  image: {{ include "vaultlib.clientImage" . | quote }}
  command: ['/bin/vault-init.sh']
  env:
    - name: VAULT_ADDR
      value: {{ include "vaultlib.serverUrl" . | quote }}
    - name: KUBECTL_VERSION
      valueFrom:
        configMapKeyRef:
          name: {{ include "vaultlib.configName" . | quote }}
          key: kubectl_version
    - name: VAULT_SECRET_SHARES
      valueFrom:
        configMapKeyRef:
          name: {{ include "vaultlib.configName" . | quote }}
          key: vault_secret_shares
    - name: VAULT_SECRET_THRESHOLD
      valueFrom:
        configMapKeyRef:
          name: {{ include "vaultlib.configName" . | quote }}
          key: vault_secret_threshold
  volumeMounts:
    - name: scripts
      mountPath: /bin/vault-init.sh
      readOnly: true
      subPath: vault-init.sh
{{- end }}
