{{- define "vaultlib.cleanup.script" }}
cleanup.sh: |-
  #!/bin/ash
  apk --update add jq curl
  curl -o /usr/local/bin/kubectl -sLO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
  chmod +x /usr/local/bin/kubectl
  {{- if .Values.vault.jobs.cleanup }}
  kubectl delete po -l job-name={{ include "vaultlib.jobName" . | quote }}
  {{- end }}
{{- end }}

{{- define "vaultlib.cleanup.runner" }}
- name: check-vault-cleanup
  image: {{ include "vaultlib.clientImage" . | quote }}
  command: ['/bin/cleanup.sh']
  env:
    - name: KUBECTL_VERSION
      valueFrom:
        configMapKeyRef:
          name: {{ include "vaultlib.configName" . | quote }}
          key: kubectl_version
  volumeMounts:
    - name: scripts
      mountPath: /bin/cleanup.sh
      readOnly: true
      subPath: cleanup.sh
{{- end }}