{{- define "vaultconfig.enableGithubAuth.config" }}
github-org: {{ .Values.vault.server.githubAuth.org }}
github-team-policies.json: |
{{ .Values.vault.server.githubAuth.teamPolicies | indent 2 }}
{{- end }}

{{- define "vaultconfig.enableGithubAuth.envs" }}
- name: GITHUB_ORG
  valueFrom:
    configMapKeyRef:
      name: {{ include "vaultconfig.defaultResourceName" . | quote }}
      key: github-org
{{- end }}

{{- define "vaultconfig.enableGithubAuth.mounts" }}
- name: files
  mountPath: /conf/github-team-policies.json
  readOnly: true
  subPath: github-team-policies.json
{{- end }}

{{- define "vaultconfig.enableGithubAuth.script" }}
sleep {{ include "vaultconfig.jobSleepSeconds" . }}

export VAULT_TOKEN=$(kubectl get secret vault-unseal-root-token -n vault -o json | jq -r '.data.root_token | @base64d')

if ! vault auth list | grep github/ ; then
  vault auth enable github
fi

if vault auth list | grep github/ ; then
  vault write auth/github/config organization=$GITHUB_ORG
fi

jq -c '.[]' /conf/github-team-policies.json | while read team_policy; do
  team_name=$(echo $team_policy | jq -r '.team')
  policy_name=$(echo $team_policy | jq -r '.policy')

  vault write auth/github/map/teams/$team_name value=$policy_name
done

if ! vault auth list | grep github/; then
  echo "SOMETHING WENT WRONG, CAN'T ENABLE GITHUB AUTH FOR VAULT"
  exit 1
fi

if ! vault read auth/github/config | grep $GITHUB_ORG; then
  echo "SOMETHING WENT WRONG, CAN'T CONFIGURE GITHUB AUTH FOR VAULT"
  exit 1
fi

echo "GITHUB AUTH ENABLED FOR VAULT"
{{- end }}


