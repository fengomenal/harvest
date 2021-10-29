require_relative './db.rb'
require 'yaml'

config = YAML.load(File.read("#{__dir__}/../config.yml"))['db']
client = Harvest::DB.connect(config)

tickers = %w[SPY UPRO SSO SPXU SDS SH]
existing_tickers = client.query("SELECT tickers FROM tickers").map { |row| row['ticker'] }
STDOUT.puts tickers - existing_tickers
#client.query("INSERT INTO tickers VALUES ()")

