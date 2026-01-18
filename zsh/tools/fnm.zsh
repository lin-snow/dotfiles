FNM_PATH="/opt/homebrew/opt/fnm/bin"
if [[ -d "$FNM_PATH" ]]; then
  eval "$(fnm env)"
fi
