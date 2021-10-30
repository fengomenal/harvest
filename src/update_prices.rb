require_relative './db.rb'
require_relative './historical.rb'
require 'date'
require 'parallel'
require 'yaml'

config = YAML.load(File.read("#{__dir__}/../config.yml"))['db']
client = Harvest::DB.connect(config)

today = Date.today.to_time.to_i
ticker_rows = client.query("SELECT * FROM tickers")
ticker_rows.each do |ticker_row|
  ticker = ticker_row['ticker']
  next unless ticker_row['active']
  first = ticker_row['last_updated'] ? ticker_row['last_updated'].to_time.to_i : 0
  data = Harvest::Historical.get_prices(ticker, first, today)
  data.each do |row|
    row = Harvest::Historical.transform_to_row(ticker, row)
    begin # update instead
      client.query(Harvest::DB.insert_query_str('historical', row))
    rescue
    end
  end
  client.query("UPDATE tickers SET last_updated='#{data[-1].split(',')[0]}' WHERE ticker='#{ticker}'")
end

