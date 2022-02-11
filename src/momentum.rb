require_relative './array_ops.rb'
require_relative './db.rb'
require_relative './util.rb'
require 'date'
require 'parallel'
require 'yaml'

config = YAML.load(File.read("#{__dir__}/../config.yml"))['db']
client = Harvest::DB.connect(config)

tickers = client.query("SELECT ticker FROM tickers WHERE active=true AND last_updated>#{(Date.today - 30).to_s}").map { |i| i['ticker'] }

count = 0
max_tickers = 7
min_window = 4000
start_cutoff = Date.today - min_window
cutoff_str = start_cutoff.to_s
historical = {}
tickers = ["NRP", "LGO", "ARMP", "ACTG", "MTA", "AAPL", "A"]
tickers.shuffle.each do |ticker|
  data = client.query("SELECT rec_date,adj_close FROM historical WHERE ticker='#{ticker}'").sort { |i| i['rec_date'] }.reverse
  next if data.any? { |i| i['adj_close'].zero? }
  next unless data.first['rec_date'] <= start_cutoff
  historical[ticker] = data.select { |val| val['rec_date'] >= start_cutoff }
  count += 1
  break if count ==  max_tickers
end

monthly_data = {}
monthly_maxes = {}
historical.each do |ticker, data|
  monthly_partition = Util.partition_via(data, 'day', 'rec_date')
  monthly_max = monthly_partition.map { |m| m.max_by { |d| d['adj_close'] }['adj_close'] }
  monthly_maxes[ticker] = monthly_max
  monthly_partition.each_with_index do |month, index|
    start_date = month.first['rec_date']
    key_string = "#{start_date.year}-#{"%02d" % start_date.month}"
    monthly_data[key_string] ||= {}
    monthly_data[key_string][ticker] = month.first['adj_close']
  end
end

months = monthly_data.keys.sort
tickers = historical.keys
performance_range = ['2016-02', '2016-05']
# momentum portfolio
momentum_portfolio = {}
months[11..-1].each_with_index do |month, index|
  position = {}
  highest_momentum = monthly_data[month].keys.sort_by { |ticker| monthly_data[month][ticker] / monthly_maxes[ticker][(index)..(index + 10)].max }.reverse[0..4]
  momentum_portfolio[month] = highest_momentum.map { |ticker| [ticker, 1.0 / 5] }.to_h
end
momentum_performance = Util.calculate_performance(momentum_portfolio, monthly_data)

allocation_per = 1.0 / max_tickers

# rebalanced market portfolio
rebalanced_portfolio = {}
months[11..-1].each do |month|
  position = {}
  tickers.each { |ticker| position[ticker] = allocation_per }
  rebalanced_portfolio[month] = position
end
rebalanced_performance = Util.calculate_performance(rebalanced_portfolio, monthly_data)

# buy and hold market portfolio
buy_and_hold_portfolio = {}
buy_and_hold_portfolio[months[11]] = tickers.map { |ticker| [ticker, allocation_per] }.to_h
buy_and_hold_portfolio[months.last] = tickers.map { |ticker| [ticker, allocation_per] }.to_h
buy_and_hold_performance = Util.calculate_performance(buy_and_hold_portfolio, monthly_data)

STDOUT.puts "Performance from #{months[11]} to #{months.last}:"
STDOUT.puts "\tMomentum: #{momentum_performance.values.last - 1}"
STDOUT.puts "\tRebalanced market: #{rebalanced_performance.values.last - 1}"
STDOUT.puts "\tBuy and hold: #{buy_and_hold_performance.values.last - 1}"
