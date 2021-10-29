require_relative './db.rb'
require_relative './historical.rb'
require 'date'
require 'parallel'
require 'yaml'

config = YAML.load(File.read("#{__dir__}/../config.yml"))['db']
client = Harvest::DB.connect(config)

today = Date.today.to_time.to_i
ticker_rows = client.query("SELECT * FROM tickers")
ticker_rows.each do |ticker_row| #parallelize
  ticker = ticker_row['ticker']
  next unless ticker_row['active']
  first = ticker_row['last_updated'] + 86400 #convert to i
  data = Harvest::Historical.get_prices(ticker, first, today)
  data.each do |row|
    row = transform_to_row(data)
    client.query(Harvest::DB.insert_query_str('historical', row))
  end
  client.query("UPDATE tickers SET last_updated=#{today} WHERE ticker=#{ticker}")
end

