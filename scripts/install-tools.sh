#!/usr/bin/env bash
# Install the CLI tools into ~/.local/bin (run inside WSL Ubuntu). Safe to run again.
set -euo pipefail
BIN="$HOME/.local/bin"; mkdir -p "$BIN"; export PATH="$BIN:$PATH"   # so the tools work right away
ARCH=$(uname -m | sed 's/x86_64/amd64/; s/aarch64/arm64/')
KIND_VERSION=v0.33.0

echo "kind $KIND_VERSION";  curl -fsSLo "$BIN/kind" "https://kind.sigs.k8s.io/dl/$KIND_VERSION/kind-linux-$ARCH"
K8S=$(curl -fsSL https://dl.k8s.io/release/stable.txt)
echo "kubectl $K8S";       curl -fsSLo "$BIN/kubectl" "https://dl.k8s.io/release/$K8S/bin/linux/$ARCH/kubectl"
echo "argo rollouts plugin"; curl -fsSLo "$BIN/kubectl-argo-rollouts" \
  "https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-$ARCH"
chmod +x "$BIN"/kind "$BIN"/kubectl "$BIN"/kubectl-argo-rollouts
echo "helm";               curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | HELM_INSTALL_DIR="$BIN" USE_SUDO=false bash
command -v ansible >/dev/null || { echo "ansible"; sudo apt-get update -qq && sudo apt-get install -y -qq pipx && pipx install ansible-core && pipx install ansible-lint && pipx ensurepath; }
grep -qs '.local/bin' ~/.bashrc || { echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc; echo "Added ~/.local/bin to ~/.bashrc. Run: source ~/.bashrc"; }
echo "Done. Check: kind version && kubectl version --client && helm version"
