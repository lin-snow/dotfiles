#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf "%s\n" "$*"; }
warn() { printf "WARN: %s\n" "$*" >&2; }
die() { printf "ERROR: %s\n" "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
用法：
  ./bootstrap.sh                 # 默认：仅应用配置（链接 ~/.zshrc），不做任何安装/更新
  ./bootstrap.sh --install       # 额外：安装/更新 OMZ/插件 + 安装 CLI（brew）
  ./bootstrap.sh --link-only     # 仅链接 ~/.zshrc（不做其它事）

可选项：
  --install        启用安装/更新逻辑（需要 git；安装 CLI 需要 brew）
  --skip-omz       安装模式下跳过 OMZ/主题/插件
  --skip-brew      安装模式下跳过 brew 包安装
  --skip-docker    安装模式下跳过 docker cask（避免下载/交互）
  --setup-fzf      生成 ~/.fzf.zsh（如果存在 brew 的 fzf install 脚本）
  -h, --help       显示帮助
EOF
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "缺少命令：$1"
}

backup_if_exists() {
  local path="$1"
  if [[ -e "$path" || -L "$path" ]]; then
    local ts
    ts="$(date +%Y%m%d-%H%M%S)"
    mv "$path" "${path}.bak.${ts}"
    log "已备份：$path -> ${path}.bak.${ts}"
  fi
}

symlink_zshrc() {
  local target="${HOME}/.zshrc"
  local source="${DOTFILES_DIR}/.zshrc"

  [[ -f "$source" ]] || die "找不到：$source"

  if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
    log "已是正确链接：$target -> $source"
    return 0
  fi

  backup_if_exists "$target"
  ln -s "$source" "$target"
  log "已链接：$target -> $source"
}

DO_INSTALL=0
DO_LINK_ONLY=0
SKIP_OMZ=0
SKIP_BREW=0
SKIP_DOCKER=0
DO_SETUP_FZF=0

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --install|install) DO_INSTALL=1; shift ;;
      --link-only|link-only) DO_LINK_ONLY=1; shift ;;
      --skip-omz) SKIP_OMZ=1; shift ;;
      --skip-brew) SKIP_BREW=1; shift ;;
      --skip-docker) SKIP_DOCKER=1; shift ;;
      --setup-fzf) DO_SETUP_FZF=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *)
        die "未知参数：$1（使用 -h 查看帮助）"
        ;;
    esac
  done
}

install_homebrew_hint() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi
  warn "未检测到 Homebrew（brew）。建议先安装："
  warn "  参考：https://brew.sh/"
  return 1
}

brew_install() {
  local pkg="$1"
  if command -v brew >/dev/null 2>&1; then
    if brew list --formula "$pkg" >/dev/null 2>&1; then
      log "已安装（brew）：$pkg"
    else
      log "安装（brew）：$pkg"
      brew install "$pkg"
    fi
  else
    warn "跳过安装 $pkg（未安装 brew）"
  fi
}

brew_install_cask() {
  local cask="$1"
  if command -v brew >/dev/null 2>&1; then
    if brew list --cask "$cask" >/dev/null 2>&1; then
      log "已安装（brew cask）：$cask"
    else
      log "安装（brew cask）：$cask"
      brew install --cask "$cask"
    fi
  else
    warn "跳过安装 cask $cask（未安装 brew）"
  fi
}

docker_desktop_exists() {
  # 如果用户不是通过 brew 安装的 Docker Desktop，brew 无法感知；
  # 这里用系统侧的存在性判断来避免重复下载。
  if [[ -d "/Applications/Docker.app" || -d "$HOME/Applications/Docker.app" ]]; then
    return 0
  fi
  if command -v open >/dev/null 2>&1 && open -Ra Docker >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

git_clone_or_update() {
  local repo="$1"
  local dest="$2"

  if [[ -d "$dest/.git" ]]; then
    log "更新：$dest"
    git -C "$dest" pull --ff-only
    return 0
  fi
  if [[ -e "$dest" ]]; then
    warn "目标已存在但不是 git 仓库，跳过：$dest"
    return 0
  fi
  log "克隆：$repo -> $dest"
  git clone --depth 1 "$repo" "$dest"
}

install_oh_my_zsh_and_plugins() {
  need_cmd git

  local zsh_dir="${HOME}/.oh-my-zsh"
  local zsh_custom="${ZSH_CUSTOM:-${zsh_dir}/custom}"

  git_clone_or_update "https://github.com/ohmyzsh/ohmyzsh.git" "$zsh_dir"

  mkdir -p "${zsh_custom}/themes" "${zsh_custom}/plugins"

  git_clone_or_update "https://github.com/romkatv/powerlevel10k.git" "${zsh_custom}/themes/powerlevel10k"
  git_clone_or_update "https://github.com/zsh-users/zsh-autosuggestions.git" "${zsh_custom}/plugins/zsh-autosuggestions"
  git_clone_or_update "https://github.com/zsh-users/zsh-syntax-highlighting.git" "${zsh_custom}/plugins/zsh-syntax-highlighting"
}

install_cli_tools() {
  if [[ "$SKIP_BREW" -eq 1 ]]; then
    return 0
  fi
  if ! install_homebrew_hint; then
    return 0
  fi

  brew_install fzf
  brew_install fnm
  brew_install kubectl
  brew_install go
  brew_install yazi

  # Docker：补全会自动读取 ~/.docker/completions。Docker Desktop 更常见（带 daemon）。
  if [[ "$SKIP_DOCKER" -ne 1 ]]; then
    if docker_desktop_exists; then
      log "已检测到 Docker Desktop（非 brew 也可），跳过 brew cask docker"
    else
      brew_install_cask docker || true
    fi
  fi

  # fzf 的 ~/.fzf.zsh 生成放到 --setup-fzf 显式触发，避免默认改动用户环境
}

setup_fzf_if_requested() {
  if [[ "$DO_SETUP_FZF" -ne 1 ]]; then
    return 0
  fi
  if ! command -v brew >/dev/null 2>&1; then
    warn "跳过 fzf setup（未安装 brew）"
    return 0
  fi
  local fzf_install
  fzf_install="$(brew --prefix)/opt/fzf/install"
  if [[ -x "$fzf_install" ]]; then
    log "配置 fzf（生成 ~/.fzf.zsh / 补全 / keybindings）"
    "$fzf_install" --key-bindings --completion --no-update-rc --no-bash --no-fish
  else
    warn "未找到 fzf install 脚本：$fzf_install"
  fi
}

install_docker_completion_if_possible() {
  if command -v docker >/dev/null 2>&1; then
    mkdir -p "${HOME}/.docker/completions"
    docker completion zsh > "${HOME}/.docker/completions/_docker" || true
    log "已生成 docker zsh 补全：~/.docker/completions/_docker"
  fi
}

main() {
  parse_args "$@"
  log "dotfiles: ${DOTFILES_DIR}"
  symlink_zshrc

  if [[ "$DO_LINK_ONLY" -eq 1 ]]; then
    log ""
    log "完成（link-only）。你可以执行："
    log "  exec zsh -l"
    return 0
  fi

  if [[ "$DO_INSTALL" -eq 1 ]]; then
    if [[ "$SKIP_OMZ" -ne 1 ]]; then
      install_oh_my_zsh_and_plugins
    fi
    install_cli_tools
    setup_fzf_if_requested
  fi

  install_docker_completion_if_possible

  log ""
  log "完成。请执行："
  log "  exec zsh -l"
  log "或重启终端。"
}

main "$@"

