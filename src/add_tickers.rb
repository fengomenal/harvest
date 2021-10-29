require_relative './db.rb'
require 'yaml'

config = YAML.load(File.read("#{__dir__}/../config.yml"))['db']
client = Harvest::DB.connect(config)

tickers = %w[SPY UPRO SSO SPXU SDS SH]
existing_tickers = client.query("SELECT ticker FROM tickers").map { |row| row['ticker'] }
to_insert = tickers - existing_tickers
to_insert.each do |ticker|
  client.query("INSERT INTO tickers VALUES ('#{ticker}', TRUE, NULL)")
end

STDOUT.puts "Inserted #{to_insert.size} rows"
