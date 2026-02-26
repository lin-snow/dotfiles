if command -v fastfetch >/dev/null 2>&1; then
  FASTFETCH_CONFIG="/opt/homebrew/share/fastfetch/presets/examples/27.jsonc"
  if [[ -f "$FASTFETCH_CONFIG" ]]; then
    alias fastfetch='command fastfetch --config "$FASTFETCH_CONFIG"'
  fi
fi
