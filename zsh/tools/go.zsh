if command -v go >/dev/null 2>&1; then
  export PATH="$PATH:$(go env GOPATH)/bin"
fi

export CGO_CFLAGS_ALLOW="-Xpreprocessor"
