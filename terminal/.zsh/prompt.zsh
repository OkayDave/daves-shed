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

  prompt_text="☸ $short_ctx:$namespace"
  [[ -n "$pod" ]] && prompt_text="${prompt_text}:$pod"
  [[ -n "$container" ]] && prompt_text="${prompt_text}/$container"

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
  local exit_status=$?
  if [ $timer ]; then
    local now=$EPOCHREALTIME
    local d=$((now - timer))
    cmd_duration="⏳ $(printf "%.2fs" $d)"
    unset timer
  else
    cmd_duration=""
  fi

  if [[ $exit_status -ne 0 ]]; then
    exit_info="%F{red}⚠️ $exit_status%f "
  else
    exit_info=""
  fi
}
add-zsh-hook preexec zsh_command_time_preexec
add-zsh-hook precmd zsh_command_time_precmd

# Git integration
autoload -Uz vcs_info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats '🌿 (%b)' '%u%c'
zstyle ':vcs_info:git:*' actionformats '🌿 (%b)' '%u%c' '<%a>'
add-zsh-hook precmd vcs_info

setopt prompt_subst

# Left and Right Prompt: Directory, Git, Kube on left; Date/Time, Duration on right
# We handle this in a precmd hook to align RPROMPT content to the first line of a multi-line prompt
build_prompt() {
  local left_part="%F{cyan}📂 %~%f %F{yellow}%B${vcs_info_msg_0_}%b%f%F{magenta}%B${vcs_info_msg_1_}%b%f %B${KUBE_PROMPT}%b"
  local right_part="%F{8} 📅 %D %*%f %F{yellow}%B ${cmd_duration}%b%f ${exit_info}"

  PROMPT="
${left_part}
%B%#%b "

  RPROMPT="${right_part}"
}

add-zsh-hook precmd build_prompt
