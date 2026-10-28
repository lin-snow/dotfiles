# zsh 入口；~/.zshrc 应为本文件的 symlink（见 bootstrap.sh）

# ========== Prompt Switch ==========
# starship | p10k
: "${PROMPT_ENGINE:=starship}"

# Enable Powerlevel10k instant prompt (only when using p10k).
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ "$PROMPT_ENGINE" == "p10k" ]] && [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load dotfiles zsh config
DOTFILES_DIR="${${(%):-%N}:A:h}"
# ~/.zshrc 本应是本文件的 symlink；若被第三方安装器覆盖成普通副本，:A 会停在 $HOME，这里回退
[[ -d "$DOTFILES_DIR/zsh" ]] || DOTFILES_DIR="$HOME/.dotfiles"
[[ -f "$DOTFILES_DIR/zsh/zshrc" ]] && source "$DOTFILES_DIR/zsh/zshrc"
