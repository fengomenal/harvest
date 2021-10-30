require 'mysql2'
require 'yaml'

config = YAML.load(File.read("#{__dir__}/../config.yml"))['db']
client = Mysql2::Client.new(config)

client.query("CREATE TABLE tickers (ticker VARCHAR(20) NOT NULL, active BOOL, last_updated DATE, PRIMARY KEY(ticker))")
client.query("CREATE TABLE historical (ticker VARCHAR(20) NOT NULL, rec_date DATE NOT NULL, open FLOAT, high FLOAT, low FLOAT, close FLOAT, adj_close FLOAT, volume INT, PRIMARY KEY(ticker, rec_date))")
