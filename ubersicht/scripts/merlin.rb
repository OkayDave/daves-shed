# frozen_string_literal: true

require 'json'
require 'csv'

csv_path = File.expand_path('../../datasets/inspired_quotes.csv', __dir__)
quotes = CSV.read(csv_path, headers: true, encoding: 'UTF-8')

random_row = quotes[rand(quotes.length)]

puts random_row.to_h.to_json
