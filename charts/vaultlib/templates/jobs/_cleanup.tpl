{{- define "vaultlib.cleanup.config" }}
cleanup.sh: |-
  #!/bin/ash
  apk --update add jq curl
  curl -o /usr/local/bin/kubectl -sLO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
  chmod +x /usr/local/bin/kubectl
  {{- if .Values.vault.server.configure.cleanup }}
  kubectl delete po -l job-name={{ include "vaultlib.configure.jobName" . | quote }}
  {{- end }}
{{- end }}

{{- define "vaultlib.cleanup.container" }}
- name: cleanup
  image: {{ include "vaultlib.configure.container.image" . | quote }}
  command: ['/bin/cleanup.sh']
  env:
    - name: KUBECTL_VERSION
      valueFrom:
        configMapKeyRef:
          name: {{ include "vaultlib.configure.configName" . | quote }}
          key: kubectl_version
  volumeMounts:
    - name: files
      mountPath: /bin/cleanup.sh
      readOnly: true
      subPath: cleanup.sh
{{- end }}
