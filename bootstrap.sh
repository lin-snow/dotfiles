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
  ./bootstrap.sh --install       # 额外：安装/更新 OMZ/插件 + 按 Brewfile 安装 CLI
  ./bootstrap.sh --link-only     # 仅链接 ~/.zshrc（不做其它事）

可选项：
  --install        启用安装/更新逻辑（需要 git；安装 CLI 需要 brew）
  --skip-omz       安装模式下跳过 OMZ/主题/插件
  --skip-brew      安装模式下跳过 Brewfile 安装
  --skip-docker    安装模式下跳过 docker cask（避免下载/交互）
  --setup-fzf      生成 ~/.fzf.zsh（如果存在 brew 的 fzf install 脚本）
  -h, --help       显示帮助

包列表的唯一来源是仓库内 Brewfile（`brew bundle --file=...`）。
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

docker_engine_available() {
  # Docker Desktop / OrbStack / Rancher Desktop 等自带 daemon 的发行版；
  # brew 只能感知自己装的 cask，这里用系统侧存在性判断避免重复下载。
  local app
  for app in Docker OrbStack "Rancher Desktop"; do
    if [[ -d "/Applications/${app}.app" || -d "$HOME/Applications/${app}.app" ]]; then
      return 0
    fi
    if command -v open >/dev/null 2>&1 && open -Ra "$app" >/dev/null 2>&1; then
      return 0
    fi
  done
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

  mkdir -p "${zsh_custom}/plugins"

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

  local brewfile="${DOTFILES_DIR}/Brewfile"
  [[ -f "$brewfile" ]] || die "找不到：$brewfile"

  # Docker 有 GUI 发行版（Docker Desktop / OrbStack）时不装 cask，避免重复下载。
  if [[ "$SKIP_DOCKER" -eq 1 ]] || docker_engine_available; then
    export HOMEBREW_BUNDLE_CASK_SKIP="docker"
    log "跳过 brew cask docker（已检测到本地 Docker 发行版）"
  fi

  log "安装 brew 包（缺失项）：$brewfile"
  # --no-upgrade：只补缺失项，不隐式升级已安装的包
  env HOMEBREW_NO_ENV_HINTS=1 HOMEBREW_NO_INSTALL_CLEANUP=1 \
    brew bundle install --file "$brewfile" --no-upgrade
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

