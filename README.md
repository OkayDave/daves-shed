# Dave's Shed

## Random wallpaper service

This repo includes a macOS wallpaper rotation script at `bin/random-wallpaper.zsh` and a sample `launchd` agent at `bin/com.daveshed.random-wallpaper.plist`.

The script chooses a random file from the `wallpaper/` directory and sets it as the desktop background.

### Files

- `bin/random-wallpaper.zsh` - random wallpaper script
- `bin/com.daveshed.random-wallpaper.plist` - `launchd` agent definition
- `wallpaper/` - source images

### Run it manually

Make the script executable if needed:

```/dev/null/commands.sh#L1-1
chmod +x /Users/dave/code/daves-shed/bin/random-wallpaper.zsh
```

Run it:

```/dev/null/commands.sh#L1-1
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

```/dev/null/commands.sh#L1-2
mkdir -p ~/Library/LaunchAgents
cp /Users/dave/code/daves-shed/bin/com.daveshed.random-wallpaper.plist ~/Library/LaunchAgents/com.daveshed.random-wallpaper.plist
```

Load it:

```/dev/null/commands.sh#L1-1
launchctl load ~/Library/LaunchAgents/com.daveshed.random-wallpaper.plist
```

It is configured to:

- run every 30 minutes
- run once immediately when loaded

### Change the schedule

The schedule is controlled by the `StartInterval` value in the plist:

```daves-shed/bin/com.daveshed.random-wallpaper.plist#L1-25
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

```/dev/null/commands.sh#L1-2
launchctl unload ~/Library/LaunchAgents/com.daveshed.random-wallpaper.plist
launchctl load ~/Library/LaunchAgents/com.daveshed.random-wallpaper.plist
```

### Update the script path

The plist currently uses this absolute script path:

```/dev/null/path.txt#L1-1
/Users/dave/code/daves-shed/bin/random-wallpaper.zsh
```

If this repo lives somewhere else on another Mac, update the path inside `ProgramArguments` before loading the service.

### Logs and debugging

The service writes logs to:

- `/tmp/com.daveshed.random-wallpaper.out`
- `/tmp/com.daveshed.random-wallpaper.err`

Check them with:

```/dev/null/commands.sh#L1-2
cat /tmp/com.daveshed.random-wallpaper.out
cat /tmp/com.daveshed.random-wallpaper.err
```

You can also test the script directly at any time:

```/dev/null/commands.sh#L1-1
/Users/dave/code/daves-shed/bin/random-wallpaper.zsh
```

### Uninstall the service

Unload the agent and remove the plist:

```/dev/null/commands.sh#L1-2
launchctl unload ~/Library/LaunchAgents/com.daveshed.random-wallpaper.plist
rm ~/Library/LaunchAgents/com.daveshed.random-wallpaper.plist
```
