[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# 统一观感：底部弹出、反向列表、边框
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"

# 用 fd 作为候选来源（速度更快，默认遵守 .gitignore）
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# Ctrl-T 预览：目录用 eza 列表，文件用 bat 高亮
if command -v bat >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then eza -la --icons=auto --group-directories-first {} 2>/dev/null || ls -la {}; else bat --style=numbers --color=always --line-range=:200 {} 2>/dev/null; fi'"
fi
