if command -v fastfetch >/dev/null 2>&1; then
  # 主题配置由仓库管理：fastfetch/config.jsonc
  if [[ -n "${ZSH_DOTDIR:-}" ]]; then
    FASTFETCH_CONFIG="${ZSH_DOTDIR:A:h}/fastfetch/config.jsonc"
  else
    FASTFETCH_CONFIG="$HOME/.dotfiles/fastfetch/config.jsonc"
  fi
  if [[ -f "$FASTFETCH_CONFIG" ]]; then
    alias fastfetch='command fastfetch --config "$FASTFETCH_CONFIG"'
  fi
fi
