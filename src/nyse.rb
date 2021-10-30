require 'json'
require 'rest-client'

module Harvest
  module Nyse
    module_function

    def post_nyse_directory(page = 1)
      RestClient::Request.execute(
        url: 'https://www.nyse.com/api/quotes/filter',
        method: :POST,
        headers:{ content_type: 'application/json' },
        payload:{ 
          instrumentType: 'EQUITY', 
          maxResultsPerPage: 50,
          pageNumber: page
        }.to_json
      )   
    end

    def get_tickers
      tickers = []
      page = 1
      loop do
        body = JSON.parse(post_nyse_directory(page).body)
        break if body.empty?
        tickers.concat(body.map { |ticker| ticker['symbolTicker'] })
        page += 1
      end
      tickers
    end
  end
end
