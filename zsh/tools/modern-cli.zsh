# 现代 CLI 工具：fd / eza / bat / ripgrep / zoxide
# 由 Brewfile 安装；缺少某个 CLI 时静默跳过，不影响 shell 启动。

# --- eza：取代 ls ---
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -lh --icons=auto --group-directories-first --git'
  alias la='eza -lah --icons=auto --group-directories-first --git'
  alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
fi

# --- bat：带语法高亮/行号的 cat ---
if command -v bat >/dev/null 2>&1; then
  # auto：按终端背景自动选浅色/深色主题
  export BAT_THEME="${BAT_THEME:-auto}"
  # -F 短文件不分页，-R 保留颜色，-X 退出后不清屏
  export BAT_PAGER="${BAT_PAGER:-less -FRX}"
  # 仅交互式替换；需要原生行为时用 `command cat`
  alias cat='bat --paging=never'
fi

# --- zoxide：z <关键字> 跳转，zi 走 fzf 交互选择 ---
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
