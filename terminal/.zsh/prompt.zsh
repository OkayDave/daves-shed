# location: $HOME/.zsh/prompt.zsh

# PROMPT
# Kube
#
# Kubernetes prompt
kube_prompt_info() {
  if [[ "$PWD" != *RubymineProjects* ]]; then
    KUBE_PROMPT=""
    return
  fi

  local context namespace pod container colour short_ctx prompt_text

  context="${ACTIVE_CONTEXT:-}"
  namespace="${ACTIVE_NAMESPACE:-default}"
  pod="${ACTIVE_POD:-}"
  container="${ACTIVE_CONTAINER:-}"

  # Fallback to kubectl current-context if helper state isn't set
  if [[ -z "$context" ]] && command -v kubectl >/dev/null 2>&1; then
    context="$(kubectl config current-context 2>/dev/null)"
  fi

  case "$context" in
    pa-uk-rail-production)
      short_ctx="prod"
      colour="red"
      ;;
    pa-uk-rail-nonprod)
      short_ctx="nonprod"
      colour="green"
      ;;
    "")
      KUBE_PROMPT=""
      return
      ;;
    *)
      short_ctx="$context"
      colour="cyan"
      ;;
  esac

  prompt_text="[⎈ $short_ctx:$namespace"
  [[ -n "$pod" ]] && prompt_text="${prompt_text}:$pod"
  [[ -n "$container" ]] && prompt_text="${prompt_text}/$container"
  prompt_text="${prompt_text}]"

  KUBE_PROMPT="%F{$colour}${prompt_text}%f"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd kube_prompt_info

# GIT
# Command duration timing
zmodload zsh/datetime
zsh_command_time_preexec() {
  timer=$EPOCHREALTIME
}
zsh_command_time_precmd() {
  if [ $timer ]; then
    local now=$EPOCHREALTIME
    local d=$((now - timer))
    cmd_duration="$(printf "%.2fs" $d)"
    unset timer
  else
    cmd_duration=""
  fi
}
add-zsh-hook preexec zsh_command_time_preexec
add-zsh-hook precmd zsh_command_time_precmd

# Git integration
autoload -Uz vcs_info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats '(%b)' '%u%c'
zstyle ':vcs_info:git:*' actionformats '(%b)' '%u%c' '<%a>'
add-zsh-hook precmd vcs_info

setopt prompt_subst

PROMPT="
%F{red}%~%f %F{yellow}%B\${vcs_info_msg_0_}%b%f%F{magenta}%B\${vcs_info_msg_1_}%b%f \${KUBE_PROMPT}
%F{cyan}%D%f %F{cyan}%*%f %B\${cmd_duration}%b %# "
# < PROMPT
