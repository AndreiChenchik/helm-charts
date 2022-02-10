{{- define "vaultconfig.unseal.script" }}
sleep {{ include "vaultconfig.jobSleepSeconds" . }}

if vault status; then
  echo "VAULT OK"
elif [ "$?" = "2" ]; then
  echo "VAULT SEALED"
  for key in `seq 0 $(($VAULT_SECRET_THRESHOLD-1))`; do
    vault operator unseal $(kubectl get secret vault-unseal-key-"$key" -o json | jq -r '.data.unseal_key_'$key' | @base64d')
    sleep 0.5s
  done
fi
{{- end }}
