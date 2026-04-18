# frozen_string_literal: true

require 'json'
require_relative 'lib/shed_kv'

clock_data = {
  time: {
    hour: Time.now.strftime('%H'),
    minute: Time.now.strftime('%M'),
    second: Time.now.strftime('%S')
  },
  date: {
    month: {
      full_name: Time.now.strftime('%B'),
      short_name: Time.now.strftime('%b'),
      number: Time.now.strftime('%m')
    },
    day: {
      full_name: Time.now.strftime('%A'),
      short_name: Time.now.strftime('%a'),
      number: Time.now.strftime('%d')
    },
    year: {
      full: Time.now.strftime('%Y'),
      short: Time.now.strftime('%y')
    }
  }
}

puts clock_data.to_json
