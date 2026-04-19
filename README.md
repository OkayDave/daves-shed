# Dave's Shed

My stash of scripts, configurations, and other customisations to ensure I have a nice time when using my computers.

## Requirements

* zsh
* ghostty
* git
* eza
* fzf
* zoxide
* AWS CLI
* kubectl
* ripgrep
* bat
* zed
* neovim
* sqlite3
* ruby
* ubersicht

## Components

- **[Editors](editors/)**: Neovim configuration, IdeaVim, and Zed settings.
- **[Terminal](terminal/README.md)**: Zsh configuration, Ghostty settings, and Kubernetes/File helper scripts (all automatically linked).
- **[Wallpaper](wallpaper/README.md)**: macOS wallpaper rotation script and automated service.
- **[Ubersicht](ubersicht/README.md)**: [Ubersicht](https://tracesof.net/uebersicht/) configuration and widgets.

## Setup

To link the configurations to your home directory, run:

### Symlinks
```bash
./bin/setup-links.sh
```

### Ubersicht
* Set your Ubersicht widgets folder to use the `ubersicht/widgets` directory.
* Add your location information for the weather widget:
```zshrc
shed-kv set weather.coordinates "56.6224,-6.0605"
shed-kv set weather.location_name "Tobermory"
```

### Wallpaper Rotation
To enable automatic wallpaper rotation, you can do any of these:

* Use the normal MacOs 'Change Wallpaper' within System Preferences.
* Add the `bin/rotate-wallpaper.sh` to whatever cron / trigger you'd like
* Add the `bin/com.github.dave-shed.wallpaper.plist` to your login items. See `wallpaper/README.md` for more details.

### Alfred
* Set your Alfred preferences folder to user `desktop/alfred` (or symlink it)