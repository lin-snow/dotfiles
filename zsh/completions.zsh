if [[ -z "$_comps" ]]; then
  autoload -Uz compinit
  compinit
fi

# bun 自带补全文件末尾会调用 compdef，必须在 compinit 之后加载
[[ -f "${BUN_INSTALL:-$HOME/.bun}/_bun" ]] && source "${BUN_INSTALL:-$HOME/.bun}/_bun"

if typeset -f __kubectl_completion_init >/dev/null; then
  __kubectl_completion_init
fi
