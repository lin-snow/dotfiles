DOCKER_COMPLETIONS_DIR="$HOME/.docker/completions"
if [[ -d "$DOCKER_COMPLETIONS_DIR" ]]; then
  fpath=("$DOCKER_COMPLETIONS_DIR" $fpath)
fi
