require_relative './array_ops.rb'
require_relative './db.rb'
require_relative './util.rb'
require 'date'
require 'parallel'
require 'yaml'

config = YAML.load(File.read("#{__dir__}/../config.yml"))['db']
client = Harvest::DB.connect(config)

as_of_date = Date.today - 15
scaffold_ticker = 'KO'
scaffold_dates = client.query(
  "SELECT rec_date FROM historical WHERE ticker='#{scaffold_ticker}'"
).map { |i| i['rec_date'] }.sort
selected_dates = [scaffold_dates.first]
scaffold_dates.each do |date|
  next if date.month == selected_dates.last.month
  selected_dates << date
end

selected_dates = selected_dates[0..100]

portfolio = {}
value = 1
selected_dates.each do |date|
  period_data = {}
  rows = client.query("SELECT ticker,adj_close FROM historical WHERE rec_date='#{date}'").map { |i| i }
  rows.each { |row| period_data[row['ticker']] = row['adj_close'] }
  unless portfolio.empty?
    value = value * Harvest::Util.calculate_new_value(portfolio, period_data) 
  end
  puts value
  portfolio = {}
  non_zero = period_data.keys.select { |ticker| !period_data[ticker].zero? }
  allocation = 1.0 / non_zero.size
  non_zero.each { |ticker| portfolio[ticker] = { allocation: allocation, price: period_data[ticker] } }
end

# momentum portfolio
#momentum_portfolio = {}
#months[11..-1].each_with_index do |month, index|
#  position = {}
#  highest_momentum = monthly_data[month].keys.sort_by { |ticker| monthly_data[month][ticker] / monthly_maxes[ticker][(index)..(index + 10)].max }.reverse[0..4]
#  momentum_portfolio[month] = highest_momentum.map { |ticker| [ticker, 1.0 / 5] }.to_h
#end
#momentum_performance = Util.calculate_performance(momentum_portfolio, monthly_data)
