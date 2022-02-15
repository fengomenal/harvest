require_relative './db.rb'
require_relative './tda_api.rb'
require_relative './historical.rb'
require 'date'
require 'json'
require 'parallel'
require 'yaml'

config = YAML.load(File.read("#{__dir__}/../config.yml"))
clients = [ Harvest::DB.connect(config['db']), Harvest::DB.connect(config['db']) ]
token = Harvest::TdaApi.get_token(config['token'])

failed = []
today = (Date.today - 1).to_time.to_i
no_date = Date.parse('1900-01-01')
ticker_rows = clients[0].query("SELECT * FROM tickers").map { |r| r }.sort_by { |row| row['last_updated'] || no_date }
ticker_rows.each do |ticker_row|
  ticker = ticker_row['ticker']
  next unless ticker_row['active']
  first = ticker_row['last_updated'] ? ticker_row['last_updated'].to_time.to_i : 0
  begin
    #if JSON.parse(Harvest::TdaApi.get_quote(token, ticker).body).empty?
    #  clients.first.query("UPDATE tickers SET active=FALSE WHERE ticker='#{ticker}'")
    #  next
    #else
      data = Harvest::Historical.get_prices(ticker, first, today)
    #end
  rescue
    clients.first.query("UPDATE tickers SET active=FALSE WHERE ticker='#{ticker}'")
    failed << ticker
    sleep 15
    next
  end
  if data.nil?
    failed << ticker
    sleep 15
    next
  end
  Parallel.each(data, in_threads: 2) do |row|
    row = Harvest::Historical.transform_to_row(ticker, row)
    begin # update instead
      clients[Parallel.worker_number].query(Harvest::DB.insert_query_str('historical', row))
    rescue
    end
  end
  clients[0].query("UPDATE tickers SET last_updated='#{data[-1].split(',')[0]}' WHERE ticker='#{ticker}'")
end

STDOUT.puts "Update failed for #{failed}"
