# Runbook: restore PostgreSQL from backup

A CronJob (`db-backup`) writes `pg_dump` files daily to the `db-backups` volume and keeps 7 days.
**Do this drill once a month and write down how long it took (your RTO). Your RPO is up to 24 h of orders (daily backups).**

```bash
NS=nimbus-dev
kubectl -n $NS create job backup-now --from=cronjob/db-backup     # take a fresh backup first
kubectl -n $NS logs job/backup-now                                  # lists the files
# restore: a temporary pod with the backup volume mounted
kubectl -n $NS run restore --rm -it --restart=Never --image=postgres:16-alpine \
  --overrides='{"spec":{"securityContext":{"runAsNonRoot":true,"runAsUser":70},"containers":[{"name":"restore","image":"postgres:16-alpine","stdin":true,"tty":true,"command":["sh"],"env":[{"name":"PGPASSWORD","valueFrom":{"secretKeyRef":{"name":"nimbus-db","key":"password"}}}],"resources":{"requests":{"cpu":"50m"},"limits":{"memory":"256Mi"}},"securityContext":{"readOnlyRootFilesystem":true},"volumeMounts":[{"name":"b","mountPath":"/backups"}]}],"volumes":[{"name":"b","persistentVolumeClaim":{"claimName":"db-backups"}}]}}' \
  --labels=app.kubernetes.io/name=db-backup
# inside the pod:
#   ls /backups
#   pg_restore -h postgres -U nimbus -d nimbus --clean --if-exists /backups/<file>.dump
```
Compose version: `.\scripts\backup.ps1` and `.\scripts\restore.ps1 backups\<file>.dump` (prints the restore time).
