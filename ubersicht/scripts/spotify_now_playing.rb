#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"

def run_osascript(script)
  stdout, stderr, status = Open3.capture3("osascript", "-e", script)

  unless status.success?
    raise "osascript failed: #{stderr.strip}"
  end

  stdout.strip
end

def spotify_running?
  script = <<~APPLESCRIPT
    tell application "System Events"
      return (name of processes) contains "Spotify"
    end tell
  APPLESCRIPT

  run_osascript(script) == "true"
end

def current_track_data
  script = <<~APPLESCRIPT
    tell application "Spotify"
      if player state is stopped then
        return "STOPPED"
      end if

      set track_name to name of current track
      set artist_name to artist of current track
      set album_name to album of current track
      set duration_ms to duration of current track
      set position_seconds to player position
      set playback_state to player state as string

      return track_name & "||" & artist_name & "||" & album_name & "||" & duration_ms & "||" & position_seconds & "||" & playback_state
    end tell
  APPLESCRIPT

  result = run_osascript(script)
  return nil if result == "STOPPED"

  track_name, artist_name, album_name, duration_ms, position_seconds, playback_state = result.split("||", 6)

  {
    track: {
      name: track_name,
      artist: artist_name,
      album: album_name,
      duration_seconds: (duration_ms.to_f / 1000).round,
      position_seconds: position_seconds.to_f.round
    },
    playback: {
      state: playback_state
    },
    app: {
      running: true
    }
  }
end

begin
  unless spotify_running?
    puts JSON.generate(
      app: { running: false },
      playback: { state: "not_running" }
    )
    exit 0
  end

  data = current_track_data

  if data.nil?
    puts JSON.generate(
      app: { running: true },
      playback: { state: "stopped" }
    )
    exit 0
  end

  puts JSON.generate(data)
rescue StandardError => e
  puts JSON.generate(
    error: "Could not load Spotify state",
    detail: e.message
  )
end
