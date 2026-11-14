# A tiny "server": Ubuntu 24.04 with systemd and SSH, so Ansible behaves exactly as on a real VM.
FROM ubuntu:24.04
RUN apt-get update \
 && apt-get install -y --no-install-recommends systemd systemd-sysv openssh-server sudo python3 \
 && rm -rf /var/lib/apt/lists/* \
 && systemctl enable ssh \
 && useradd -m -s /bin/bash ansible \
 && echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
COPY --chown=ansible:ansible .ssh/id_ed25519.pub /home/ansible/.ssh/authorized_keys
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
