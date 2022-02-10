{{- define "vaultconfig.cleanup.script" }}
sleep {{ include "vaultconfig.jobSleepSeconds" . }}

kubectl delete po -l job-name={{ include "vaultconfig.defaultResourceName" . | quote }}
{{- end }}
