#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"
require "time"

def run_helper
  helper_path = File.expand_path("../bin/calendar-today-helper", __dir__)
  stdout, stderr, status = Open3.capture3(helper_path)

  unless status.success?
    raise "calendar helper failed: #{stderr.strip}"
  end

  JSON.parse(stdout)
end

def format_time(time)
  time.strftime("%H:%M")
end

def build_payload(raw_events)
  now = Time.now
  today_label = now.strftime("%A %-d %B")

  events = raw_events.map do |event|
    start_time = Time.iso8601(event.fetch("startTimestamp")).localtime
    end_time = Time.iso8601(event.fetch("endTimestamp")).localtime

    {
      calendar: event.fetch("calendar"),
      title: event.fetch("title").strip,
      start: format_time(start_time),
      end: format_time(end_time),
      start_timestamp: start_time.iso8601,
      end_timestamp: end_time.iso8601,
      all_day: event.fetch("allDay"),
      is_now: !event.fetch("allDay") && now >= start_time && now < end_time,
      is_upcoming: !event.fetch("allDay") && now < start_time
    }
  end

  sorted = events.sort_by do |event|
    [
      event[:all_day] ? 0 : 1,
      event[:start_timestamp],
      event[:title].downcase
    ]
  end

  next_event = sorted.find { |event| event[:is_now] || event[:is_upcoming] }

  {
    date: {
      label: today_label
    },
    summary: {
      count: sorted.length,
      has_events: sorted.any?,
      next_title: next_event&.dig(:title),
      next_start: next_event&.dig(:start),
      next_is_now: next_event&.dig(:is_now) || false
    },
    events: sorted,
    updated_at: Time.now.iso8601
  }
end

begin
  raw = run_helper

  if raw.is_a?(Hash) && raw["error"]
    puts JSON.generate(raw)
    exit 0
  end

  puts JSON.generate(build_payload(raw))
rescue StandardError => e
  puts JSON.generate(
    error: "Could not load calendar events",
    detail: e.message
  )
end
