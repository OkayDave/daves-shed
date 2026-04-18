#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "time"

require_relative "./lib/shed_kv"

DEFAULT_DURATION_SECONDS = 25 * 60

module FocusTimer
  module_function

  def now
    Time.now.to_i
  end

  def get_int(key, default = nil)
    raw = get_kv(key)
    return default if raw.nil? || raw.strip.empty?

    raw.to_i
  end

  def get_bool(key, default = true)
    raw = get_kv(key)
    return default if raw.nil? || raw.strip.empty?

    raw == "true"
  end

  def get_string(key, default = nil)
    raw = get_kv(key)
    return default if raw.nil? || raw.strip.empty?

    raw
  end

  def set(key, value)
    set_kv(key, value.to_s)
  end

  def delete(key)
    shed_kv("delete", key)
  end

  def load_state
    {
      state: get_string("focus.state", "idle"),
      duration_seconds: get_int("focus.duration_seconds", DEFAULT_DURATION_SECONDS),
      started_at: get_int("focus.started_at"),
      paused_at: get_int("focus.paused_at"),
      paused_total_seconds: get_int("focus.paused_total_seconds", 0),
      sound_enabled: get_bool("focus.sound_enabled", true)
    }
  end

  def save_state(state)
    set("focus.state", state[:state])
    set("focus.duration_seconds", state[:duration_seconds])
    set("focus.paused_total_seconds", state[:paused_total_seconds])
    set("focus.sound_enabled", state[:sound_enabled])

    state[:started_at] ? set("focus.started_at", state[:started_at]) : delete("focus.started_at")
    state[:paused_at] ? set("focus.paused_at", state[:paused_at]) : delete("focus.paused_at")
  end

  def elapsed_seconds(state)
    case state[:state]
    when "running"
      now - state[:started_at] - state[:paused_total_seconds]
    when "paused"
      state[:paused_at] - state[:started_at] - state[:paused_total_seconds]
    when "done"
      state[:duration_seconds]
    else
      0
    end
  end

  def remaining_seconds(state)
    [state[:duration_seconds] - elapsed_seconds(state), 0].max
  end

  def completed?(state)
    %w[running paused done].include?(state[:state]) && remaining_seconds(state) <= 0
  end

  def maybe_complete!(state)
    return state unless completed?(state)
    return state if state[:state] == "done"

    state[:state] = "done"
    state[:paused_at] = nil
    save_state(state)
    notify_complete! if state[:sound_enabled]
    state
  end

  def notify_complete!
    system("osascript", "-e", 'display notification "Focus session complete" with title "Focus Timer"')
    system("osascript", "-e", "beep")
  end

  def status_payload(state)
    state = maybe_complete!(state)

    {
      state: state[:state],
      duration_seconds: state[:duration_seconds],
      remaining_seconds: remaining_seconds(state),
      elapsed_seconds: elapsed_seconds(state),
      started_at: state[:started_at],
      paused_at: state[:paused_at],
      paused_total_seconds: state[:paused_total_seconds],
      sound_enabled: state[:sound_enabled],
      progress_percent: if state[:duration_seconds].to_i > 0
                          ((elapsed_seconds(state).to_f / state[:duration_seconds]) * 100).clamp(0, 100).round
                        else
                          0
                        end
    }
  end

  def start!(duration_seconds = nil)
    state = load_state
    duration = (duration_seconds || state[:duration_seconds] || DEFAULT_DURATION_SECONDS).to_i
    duration = DEFAULT_DURATION_SECONDS if duration <= 0

    state[:state] = "running"
    state[:duration_seconds] = duration
    state[:started_at] = now
    state[:paused_at] = nil
    state[:paused_total_seconds] = 0

    save_state(state)
    status_payload(state)
  end

  def pause!
    state = load_state
    if state[:state] == "running"
      state[:state] = "paused"
      state[:paused_at] = now
      save_state(state)
    end
    status_payload(state)
  end

  def resume!
    state = load_state
    if state[:state] == "paused" && state[:paused_at]
      state[:paused_total_seconds] += (now - state[:paused_at])
      state[:paused_at] = nil
      state[:state] = "running"
      save_state(state)
    end
    status_payload(state)
  end

  def reset!
    state = load_state
    state[:state] = "idle"
    state[:started_at] = nil
    state[:paused_at] = nil
    state[:paused_total_seconds] = 0
    save_state(state)
    status_payload(state)
  end

  def toggle_sound!
    state = load_state
    state[:sound_enabled] = !state[:sound_enabled]
    save_state(state)
    status_payload(state)
  end
end

begin
  command = ARGV[0] || "status"

  result =
    case command
    when "status"
      FocusTimer.status_payload(FocusTimer.load_state)
    when "start"
      FocusTimer.start!(ARGV[1])
    when "pause"
      FocusTimer.pause!
    when "resume"
      FocusTimer.resume!
    when "reset"
      FocusTimer.reset!
    when "toggle_sound"
      FocusTimer.toggle_sound!
    else
      { error: "Unknown command: #{command}" }
    end

  puts JSON.generate(result)
rescue StandardError => e
  puts JSON.generate(
    error: "Could not process focus timer command",
    detail: e.message
  )
end
