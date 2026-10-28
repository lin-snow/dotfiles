# 环境变量与 PATH 管理
# typeset -U：path 与 PATH 绑定，去重后重复目录只保留首次出现（避免嵌套 shell 里 PATH 无限变长）
typeset -gU path

if [[ -d "/opt/homebrew/bin" ]]; then
  path=("/opt/homebrew/bin" $path)
fi
if [[ -d "/opt/homebrew/sbin" ]]; then
  path=("/opt/homebrew/sbin" $path)
fi

# brew 的 curl 优先于系统 curl（brew install curl 后生效）
if [[ -d "/opt/homebrew/opt/curl/bin" ]]; then
  path=("/opt/homebrew/opt/curl/bin" $path)
fi

# 用户级本地 bin（omp / claude / uv 等），优先级高于 homebrew
if [[ -d "$HOME/.local/bin" ]]; then
  path=("$HOME/.local/bin" $path)
fi
