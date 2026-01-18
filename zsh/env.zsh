if [[ -d "/opt/homebrew/bin" ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi
if [[ -d "/opt/homebrew/sbin" ]]; then
  export PATH="/opt/homebrew/sbin:$PATH"
fi

if [[ -f "$HOME/.local/bin/env" ]]; then
  . "$HOME/.local/bin/env"
fi
