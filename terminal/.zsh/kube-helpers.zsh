# location: $HOME/.zsh/kube-helpers.zsh

# =========================
# Kubernetes helper state
# =========================
export ACTIVE_CONTEXT="${ACTIVE_CONTEXT:-pa-uk-rail-nonprod}"
export ACTIVE_NAMESPACE="${ACTIVE_NAMESPACE:-pa-staging}"
export ACTIVE_POD="${ACTIVE_POD:-}"
export ACTIVE_CONTAINER="${ACTIVE_CONTAINER:-}"


# =========================
# Internal helpers
# =========================

_kube_kubectl() {
  kubectl ${ACTIVE_CONTEXT:+--context="$ACTIVE_CONTEXT"} "$@"
}

_kube_current_context() {
  if [[ -n "$ACTIVE_CONTEXT" ]]; then
    echo "$ACTIVE_CONTEXT"
  else
    kubectl config current-context 2>/dev/null
  fi
}

_kube_is_production() {
  local ctx="$(_kube_current_context)"
  local ns="$ACTIVE_NAMESPACE"

  [[ "$ctx" == *production* || "$ns" == *production* ]]
}

_kube_prod_colour_on() {
  if _kube_is_production; then
    printf "\033]11;%s\007" "$PROD_TERM_BG" 2>/dev/null
  fi
}

_kube_prod_colour_off() {
  printf "\033]11;%s\007" "$DEFAULT_TERM_BG" 2>/dev/null
}

_kube_prod_color_reset() {
    if _kube_is_production; then
        _kube_prod_colour_on
    else
        _kube_prod_colour_off
    fi
}

_kube_confirm_prod() {
  local ctx="$(_kube_current_context)"
  local ns="$ACTIVE_NAMESPACE"

  if _kube_is_production; then
    echo
    print -P "%F{red}%B⚠️  PRODUCTION [$ctx:$ns] ⚠️%b%f"
    read "?Continue? [y/N] " reply
    [[ "$reply" == "y" || "$reply" == "Y" ]] || return 1
  fi

  return 0
}

_kube_require_pod() {
  if [[ -z "$ACTIVE_POD" ]]; then
    echo "No active pod selected. Run: kpod <search-term>" >&2
    return 1
  fi
}

_kube_container_args() {
  if [[ -n "$ACTIVE_CONTAINER" ]]; then
    echo "-c" "$ACTIVE_CONTAINER"
  fi
}

# =========================
# Status helpers
# =========================

kubeactive() {
  echo "ACTIVE_CONTEXT=${ACTIVE_CONTEXT:-"(using kubectl current-context)"}"
  echo "ACTIVE_NAMESPACE=${ACTIVE_NAMESPACE:-"(not set)"}"
  echo "ACTIVE_POD=${ACTIVE_POD:-"(not set)"}"
  echo "ACTIVE_CONTAINER=${ACTIVE_CONTAINER:-"(not set)"}"
}

kreset() {
  export ACTIVE_POD=""
  export ACTIVE_CONTAINER=""
  echo "ACTIVE_POD cleared"
  echo "ACTIVE_CONTAINER cleared"
}

# =========================
# Context helpers
# =========================

kctx() {
  local selected

  if [[ -n "$1" ]]; then
    selected="$1"
  else
    selected=$(
      kubectl config get-contexts -o name | fzf --prompt="Context > " --height=40% --reverse
    ) || return 1
  fi

  export ACTIVE_CONTEXT="$selected"
  kubectl config use-context "$ACTIVE_CONTEXT"
}

kctxs() {
  kubectl config get-contexts
}

# =========================
# Namespace helpers
# =========================

kns() {
  local selected

  if [[ -n "$1" ]]; then
    selected="$1"
  else
    selected=$(
      _kube_kubectl get namespaces --no-headers -o custom-columns=":metadata.name" \
        | fzf --prompt="Namespace > " --height=40% --reverse
    ) || return 1
  fi

  export ACTIVE_NAMESPACE="$selected"
  echo "ACTIVE_NAMESPACE=$ACTIVE_NAMESPACE"
}

knss() {
  _kube_kubectl get namespaces
}

# =========================
# Pod helpers
# =========================

kpods() {
  _kube_kubectl -n "$ACTIVE_NAMESPACE" get pods
}

kpod() {
  local selected search

  if [[ -n "$1" ]]; then
    search="$1"
    selected=$(
      _kube_kubectl -n "$ACTIVE_NAMESPACE" get pods --no-headers \
        | grep "$search" \
        | fzf --prompt="Pod > " --height=50% --reverse
    ) || return 1
  else
    selected=$(
      _kube_kubectl -n "$ACTIVE_NAMESPACE" get pods --no-headers \
        | fzf --prompt="Pod > " --height=50% --reverse
    ) || return 1
  fi

  export ACTIVE_POD="${selected%% *}"
  export ACTIVE_CONTAINER=""

  echo "$ACTIVE_POD"
}

kpodclear() {
  export ACTIVE_POD=""
  export ACTIVE_CONTAINER=""
  echo "ACTIVE_POD cleared"
  echo "ACTIVE_CONTAINER cleared"
}

# =========================
# Container helpers
# =========================

kcontainers() {
  _kube_require_pod || return 1
  _kube_kubectl -n "$ACTIVE_NAMESPACE" get pod "$ACTIVE_POD" -o jsonpath='{.spec.containers[*].name}'
  echo
}

