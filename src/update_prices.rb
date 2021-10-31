require_relative './db.rb'
require_relative './historical.rb'
require 'date'
require 'parallel'
require 'yaml'

config = YAML.load(File.read("#{__dir__}/../config.yml"))['db']
clients = [ Harvest::DB.connect(config), Harvest::DB.connect(config) ]

failed = []
today = Date.today.to_time.to_i
ticker_rows = clients[0].query("SELECT * FROM tickers").map { |r| r }.reverse
ticker_rows.each do |ticker_row|
  ticker = ticker_row['ticker']
  next unless ticker_row['active']
  first = ticker_row['last_updated'] ? ticker_row['last_updated'].to_time.to_i : 0
  begin
    data = Harvest::Historical.get_prices(ticker, first, today)
  rescue
    failed << ticker
    sleep 30
    next
  end
  if data.nil?
    failed << ticker
    sleep 30
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
