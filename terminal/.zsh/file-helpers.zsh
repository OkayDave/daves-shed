# location: $HOME/.zsh/file-helpers.zsh

_lns_resolve_target_path() {
  local target_path="$1"
  local parent_dir base_name

  parent_dir=$(dirname "$target_path") || return 1
  base_name=$(basename "$target_path") || return 1

  mkdir -p "$parent_dir" || return 1
  echo "$(cd "$parent_dir" && pwd -P)/$base_name"
}

lns() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<EOF
lns — create a symlink, with fuzzy source lookup if needed

Usage:
  lns <source> [target]
  lns --force <source> [target]

What it does:
  - accepts an exact source path, or fuzzy-finds one with fd
  - defaults target to ./<basename of source>
  - creates parent directories if needed
  - warns before replacing an existing symlink

Examples:
  lns ~/.config/nvim/init.lua
  lns init.lua ~/.config/nvim/init.lua
  lns --force zshrc ~/.zshrc
EOF
    return 0
  fi

  local force=0
  local input_path target_path source_path
  local current_target confirm
  local -a matches

  if [[ "$1" == "-f" || "$1" == "--force" ]]; then
    force=1
    shift
  fi

  if [[ $# -lt 1 ]]; then
    echo "Usage: lns <source> [target]"
    return 1
  fi

  input_path="$1"
  target_path="$2"

  if [[ -e "$input_path" || -L "$input_path" ]]; then
    source_path=$(realpath "$input_path")
  else
    matches=("${(@f)$(fd --hidden --follow --exclude .git "$input_path" 2>/dev/null)}")

    if [[ ${#matches[@]} -eq 0 ]]; then
      echo "❌ No matches found for: $input_path"
      return 1
    elif [[ ${#matches[@]} -eq 1 ]]; then
      source_path=$(realpath "${matches[1]}")
    else
      echo "🔍 Multiple matches, pick one:"
      source_path=$(
        printf '%s\n' "${matches[@]}" |
          fzf --preview '
            preview_path="{}"
            if [[ -d "$preview_path" ]]; then
              eza -la --icons "$preview_path" 2>/dev/null || ls -la "$preview_path"
            else
              bat --style=numbers --color=always "$preview_path" 2>/dev/null || ls -la "$preview_path"
            fi
          '
      ) || return 1

      [[ -z "$source_path" ]] && return 1
      source_path=$(realpath "$source_path")
    fi
  fi

  if [[ -z "$target_path" ]]; then
    target_path="./$(basename "$source_path")"
  fi

  target_path=$(_lns_resolve_target_path "$target_path") || {
    echo "❌ Failed to resolve target path: $target_path"
    return 1
  }

  if [[ -e "$target_path" && ! -L "$target_path" ]]; then
    echo "❌ Target exists and is not a symlink: $target_path"
    return 1
  fi

  if [[ -L "$target_path" ]]; then
    current_target=$(readlink "$target_path")

    if [[ "$force" -ne 1 ]]; then
      echo "⚠️  Target already exists as a symlink:"
      echo "   $target_path -> $current_target"
      read "?Replace it? [y/N]: " confirm
      [[ "$confirm" != "y" && "$confirm" != "Y" ]] && {
        echo "Aborted."
        return 1
      }
    fi
  fi

  ln -sfn "$source_path" "$target_path" || {
    echo "❌ Failed to create symlink"
    return 1
  }

  echo "🔗 Linked: $target_path -> $source_path"
}

grom() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<EOF
grom — hard reset current repo to origin/main

Usage:
  grom

What it does:
  - switches to main
  - fetches origin
  - hard resets to origin/main (DESTROYS local changes)

⚠️  WARNING: This will permanently discard ALL local changes.
EOF
    return 0
  fi

  echo "⚠️  This will HARD RESET to origin/main and delete local changes."
  read "?Continue? [y/N]: " confirm
  [[ "$confirm" != "y" && "$confirm" != "Y" ]] && {
    echo "Aborted."
    return 1
  }

  git switch main &&
  git fetch origin &&
  git reset --hard origin/main
}

rg() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<EOF
rg — ripgrep with sane defaults

Usage:
  rg <pattern> [path...]

Defaults:
  --hidden        include hidden files
  --glob "!.git"  ignore .git directory

Examples:
  rg TODO
  rg "User.find" app/
EOF
    return 0
  fi

  command rg --hidden --glob "!.git" "$@"
}

rgf() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<EOF
rgf — interactive ripgrep + fzf search

Usage:
  rgf <pattern>

What it does:
  - searches with ripgrep
  - pipes results into fzf
  - previews matches with bat

Example:
  rgf "def perform"
EOF
    return 0
  fi

  if [[ $# -eq 0 ]]; then
    echo "❌ rgf requires a search pattern. Try: rgf --help"
    return 1
  fi

  command rg --hidden --glob "!.git" --line-number --no-heading --color=always "$@" |
    fzf --ansi \
        --delimiter : \
        --preview 'bat --style=numbers --color=always {1} --line-range {2}:'
}

ff() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<EOF
ff — fuzzy file finder + open in editor

Usage:
  ff

Keys:
  ENTER     open in \$VISUAL
  CTRL-E    open in \$EDITOR

EOF
    return 0
  fi

  local visual_editor terminal_editor
  local selection key selected
  local -a lines

  visual_editor="${VISUAL:-zed}"
  terminal_editor="${EDITOR:-nvim}"

  selection=$(
    command rg --files --hidden --glob "!.git" |
      fzf --preview 'bat --style=numbers --color=always {}' \
          --bind 'enter:accept,ctrl-e:accept' \
          --expect=enter,ctrl-e
  ) || return

  lines=("${(@f)selection}")
  key="${lines[1]}"
  selected="${lines[2]}"

  [[ -z "$selected" ]] && return

  if [[ "$key" == "ctrl-e" ]]; then
    "$terminal_editor" "$selected"
  else
    "$visual_editor" "$selected"
  fi
}
