#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "net/http"
require "uri"
require "time"
require "openssl"

require_relative "./lib/shed_kv"

FORECAST_URL = "https://api.open-meteo.com/v1/forecast"

WEATHER_CODES = {
  0 => { label: "Clear", emoji: "☀" },
  1 => { label: "Mainly clear", emoji: "☀" },
  2 => { label: "Partly cloudy", emoji: "☁" },
  3 => { label: "Overcast", emoji: "☁" },
  45 => { label: "Fog", emoji: "〰" },
  48 => { label: "Rime fog", emoji: "〰" },
  51 => { label: "Light drizzle", emoji: "☂" },
  53 => { label: "Drizzle", emoji: "☂" },
  55 => { label: "Heavy drizzle", emoji: "☂" },
  56 => { label: "Freezing drizzle", emoji: "❄" },
  57 => { label: "Heavy freezing drizzle", emoji: "❄" },
  61 => { label: "Light rain", emoji: "☔" },
  63 => { label: "Rain", emoji: "☔" },
  65 => { label: "Heavy rain", emoji: "☔" },
  66 => { label: "Freezing rain", emoji: "❄" },
  67 => { label: "Heavy freezing rain", emoji: "❄" },
  71 => { label: "Light snow", emoji: "❄" },
  73 => { label: "Snow", emoji: "❄" },
  75 => { label: "Heavy snow", emoji: "❄" },
  77 => { label: "Snow grains", emoji: "❄" },
  80 => { label: "Rain showers", emoji: "☔" },
  81 => { label: "Heavy showers", emoji: "☔" },
  82 => { label: "Violent showers", emoji: "☔" },
  85 => { label: "Snow showers", emoji: "❄" },
  86 => { label: "Heavy snow showers", emoji: "❄" },
  95 => { label: "Thunderstorm", emoji: "⚡" },
  96 => { label: "Thunderstorm & hail", emoji: "⚡" },
  99 => { label: "Severe thunderstorm", emoji: "⚡" }
}.freeze

def fetch_json(url)
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)

  if uri.scheme == "https"
    http.use_ssl = true
    # On some systems, CRL checking might be enabled by default and fail.
    # We disable it for better compatibility while still verifying the certificate chain.
    store = OpenSSL::X509::Store.new
    store.set_default_paths
    store.flags = 0 if store.respond_to?(:flags=)
    http.cert_store = store
  end

  response = http.request(Net::HTTP::Get.new(uri))

  unless response.is_a?(Net::HTTPSuccess)
    raise "HTTP #{response.code} from #{uri}"
  end

  JSON.parse(response.body)
end

def read_coordinates!
  raw = get_kv("weather.coordinates")
  raise "weather.coordinates is missing" if raw.nil? || raw.strip.empty?

  lat_str, lon_str = raw.split(",", 2).map(&:strip)
  raise "weather.coordinates must be in the form 'latitude,longitude'" if lat_str.nil? || lon_str.nil?

  [Float(lat_str), Float(lon_str)]
end

def read_location_name
  value = get_kv("weather.location_name")
  value.nil? || value.strip.empty? ? "Local weather" : value
end

def fetch_weather(lat:, lon:)
  params = URI.encode_www_form(
    latitude: lat,
    longitude: lon,
    current: [
      "temperature_2m",
      "apparent_temperature",
      "weather_code",
      "wind_speed_10m"
    ].join(","),
    daily: [
      "temperature_2m_max",
      "temperature_2m_min",
      "precipitation_probability_max"
    ].join(","),
    forecast_days: 1,
    timezone: "Europe/London",
    temperature_unit: "celsius",
    wind_speed_unit: "mph"
  )

  fetch_json("#{FORECAST_URL}?#{params}")
end

begin
  latitude, longitude = read_coordinates!
  location_name = read_location_name

  weather = fetch_weather(lat: latitude, lon: longitude)

  current = weather.fetch("current")
  daily = weather.fetch("daily")

  code_info = WEATHER_CODES.fetch(
    current["weather_code"],
    { label: "Unknown", emoji: "?" }
  )

  payload = {
    location: {
      name: location_name,
      latitude: latitude,
      longitude: longitude
    },
    current: {
      temperature_c: current["temperature_2m"].round,
      feels_like_c: current["apparent_temperature"].round,
      condition: code_info[:label],
      condition_icon: code_info[:emoji],
      wind_mph: current["wind_speed_10m"].round
    },
    today: {
      high_c: daily["temperature_2m_max"][0].round,
      low_c: daily["temperature_2m_min"][0].round,
      rain_chance_percent: daily["precipitation_probability_max"][0] || 0
    },
    attribution: {
      name: "Open-Meteo",
      url: "https://open-meteo.com/",
      licence: "CC BY 4.0"
    },
    updated_at: Time.now.iso8601
  }

  puts JSON.generate(payload)
rescue StandardError => e
  puts JSON.generate(
    error: "Could not load weather data",
    detail: e.message
  )
end

