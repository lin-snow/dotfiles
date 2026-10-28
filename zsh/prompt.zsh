# 提示符：Starship。配置文件为 ~/.config/starship.toml（可选，默认内置配置即可用）
# starship 缺失时不接管 prompt，保留 zsh 默认提示符（不会启动失败）
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
