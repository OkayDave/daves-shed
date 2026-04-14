# Random wallpaper service

This directory contains the source images for the wallpaper rotation script.

## Overview

The macOS wallpaper rotation script is located at `bin/random-wallpaper.zsh` and uses a sample `launchd` agent at `bin/com.daveshed.random-wallpaper.plist`.

The script chooses a random file from this `wallpaper/` directory and sets it as the desktop background.

### Files

- `bin/random-wallpaper.zsh` - random wallpaper script
- `bin/com.daveshed.random-wallpaper.plist` - `launchd` agent definition
- `wallpaper/` - source images

### Run it manually

Make the script executable if needed:

```bash
chmod +x /Users/dave/code/daves-shed/bin/random-wallpaper.zsh
```

Run it:

```bash
/Users/dave/code/daves-shed/bin/random-wallpaper.zsh
```

### Security and permissions

On macOS, the terminal app and shell that launch the script may need permission to control desktop-related apps.

If the script prints a success message but the wallpaper does not visibly change, check:

- `System Settings` -> `Privacy & Security` -> `Accessibility`
- `System Settings` -> `Privacy & Security` -> `Automation`

You may need to allow your terminal application, such as `Ghostty`, and/or the shell process (`zsh`) to control `Finder` and `System Events`.

After granting permissions, run the script again manually to confirm it works before setting up the scheduled service.

### Install the service

Copy the plist into your user LaunchAgents folder:

```bash
mkdir -p ~/Library/LaunchAgents
cp /Users/dave/code/daves-shed/bin/com.daveshed.random-wallpaper.plist ~/Library/LaunchAgents/com.daveshed.random-wallpaper.plist
```

Load it:

```bash
launchctl load ~/Library/LaunchAgents/com.daveshed.random-wallpaper.plist
```

It is configured to:

- run every 30 minutes
- run once immediately when loaded

### Change the schedule

The schedule is controlled by the `StartInterval` value in the plist:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDsPropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.daveshed.random-wallpaper</string>

  <key>ProgramArguments</key>
  <array>
    <string>/Users/dave/code/daves-shed/bin/random-wallpaper.zsh</string>
  </array>

  <key>StartInterval</key>
  <integer>1800</integer>

  <key>RunAtLoad</key>
  <true/>

  <key>StandardOutPath</key>
  <string>/tmp/com.daveshed.random-wallpaper.out</string>

  <key>StandardErrorPath</key>
  <string>/tmp/com.daveshed.random-wallpaper.err</string>
</dict>
</plist>
```

`1800` means 1800 seconds, which is 30 minutes.

Examples:

- `900` = 15 minutes
- `1800` = 30 minutes
- `3600` = 1 hour

After editing the plist, reload the service:

```bash
launchctl unload ~/Library/LaunchAgents/com.daveshed.random-wallpaper.plist
launchctl load ~/Library/LaunchAgents/com.daveshed.random-wallpaper.plist
```

### Update the script path

The plist currently uses this absolute script path:

```text
/Users/dave/code/daves-shed/bin/random-wallpaper.zsh
```

If this repo lives somewhere else on another Mac, update the path inside `ProgramArguments` before loading the service.

### Logs and debugging

The service writes logs to:

- `/tmp/com.daveshed.random-wallpaper.out`
- `/tmp/com.daveshed.random-wallpaper.err`

Check them with:

```bash
cat /tmp/com.daveshed.random-wallpaper.out
cat /tmp/com.daveshed.random-wallpaper.err
```

You can also test the script directly at any time:

```bash
/Users/dave/code/daves-shed/bin/random-wallpaper.zsh
```

### Uninstall the service

Unload the agent and remove the plist:

```bash
launchctl unload ~/Library/LaunchAgents/com.daveshed.random-wallpaper.plist
rm ~/Library/LaunchAgents/com.daveshed.random-wallpaper.plist
```
