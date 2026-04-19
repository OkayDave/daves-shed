# frozen_string_literal: true

require 'json'

# file = File.read()
quotes = JSON.load_file(File.expand_path('../../datasets/gen_quotes.json', __dir__))

random_row = quotes[rand(quotes.length - 1)]

random_row['quote'].capitalize!
random_row['tags'] = random_row['tags'].join(' | ')
puts random_row.to_h.to_json
