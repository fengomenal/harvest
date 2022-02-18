require_relative './array_ops.rb'
require_relative './db.rb'
require_relative './util.rb'
require 'date'
require 'parallel'
require 'yaml'

config = YAML.load(File.read("#{__dir__}/../config.yml"))['db']
client = Harvest::DB.connect(config)

tickers = client.query("SELECT * FROM tickers").map { |i| i }
STDOUT.puts 'TICKERS:' + tickers.size.to_s
STDOUT.puts 'UPDATED: ' + tickers.select { |i| i['last_updated'] && i['last_updated'] > Date.parse('02-01-2022') }.size.to_s
STDOUT.puts 'INACTIVE: ' + tickers.select { |i| i['active'].zero? && !i['last_updated'] }.size.to_s

