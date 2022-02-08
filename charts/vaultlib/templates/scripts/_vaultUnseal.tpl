{{- define "vaultlib.vaultUnseal.script" }}
vault-unseal.sh: |-
  #!/bin/ash
  apk --update add jq curl
  curl -o /usr/local/bin/kubectl -sLO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
  chmod +x /usr/local/bin/kubectl
  if vault status; then
    echo "VAULT OK EXITING"
    exit 0
  elif [ "$?" = "2" ]; then
    echo "VAULT SEALED"
    for key in `seq 0 $(($VAULT_SECRET_THRESHOLD-1))`; do
      vault operator unseal $(kubectl get secret vault-unseal-key-"$key" -o json | jq -r '.data.unseal_key_'$key' | @base64d')
      sleep 0.5s
    done
  fi
{{- end }}

{{- define "vaultlib.vaultUnseal.container" }}
- name: vault-unseal
  image: {{ include "vaultlib.clientImage" . | quote }}
  command: ['/bin/vault-unseal.sh']
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
      mountPath: /bin/vault-unseal.sh
      readOnly: true
      subPath: vault-unseal.sh
{{- end }}
