#!/bin/zsh

set -euo pipefail

SCRIPT_DIR=${0:A:h}
WALLPAPER_DIR="${SCRIPT_DIR:h}/wallpaper"

if [[ ! -d "${WALLPAPER_DIR}" ]]; then
  echo "Wallpaper directory not found: ${WALLPAPER_DIR}" >&2
  exit 1
fi

wallpapers=(
  "${WALLPAPER_DIR}"/*.{jpg,jpeg,png,webp,heic}(.N)
)

if (( ${#wallpapers[@]} == 0 )); then
  echo "No wallpaper files found in: ${WALLPAPER_DIR}" >&2
  exit 1
fi

# Join wallpapers with a special delimiter for AppleScript to split on
wallpaper_list_string="${(j:|:)wallpapers}"

osascript <<APPLESCRIPT
set wallpaperString to "${wallpaper_list_string}"
set oldDelimiters to AppleScript's text item delimiters
set AppleScript's text item delimiters to "|"
set wallpaperList to text items of wallpaperString
set AppleScript's text item delimiters to oldDelimiters

tell application "System Events"
  set desktopCount to count of desktops
  repeat with i from 1 to desktopCount
    set randomIndex to random number from 1 to (count of wallpaperList)
    set selectedWallpaper to item randomIndex of wallpaperList
    set picture of desktop i to POSIX file selectedWallpaper
  end repeat
end tell
APPLESCRIPT
