alias k="kubectl"

__kubectl_completion_init() {
  if command -v kubectl >/dev/null 2>&1; then
    compdef k=kubectl
    source <(kubectl completion zsh)
  fi
}
