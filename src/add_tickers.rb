require_relative './db.rb'
require_relative './nyse.rb'
require 'yaml'

config = YAML.load(File.read("#{__dir__}/../config.yml"))['db']
client = Harvest::DB.connect(config)

index_tickers = %w[SPY UPRO SSO SPXU SDS SH]
nyse = Harvest::Nyse.get_tickers

existing_tickers = client.query("SELECT ticker FROM tickers").map { |row| row['ticker'] }
to_insert = index_tickers.concat(nyse) - existing_tickers
to_insert.each do |ticker|
  client.query("INSERT INTO tickers VALUES ('#{ticker}', TRUE, NULL)")
end

STDOUT.puts "Inserted #{to_insert.size} rows"
