{{- define "vaultlib.enableGithubAuth.config" }}
github_org: {{ .Values.vault.server.github.org }}
team-policies.json: |
{{ .Values.vault.server.github.teamPolicies | indent 2 }}
enable-github-auth.sh: |
  #!/bin/ash
  apk --update add jq curl
  curl -o /usr/local/bin/kubectl -sLO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
  chmod +x /usr/local/bin/kubectl
  
  export VAULT_TOKEN=$(kubectl get secret vault-unseal-root-token -n vault -o json | jq -r '.data.root_token | @base64d')
  
  if ! vault auth list | grep github/ ; then
    vault auth enable github
  fi

  if vault auth list | grep github/ ; then
    vault write auth/github/config organization=$GITHUB_ORG
  fi

  jq -c '.[]' /conf/team-policies.json | while read $team_policy; do
    team_name=$(echo $team_policy | jq -r '.team')
    policy_name=$(echo $team_policy | jq -r '.policy')

    vault write auth/github/map/teams/$team_name value=$policy_name
  done

  if vault auth list | grep kubernetes; then
    if vault read auth/github/config | grep $GITHUB_ORG; then
      echo "GITHUB AUTH ENABLED FOR VAULT"
      exit 0
    fi
  fi

  echo "SOMETHING WENT WRONG, CAN'T ENABLE GITHUB AUTH FOR VAULT"
  exit 1
{{- end }}

{{- define "vaultlib.enableGithubAuth.container" }}
- name: enable-github-auth
  image: {{ include "vaultlib.clientImage" . | quote }}
  command: ['/bin/enable-github-auth.sh']
  env:
    - name: VAULT_ADDR
      value: {{ include "vaultlib.serverUrl" . | quote }}
    - name: KUBECTL_VERSION
      valueFrom:
        configMapKeyRef:
          name: {{ include "vaultlib.configName" . | quote }}
          key: kubectl_version
    - name: GITHUB_ORG
      valueFrom:
        configMapKeyRef:
          name: {{ include "vaultlib.configName" . | quote }}
          key: github_org
  volumeMounts:
    - name: files
      mountPath: /bin/enable-github-auth.sh
      readOnly: true
      subPath: enable-github-auth.sh
    - name: files
      mountPath: /conf/team-policies.json
      readOnly: true
      subPath: team-policies.json
{{- end }}
