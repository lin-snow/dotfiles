# bun（BUN_INSTALL 默认 ~/.bun）；补全文件 _bun 由 completions.zsh 在 compinit 之后加载
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
if [[ -d "$BUN_INSTALL/bin" ]]; then
  path=("$BUN_INSTALL/bin" $path)
fi
