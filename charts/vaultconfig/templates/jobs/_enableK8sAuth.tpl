{{- define "vaultconfig.enableK8sAuth.config" }}
k8-roles.json: |
{{ .Values.vault.server.k8roles | indent 2 }}
{{- end }}

{{- define "vaultconfig.enableK8sAuth.mounts" }}
- name: files
  mountPath: /conf/k8-roles.json
  readOnly: true
  subPath: k8-roles.json
{{- end }}

{{- define "vaultconfig.enableK8sAuth.script" }}
sleep {{ include "vaultconfig.jobSleepSeconds" . }}

export VAULT_TOKEN=$(kubectl get secret vault-unseal-root-token -n vault -o json | jq -r '.data.root_token | @base64d')

if ! vault auth list | grep kubernetes/ ; then
  vault auth enable kubernetes
fi

vault write auth/kubernetes/config \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    issuer="https://kubernetes.default.svc.cluster.local"

if ! vault auth list | grep kubernetes; then
  echo "SOMETHING WENT WRONG, CAN'T ENABLE KUBERNETES AUTH FOR VAULT"
  exit 1
fi

if vault read auth/kubernetes/config | grep $KUBERNETES_PORT_443_TCP_ADDR; then
  echo "SOMETHING WENT WRONG, CAN'T CONFIGURE KUBERNETES AUTH FOR VAULT"
  exit 1
fi

echo "KUBERNETES AUTH ENABLED FOR VAULT"

jq -c '.[]' /conf/k8-roles.json | while read k8_role; do
  role=$(echo $k8_role | jq -r '.role')
  policy=$(echo $k8_role | jq -r '.policy')
  serviceAccount=$(echo $k8_role | jq -r '.serviceAccount')
  namespace=$(echo $k8_role | jq -r '.namespace')

  if ! vault read auth/kubernetes/role/$role; then
    echo "NO $role ROLE FOUND, CREATING"
    vault write auth/kubernetes/role/$role \
      bound_service_account_names=$serviceAccount \
      bound_service_account_namespaces=$namespace \
      policies=$policy \
      ttl=24h
  else
    echo "EXISTING $role ROLE FOUND, CONFIGURING"
    
    tmpfile=$(mktemp -d)

    vault read auth/kubernetes/role/$role -format=json \
      | jq -r '
        .data
          | .bound_service_account_names |= (.+ [$sa_name] | unique)
          | .bound_service_account_namespaces |= (.+ [$sa_namespace] | unique)
          | .token_policies |= (.+ [$policy] | unique)       
        ' \
        --arg sa_name "$serviceAccount" \
        --arg sa_namespace "$namespace" \
        --arg policy "$policy" \
        | tee > $tmpfile/updated_role.json
    
    vault write auth/kubernetes/role/$role @$tmpfile/updated_role.json
  fi

  sleep {{ include "vaultconfig.jobSleepSeconds" . }}

  role=$(vault read auth/kubernetes/role/$role -format=json \
    | jq -r '.data 
        | select(.bound_service_account_names | contains([$sa_name])) 
        | select(.token_policies | contains([$policy])) 
        | select(.bound_service_account_namespaces | contains([$sa_namespace]))
      ' \
      --arg sa_name "$serviceAccount" \
      --arg sa_namespace "$namespace" \
      --arg policy "$policy"
  )

  if [ "$role" = "" ]; then                                        
    echo "SOMETHING WENT WRONG, CAN'T CONFIGURE VAULT ROLE"
    exit 1 
  fi

  echo "$role ROLE CONFIGURED"
done

echo "KUBERNETES AUTH CONFIGURED FOR VAULT"
{{- end }}

