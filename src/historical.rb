require 'parallel'
require 'rest-client'
require_relative './db.rb'

module Harvest
  module Historical
    module_function

    def get_prices(symbol, first, last)
      res = RestClient.get "https://query1.finance.yahoo.com/v7/finance/download/#{symbol}?period1=#{first}&period2=#{last}&interval=1d&events=history&includeAdjustedClose=true"
      res.body.split("\n")[1..-1]
    rescue StandardError => e
      STDOUT.puts e
      nil
    end

    def transform_to_row(data)
      cells = data.split(',')
      [ Time.parse(cells[0]).to_i, cells[1..-2].map { |cell| cell.to_f }, cell[-1] ].flatten
    end

    def pull_and_update(client, table, symbol, last_updated, parallel = 1)
      data = get_prices(symbol, last_updated + 86400, Time.now.to_i)
      Parallel.each(data, in_threads: parallel) do |data|
        row = transform_to_row(data)
        client.query(Harvest::DB.insert_query_str(table, row))
      end
      # replace last updated
    end
  end
end
