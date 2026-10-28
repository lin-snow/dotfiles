alias k="kubectl"

# `source <(kubectl completion zsh)` 每次启动约 70~90ms；缓存到 XDG_CACHE_HOME，
# kubectl 自身更新（可执行文件比缓存新）时自动重建。
__kubectl_completion_init() {
  command -v kubectl >/dev/null 2>&1 || return 0

  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/kubectl-completion.zsh"
  if [[ ! -s "$cache" ]] || [[ "$(command -v kubectl)" -nt "$cache" ]]; then
    mkdir -p "${cache:h}"
    kubectl completion zsh >| "$cache" 2>/dev/null || { rm -f "$cache"; return 0; }
  fi

  source "$cache"
  compdef k=kubectl
}
