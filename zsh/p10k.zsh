PROMPT_ENGINE="${PROMPT_ENGINE:-starship}"

if [[ "$PROMPT_ENGINE" == "starship" ]]; then
  if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
  elif [[ -f "$HOME/.p10k.zsh" ]]; then
    # starship 未安装时，自动回退到 p10k（避免无 prompt）
    source "$HOME/.p10k.zsh"
  fi
else
  [[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
fi
