# oMLX CLI shim（原由 oMLX/magpie 直接注入 ~/.zshrc，改为 dotfiles 托管）
if [[ -d "$HOME/.omlx/bin" ]]; then
  path=("$HOME/.omlx/bin" $path)
fi
