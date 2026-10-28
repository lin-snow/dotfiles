# zsh 入口；~/.zshrc 应为本文件的 symlink（见 bootstrap.sh）

# Load dotfiles zsh config
DOTFILES_DIR="${${(%):-%N}:A:h}"
# ~/.zshrc 本应是本文件的 symlink；若被第三方安装器覆盖成普通副本，:A 会停在 $HOME，这里回退
[[ -d "$DOTFILES_DIR/zsh" ]] || DOTFILES_DIR="$HOME/.dotfiles"
[[ -f "$DOTFILES_DIR/zsh/zshrc" ]] && source "$DOTFILES_DIR/zsh/zshrc"
