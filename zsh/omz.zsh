export ZSH="$HOME/.oh-my-zsh"
if [[ "${PROMPT_ENGINE:-starship}" == "p10k" ]]; then
  ZSH_THEME="powerlevel10k/powerlevel10k"
else
  # Starship 会自己初始化 prompt，这里不要让 OMZ 主题接管 prompt
  ZSH_THEME=""
fi

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  z
)

if [[ -d "$ZSH" && -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi
