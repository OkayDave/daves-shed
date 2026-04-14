# location: $HOME/.zshrc

# =========================
# PREAMBLE
# =========================
export XDG_CONFIG_HOME="$HOME/.config"
export DEFAULT_TERM_BG="#041E23"
export PROD_TERM_BG="#3B0A0A"
export EDITOR="nvim"
export VISUAL="zed"

# Set a clean baseline PATH explicitly.
# Do not build this from the existing $PATH, because if startup has already
# gone wrong, you'll preserve the corruption.
# export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Applications/Ghostty.app/Contents/MacOS"

# Keep zsh's special path array in sync
path=("${(@s/:/)PATH}")

get_in() {
  local config_path file

  for config_path in "$@"; do
    file="${~config_path}"
    [[ "$file" != /* ]] && file="$HOME/$file"

    if [[ -f "$file" ]]; then
      source "$file"
      # echo "📥 Loaded: $file"
    else
      echo "⚠️  Not found: $file"
    fi
  done
}

# =========================
# ZOXIDE
# =========================
eval "$(zoxide init zsh)"

# =========================
# ALIASES
# =========================
alias ls="eza -1 --long -T --colour=always --all --icons --git --level=1"
alias awsli="aws sso login --sso-session aws"
alias awslc="aws eks list-clusters --profile"
alias cd="z"
alias prodon="_kube_prod_colour_on"
alias prodoff="_kube_prod_colour_off"

# =========================
# HELPERS
# =========================
get_in ".zsh/file-helpers.zsh"
get_in ".zsh/kube-helpers.zsh"

# =========================
# COMPLETIONS
# =========================
fpath=("$HOME/.zsh" $fpath)
zstyle ':completion:*:*:git:*' script "$HOME/.zsh/git-completion.bash"
autoload -Uz compinit
compinit

# =========================
# PROMPT
# =========================
get_in ".zsh/prompt.zsh"
