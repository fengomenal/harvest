require_relative './array_ops.rb'
require_relative './db.rb'
require_relative './util.rb'
require 'date'
require 'parallel'
require 'yaml'

config = YAML.load(File.read("#{__dir__}/../config.yml"))['db']
client = Harvest::DB.connect(config)

data = client.query("SELECT rec_date,adj_close,volume FROM historical WHERE ticker='A'").sort { |i| i['rec_date'] }.reverse
weekly_data = Util.partition_via(data, 'wday', 'rec_date')
weekly_average = weekly_data.map { |week| { volume: week.sum { |day| day['volume'] } / week.size, close: week.sum { |day| day['adj_close'] } / week.size } }
weekly_diff = weekly_average[1..-1].each_with_index.map { |val, i| { volume: (1 - (val[:volume].to_f / weekly_average[i][:volume])).abs, close: (1 - (val[:close].to_f / weekly_average[i][:close])).abs } }

r_volume = weekly_diff.map { |i| i[:volume] }[0..-2].r(weekly_diff.map { |i| i[:close] }[1..-1])
r_close = weekly_diff.map { |i| i[:close] }[0..-2].r(weekly_diff.map { |i| i[:close] }[1..-1])
STDOUT.puts r_volume
STDOUT.puts r_close
