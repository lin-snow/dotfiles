DOCKER_COMPLETIONS_DIR="/Users/l1nsn0w/.docker/completions"
if [[ -d "$DOCKER_COMPLETIONS_DIR" ]]; then
  fpath=("$DOCKER_COMPLETIONS_DIR" $fpath)
fi
