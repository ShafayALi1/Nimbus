# Nimbus platform

Where and how Nimbus runs: infrastructure as code, CI, Kubernetes, GitOps, monitoring, security, chaos.
**Everything here is free and runs on your laptop.** The only paid part is `terraform/envs/aws-dev`, and you never run it by accident.

The map of how it all connects is in `nimbus-app/BRAIN.md`.

## Install (once)

1. **Copy the files.** Unzip next to your existing folder so you get `Desktop\Nimbus\nimbus-app` and `Desktop\Nimbus\nimbus-platform`.
   Copying over `nimbus-app` keeps your own files (`LEARN-M0.md`, `CLAUDE.md`, `setup/`); only files with the same name are replaced.
2. **Docker Desktop settings:** Resources → at least **8 GB memory** and 4 CPUs for the full cluster (6 GB works without prod).
   Settings → Resources → WSL integration → turn on your Ubuntu distro.
3. **Tools, in WSL Ubuntu** (open "Ubuntu" from the Start menu):
   ```bash
   cd "<path-to>/nimbus-platform"
   bash scripts/install-tools.sh && source ~/.bashrc
   ```
   Why WSL? kind, Ansible and these scripts are Linux tools, and real servers are Linux. It's also M0's Linux practice.
4. **GitHub:** create two public repos, `nimbus-app` and `nimbus-platform`, and push both (Argo CD reads Git from GitHub).
   First put your GitHub username into the files (runbook links, AWS bucket name):
   ```bash
   grep -rl CHANGE-ME --exclude=README.md . | xargs sed -i "s/CHANGE-ME/<your-github-username-in-lowercase>/g"
   git init -b main && git add . && git commit -m "Nimbus platform" && git remote add origin https://github.com/<you>/nimbus-platform.git && git push -u origin main
   ```

## Run the whole platform

```bash
bash scripts/up.sh        # registry + kind cluster + images + Argo CD; Argo CD installs the rest from Git
```

| URL | What |
|---|---|
| http://nimbus.localtest.me:8088 | the app |
| http://argocd.localtest.me:8088 | Argo CD: every app, its Git state, sync and health |
| http://grafana.localtest.me:8088 | dashboards ("Nimbus overview") and logs (Explore → Loki) |

`up.sh` prints the passwords at the end. `bash scripts/down.sh` deletes the cluster; `up.sh` rebuilds it from Git in about 10 minutes.
That's the "destroy and rebuild from code in under an hour" goal.

Phone access: `bash scripts/public-url.sh` gives a free `https://…trycloudflare.com` link. It's public, so stop it afterwards.

## The pieces, one milestone each

| Milestone | Folder | Start with |
|---|---|---|
| M1–M2 Terraform | `terraform/` | [terraform/README.md](terraform/README.md) |
| M3 Ansible | `ansible/` | [ansible/README.md](ansible/README.md) |
| M4 Jenkins | `ci/jenkins/` | `cp .env.example .env`, fill it in, `docker compose up -d --build`, open http://localhost:8090 |
| M5–M6 Kubernetes + Helm | `kind/`, `helm/` | `kubectl get pods -A`, then read `helm/nimbus-service/templates/_helpers.tpl` |
| M7 GitOps | `gitops/` | change `replicas` in `gitops/envs/dev/worker.yaml`, push, watch Argo CD |
| M8 Observability | `platform/monitoring/`, `platform/logging/` | Grafana → Nimbus overview; Explore → Loki → `{namespace="nimbus-dev"}` |
| M9 Security | `platform/security/` | try `kubectl -n nimbus-dev run bad --image=nginx:latest` and read the error |
| M10 Reliability | `helm/nimbus-service/templates/rollout.yaml` | `kubectl argo rollouts get rollout orders-api -n nimbus-dev --watch` |
| M11 Chaos | `chaos/` | [chaos/README.md](chaos/README.md) |
| M12 Docs | `docs/` | ADRs, runbooks, postmortem template |

## Release flow (what happens on `git push` to nimbus-app)

Jenkins (polls GitHub every 2 min): lint + tests → build → Trivy scan (fails on HIGH/CRITICAL) → integration test →
push `localhost:5001/nimbus/<svc>:<sha>` → commit the new tag to `gitops/envs/dev/*.yaml` here →
Argo CD syncs → orders-api goes out as a canary, and Prometheus decides whether it continues or rolls back.

Promote to prod = a pull request that copies the `tag:` lines from `gitops/envs/dev` to `gitops/envs/prod`.
Turn prod on with `ENVIRONMENTS="dev prod" bash scripts/up.sh` (needs about 1.5 GB more RAM).

## Cost

| Thing | Cost |
|---|---|
| Docker Desktop, kind, Argo CD, Prometheus, Grafana, Loki, Kyverno, Jenkins, Trivy | free |
| LocalStack 4.14 (pinned; newer needs a free account) | free |
| Cloudflare quick tunnel | free, no account |
| GitHub public repos, Actions minutes, GHCR | free for public repos |
| `terraform/envs/aws-dev` | **paid**: RDS ~0.02 USD/h; NAT off by default (it would be ~32 USD/month). Always `terraform destroy` the same day |
