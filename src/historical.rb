require 'rest-client'

module Harvest
  module Historical
    module_function

    def get_prices(ticker, first, last)
      res = RestClient.get "https://query1.finance.yahoo.com/v7/finance/download/#{ticker}?period1=#{first}&period2=#{last}&interval=1d&events=history&includeAdjustedClose=true"
      res.body.split("\n")[1..-1]
    end

    def transform_to_row(ticker, data)
      cells = data.split(',')
      [ "'#{ticker}'", "'#{Date.parse(cells[0]).strftime('%Y-%m-%d')}'", cells[1..-2].map { |cell| cell.to_f }, cells[-1] ].flatten
    end
  end
end
