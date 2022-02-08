{{- define "vaultlib.enableK8sAuth.script" }}
enable-k8s-auth.sh: |-
  #!/bin/ash
  apk --update add jq curl
  curl -o /usr/local/bin/kubectl -sLO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
  chmod +x /usr/local/bin/kubectl
  
  export VAULT_TOKEN=$(kubectl get secret vault-unseal-root-token -n vault -o json | jq -r '.data.root_token | @base64d')
  
  if ! vault auth list | grep kubernetes/ ; then
    vault auth enable kubernetes
  fi

  if vault auth list | grep kubernetes/ ; then
    vault write auth/kubernetes/config \
        kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
        token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
        kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
        issuer="https://kubernetes.default.svc.cluster.local"
  fi

  if vault auth list | grep kubernetes; then
    if vault read auth/kubernetes/config | grep $KUBERNETES_PORT_443_TCP_ADDR; then
      echo "KUBERNETES AUTH ENABLED FOR VAULT"
      exit 0
    fi
  fi

  echo "SOMETHING WENT WRONG, CAN'T ENABLE KUBERNETES AUTH FOR VAULT"
  exit 1
{{- end }}

{{- define "vaultlib.enableK8sAuth.container" }}
- name: enable-k8s-auth
  image: {{ include "vaultlib.clientImage" . | quote }}
  command: ['/bin/enable-k8s-auth.sh']
  env:
    - name: VAULT_ADDR
      value: {{ include "vaultlib.serverUrl" . | quote }}
    - name: KUBECTL_VERSION
      valueFrom:
        configMapKeyRef:
          name: {{ include "vaultlib.configName" . | quote }}
          key: kubectl_version
  volumeMounts:
    - name: scripts
      mountPath: /bin/enable-k8s-auth.sh
      readOnly: true
      subPath: enable-k8s-auth.sh
{{- end }}
