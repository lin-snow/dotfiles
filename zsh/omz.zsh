export ZSH="$HOME/.oh-my-zsh"

# Starship 负责 prompt（见 prompt.zsh），不要让 OMZ 主题接管 prompt
ZSH_THEME=""

# 不启用 z 插件：z/zi 由 zoxide 提供（见 tools/modern-cli.zsh）
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

if [[ -d "$ZSH" && -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi
