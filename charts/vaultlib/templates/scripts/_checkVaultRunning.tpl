{{- define "vaultlib.checkVaultRunning.script" }}
check-vault-running.sh: |-
  #!/bin/ash
  for attempt in `seq 15`; do
    if [ "$attempt" -eq 15 ]; then
      echo "VAULT NOT REACHABLE"
      exit 1
    elif vault status; then
      echo "VAULT OK EXITING"
      exit 0
    elif [ "$?" = "2" ]; then
      echo "VAULT SEALED"
      exit 0
    else
      echo "sleeping for $attempt"
      sleep "$attempt"
    fi
  done
{{- end }}

{{- define "vaultlib.checkVaultRunning.runner" }}
- name: check-vault-running
  image: "{{- include "vaultlib.clientImage" . }}"
  command: ["/bin/check-vault-running.sh"]
  env:
    - name: VAULT_ADDR
      value: "{{ .Values.vault.server.url }}"
  volumeMounts:
    - name: scripts
      mountPath: /bin/check-vault-running.sh
      readOnly: true
      subPath: check-vault-running.sh
{{- end }}