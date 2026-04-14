#!/bin/zsh

set -euo pipefail

SCRIPT_DIR=${0:A:h}
WALLPAPER_DIR="${SCRIPT_DIR:h}/wallpaper"

if [[ ! -d "${WALLPAPER_DIR}" ]]; then
  echo "Wallpaper directory not found: ${WALLPAPER_DIR}" >&2
  exit 1
fi

wallpapers=(
  "${WALLPAPER_DIR}"/*(.N)
)

if (( ${#wallpapers[@]} == 0 )); then
  echo "No wallpaper files found in: ${WALLPAPER_DIR}" >&2
  exit 1
fi

selected_wallpaper="${wallpapers[RANDOM % ${#wallpapers[@]} + 1]}"

osascript <<APPLESCRIPT
tell application "Finder"
  set desktop picture to POSIX file "${selected_wallpaper}"
end tell

tell application "System Events"
  tell every desktop
    set picture to POSIX file "${selected_wallpaper}"
  end tell
end tell
APPLESCRIPT

killall Dock >/dev/null 2>&1 || true

echo "Wallpaper set to: ${selected_wallpaper}"