kcontainer() {
  if [[ -z "$1" ]]; then
    echo "$ACTIVE_CONTAINER"
    return 0
  fi

  export ACTIVE_CONTAINER="$1"
  echo "ACTIVE_CONTAINER=$ACTIVE_CONTAINER"
}

# =========================
# Exec / shell helpers
# =========================

kexec() {
  local search=""
  if [[ "$1" != "--" && -n "$1" ]]; then
    search="$1"
    kpod "$search" >/dev/null || return 1
    shift
  else
    _kube_require_pod || return 1
  fi

  [[ "$1" == "--" ]] && shift

  if [[ $# -eq 0 ]]; then
    echo "Usage: kexec [pod-search] -- <command>" >&2
    return 1
  fi

  _kube_confirm_prod || return 1
  _kube_prod_colour_on

  _kube_kubectl -n "$ACTIVE_NAMESPACE" exec -it "$ACTIVE_POD" $(_kube_container_args) -- "$@"

  local status=$?
  _kube_prod_colour_off
  return $status
}

kbash() {
  if [[ -n "$1" ]]; then
    kpod "$1" >/dev/null || return 1
  else
    _kube_require_pod || return 1
  fi

  _kube_confirm_prod || return 1
  _kube_prod_colour_on

  _kube_kubectl -n "$ACTIVE_NAMESPACE" exec -it "$ACTIVE_POD" $(_kube_container_args) -- bash

  local status=$?
  _kube_prod_colour_off
  return $status
}

ksh() {
  if [[ -n "$1" ]]; then
    kpod "$1" >/dev/null || return 1
  else
    _kube_require_pod || return 1
  fi

  _kube_confirm_prod || return 1
  _kube_prod_colour_on

  _kube_kubectl -n "$ACTIVE_NAMESPACE" exec -it "$ACTIVE_POD" $(_kube_container_args) -- sh

  local status=$?
  _kube_prod_colour_off
  return $status
}

# =========================
# Logs
# =========================

klogs() {
  if [[ -n "$1" && "$1" != -* ]]; then
    kpod "$1" >/dev/null || return 1
    shift
  else
    _kube_require_pod || return 1
  fi

  _kube_kubectl -n "$ACTIVE_NAMESPACE" logs $(_kube_container_args) "$ACTIVE_POD" "$@"
}

klogsf() {
  if [[ -n "$1" && "$1" != -* ]]; then
    kpod "$1" >/dev/null || return 1
    shift
  else
    _kube_require_pod || return 1
  fi

  _kube_kubectl -n "$ACTIVE_NAMESPACE" logs -f $(_kube_container_args) "$ACTIVE_POD" "$@"
}

# =========================
# Copy helpers
# =========================

kcpfrom() {
  _kube_require_pod || return 1

  local remote_path="$1"
  local local_path="$2"

  if [[ -z "$remote_path" || -z "$local_path" ]]; then
    echo "Usage: kcpfrom <remote-path-in-pod> <local-path>" >&2
    return 1
  fi

  mkdir -p "$(dirname "$local_path")" 2>/dev/null

  _kube_kubectl cp \
    ${ACTIVE_CONTAINER:+-c "$ACTIVE_CONTAINER"} \
    "$ACTIVE_NAMESPACE/$ACTIVE_POD:$remote_path" \
    "$local_path"
}

kcpto() {
  _kube_require_pod || return 1

  local local_path="$1"
  local remote_path="$2"

  if [[ -z "$local_path" || -z "$remote_path" ]]; then
    echo "Usage: kcpto <local-path> <remote-path-in-pod>" >&2
    return 1
  fi

  _kube_confirm_prod || return 1

  _kube_kubectl cp \
    ${ACTIVE_CONTAINER:+-c "$ACTIVE_CONTAINER"} \
    "$local_path" \
    "$ACTIVE_NAMESPACE/$ACTIVE_POD:$remote_path"
}

# =========================
# Inspection helpers
# =========================

kdescribe() {
  _kube_require_pod || return 1
  _kube_kubectl -n "$ACTIVE_NAMESPACE" describe pod "$ACTIVE_POD"
}

kenv() {
  _kube_require_pod || return 1
  _kube_kubectl -n "$ACTIVE_NAMESPACE" exec -it "$ACTIVE_POD" $(_kube_container_args) -- env
}

kenvrg() {
    kenv | rg "$1"
}


# =========================
# Rails helpers
# =========================

krails() {
  if [[ -n "$1" && "$1" != "--" ]]; then
    kpod "$1" >/dev/null || return 1
    shift
  else
    _kube_require_pod || return 1
  fi

  [[ "$1" == "--" ]] && shift

  _kube_confirm_prod || return 1

  _kube_kubectl -n "$ACTIVE_NAMESPACE" exec -it "$ACTIVE_POD" $(_kube_container_args) -- bundle exec rails "$@"

  local status=$?
  return $status
}

kconsole() {
  if [[ -n "$1" ]]; then
    kpod "$1" >/dev/null || return 1
  else
    _kube_require_pod || return 1
  fi

  _kube_confirm_prod || return 1

  _kube_kubectl -n "$ACTIVE_NAMESPACE" exec -it "$ACTIVE_POD" $(_kube_container_args) -- bundle exec rails console

  local status=$?
  return $status
}

kuse() {
  kctx || return 1
  kns || return 1
  kpod || return 1
  _kube_prod_color_reset
  kubeactive
}
