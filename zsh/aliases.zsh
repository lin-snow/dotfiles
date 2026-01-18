_dotfiles_open() {
  local target="$1"
  if command -v mate >/dev/null 2>&1; then
    mate "$target"
  elif command -v code >/dev/null 2>&1; then
    code "$target"
  elif command -v nvim >/dev/null 2>&1; then
    nvim "$target"
  else
    vim "$target"
  fi
}

alias zshconfig='_dotfiles_open "$HOME/.zshrc"'
alias ohmyzsh='_dotfiles_open "$HOME/.oh-my-zsh"'
