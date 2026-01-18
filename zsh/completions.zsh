if [[ -z "$_comps" ]]; then
  autoload -Uz compinit
  compinit
fi

if typeset -f __kubectl_completion_init >/dev/null; then
  __kubectl_completion_init
fi
