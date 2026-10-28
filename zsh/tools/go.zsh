if command -v go >/dev/null 2>&1; then
  # 必须用 path 数组追加：typeset -U 只对数组赋值去重，`PATH="$PATH:..."` 会重复追加
  path+=("$(go env GOPATH)/bin")
fi

export CGO_CFLAGS_ALLOW="-Xpreprocessor"
