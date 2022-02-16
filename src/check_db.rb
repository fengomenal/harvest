require_relative './array_ops.rb'
require_relative './db.rb'
require_relative './util.rb'
require 'date'
require 'parallel'
require 'yaml'

config = YAML.load(File.read("#{__dir__}/../config.yml"))['db']
client = Harvest::DB.connect(config)

STDOUT.puts 'UPDATED: ' + client.query("SELECT COUNT(*) FROM tickers WHERE last_updated>'2022-02-10'").map { |i| i }.to_s
STDOUT.puts 'INACTIVE: ' + client.query("SELECT COUNT(*) FROM tickers WHERE active=FALSE").map { |i| i }.to_s

