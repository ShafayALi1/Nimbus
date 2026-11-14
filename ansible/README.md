# Ansible (M3)

Two lab "servers" (Ubuntu 24.04 containers with systemd and SSH) behave like real VMs. Run everything in WSL:

```bash
cd ansible
sh lab/up.sh                     # SSH key + 2 servers + "ansible all -m ping"
ansible-playbook site.yml        # configure both servers
ansible-playbook site.yml        # again: must end with changed=0 (idempotency)
ssh -i lab/.ssh/id_ed25519 -p 2221 deploy@127.0.0.1    # log in as the new deploy user
curl -s localhost:9100/metrics | head   # from inside a node: node_exporter works
```

| Role | Does |
|---|---|
| `common` | base packages, UTC time, `deploy` user with SSH key + sudo, SSH hardening (no root, no passwords; config is tested before reload) |
| `docker` | Docker + Compose from Ubuntu, log rotation, deploy user in the docker group |
| `node_exporter` | download with checksum, non-login system user, hardened systemd unit |

Exercises: change `common_packages`, run twice, read the diff. Encrypt a variable with `ansible-vault encrypt_string`.
Explain where Terraform stops and Ansible starts (Terraform creates the server; Ansible configures what's inside it).
