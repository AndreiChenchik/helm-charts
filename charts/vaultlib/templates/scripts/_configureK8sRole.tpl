{{- define "vaultlib.configureK8sRole.script" }}
configure-k8s-role.sh: |-
  #!/bin/ash
  apk --update add jq curl
  curl -o /usr/local/bin/kubectl -sLO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
  chmod +x /usr/local/bin/kubectl
  
  export VAULT_TOKEN=$(kubectl get secret vault-unseal-root-token -n vault -o json | jq -r '.data.root_token | @base64d')
  
  if ! vault read auth/kubernetes/role/$VAULT_ROLE; then
    echo "NO VAULT ROLE FOUND, CREATING"
    vault write auth/kubernetes/role/$VAULT_ROLE \
      bound_service_account_names=$VAULT_SA \
      bound_service_account_namespaces=$VAULT_SA_NAMESPACE \
      policies=$VAULT_POLICY \
      ttl=24h
  else
    echo "EXISTING VAULT ROLE FOUND, CONFIGURING"
    
    tmpfile=$(mktemp -d)

    vault read auth/kubernetes/role/$VAULT_ROLE -format=json \
      | jq -r '
        .data
          | .bound_service_account_names |= (.+ [$sa_name] | unique)
          | .bound_service_account_namespaces |= (.+ [$sa_namespace] | unique)
          | .token_policies |= (.+ [$policy] | unique)       
        ' \
        --arg sa_name "$VAULT_SA" \
        --arg sa_namespace "$VAULT_SA_NAMESPACE" \
        --arg policy "$VAULT_POLICY" \
        | > $tmpfile/updated_role.json
    
    vault write auth/kubernetes/role/$VAULT_ROLE @$tmpfile/updated_role.json
  fi

  role=$(vault read auth/kubernetes/role/$VAULT_ROLE -format=json \
    | jq -r '.data 
        | select(.bound_service_account_names | contains([$sa_name])) 
        | select(.token_policies | contains([$policy])) 
        | select(.bound_service_account_namespaces | contains([$sa_namespace]))
      ' \
      --arg sa_name "$VAULT_SA" \
      --arg sa_namespace "$VAULT_SA_NAMESPACE" \
      --arg policy "$VAULT_POLICY"
  )

  if [ ! "$role" = "" ]; then                                        
    echo "VAULT ROLE CONFIGURED"
    exit 0  
  fi

  echo "SOMETHING WENT WRONG, CAN'T CONFIGURE VAULT ROLE"
  exit 1                                                                   
{{- end }}

{{- define "vaultlib.configureK8sRole.container" }}
- name: configure-k8s-role
  image: {{ include "vaultlib.clientImage" . | quote }}
  command: ['/bin/configure-k8s-role.sh']
  env:
    - name: VAULT_ADDR
      value: {{ include "vaultlib.serverUrl" . | quote }}
    - name: KUBECTL_VERSION
      valueFrom:
        configMapKeyRef:
          name: {{ include "vaultlib.configName" . | quote }}
          key: kubectl_version
    - name: VAULT_ROLE
      valueFrom:
        configMapKeyRef:
          name: {{ include "vaultlib.configName" . | quote }}
          key: vault_role
    - name: VAULT_POLICY
      valueFrom:
        configMapKeyRef:
          name: {{ include "vaultlib.configName" . | quote }}
          key: vault_policy
    - name: VAULT_SA
      valueFrom:
        configMapKeyRef:
          name: {{ include "vaultlib.configName" . | quote }}
          key: vault_serviceaccount
    - name: VAULT_SA_NAMESPACE
      valueFrom:
        configMapKeyRef:
          name: {{ include "vaultlib.configName" . | quote }}
          key: vault_serviceaccount_namespace
  volumeMounts:
    - name: scripts
      mountPath: /bin/configure-k8s-role.sh
      readOnly: true
      subPath: configure-k8s-role.sh
{{- end }}
