# Terminal Configuration

This directory contains the Zsh configuration and helper scripts used for the terminal environment.

## Main Configuration (`.zshrc`)

The `.zshrc` file serves as the entry point, setting up environment variables, aliases, and loading auxiliary scripts.

### Key Aliases
- `ls`: Enhanced `eza` command with icons, git integration, and tree view.
- `cd`: Alias for `z` (zoxide).
- `awsli`: AWS SSO login shortcut (`aws sso login --sso-session aws`).
- `awslc`: List EKS clusters for a profile (`aws eks list-clusters --profile`).
- `prodon` / `prodoff`: Manually toggle production terminal background color.

### Key Environment Variables
- `EDITOR`: `nvim`
- `VISUAL`: `zed`
- `DEFAULT_TERM_BG`: Hex code for the default terminal background.
- `PROD_TERM_BG`: Hex code for the production terminal background (used for visual warnings).

---

## File Helpers (`.zsh/file-helpers.zsh`)

A collection of utilities for file management and searching.

- `lns <source> [target]`: Create a symlink with fuzzy source lookup (using `fd` and `fzf`).
- `grom`: Hard reset the current git repository to `origin/main` (switches to main, fetches, and resets).
- `rg <pattern>`: Ripgrep with sane defaults (includes hidden files, ignores `.git`).
- `rgf <pattern>`: Interactive ripgrep piped into `fzf` with `bat` preview.
- `ff`: Fuzzy file finder to open files in `$VISUAL` (Enter) or `$EDITOR` (Ctrl-E).

---

## Kubernetes Helpers (`.zsh/kube-helpers.zsh`)

Extensive helpers for managing Kubernetes contexts, namespaces, and pods.

### State Management
The helpers maintain an "active" state to simplify subsequent commands:
- `ACTIVE_CONTEXT`: Current Kubernetes context.
- `ACTIVE_NAMESPACE`: Current namespace.
- `ACTIVE_POD`: Currently selected pod.
- `ACTIVE_CONTAINER`: Currently selected container within the pod.

### Navigation & Selection
- `kuse`: Interactive wizard to set context, namespace, and pod in one go.
- `kctx [context]`: Switch context (interactive if no argument provided).
- `kns [namespace]`: Switch namespace (interactive if no argument provided).
- `kpod [search]`: Select a pod using fuzzy search.
- `kpodclear` / `kreset`: Clear the active pod and container selection.

### Operations
- `kexec [--] <command>`: Execute a command in the active pod.
- `kbash` / `ksh`: Drop into a bash or sh shell in the active pod.
- `klogs` / `klogsf`: View or follow logs for the active pod.
- `kcpfrom <remote> <local>`: Copy a file from the active pod.
- `kcpto <local> <remote>`: Copy a file to the active pod.
- `kdescribe`: Describe the active pod.
- `kenv` / `kenvrg [pattern]`: View environment variables in the active pod.

### Rails Specifics
- `krails <command>`: Run a Rails command in the active pod.
- `kconsole`: Open a Rails console in the active pod.

---

## Ghostty Configuration (`config.ghostty`)

The `config.ghostty` file defines the appearance and behavior of the Ghostty terminal.

### Visual Settings
- **Theme**: `Spacedust`
- **Font**: `Rec Mono Casual` at size `15.5`.
- **Window**: Includes padding (`18x12`), `0.85` opacity, and `20` blur.
- **Cursor**: Bar style, blinking, with color `#ffcc66`.

### Key Features
- **Scrollback**: Increased limit to `200,000` lines.
- **Shell Integration**: Automatically detected, supporting cursor, sudo, and title updates.
- **Keybindings**: `Cmd+W` is bound to `close_surface`.
- **Behavior**: `copy-on-select` enabled; `confirm-close-surface` disabled.

---

## Prompt & Hooks (`.zsh/prompt.zsh`)

Customizes the Zsh prompt and adds shell hooks.

- **Kubernetes Info**: Displays the current context, namespace, and pod in the prompt (only when inside `RubymineProjects` directory).
- **Command Timing**: Tracks and displays the duration of the last executed command.
- **Git Integration**: Shows current branch and status via `vcs_info`.
- **Production Safety**: Automatically changes the terminal background color when connected to a production context.
