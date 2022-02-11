require_relative './tda_api.rb'
require 'json'
require 'yaml'

config = YAML.load(File.read("#{__dir__}/../config.yml"))

token = Harvest::TdaApi.get_token(config['token'])
account_id = config['account_id']

account_data = JSON.parse(Harvest::TdaApi.get_accounts(token, account_id).body)
cash = account_data['securitiesAccount']['currentBalances']['cashBalance']

allocations = { 'TQQQ': 1.0 }
shares = allocation.map { |equity| [equity[0], equity[1] * cash] }

orders = []

allocations.each do |symbol, allocation|
  dollar_amount = allocation * cash
  quote = JSON.parse(Harvest::TdaApi.get_quote(token, symbol).body)
  average_price = (quote['bidPrice'] + quote['askPrice']) / 2
  quantity = dollar_amount / average_price
  next if quantity < 1
  orders << Harvest::Order.limit_equity(symbol, 'BUY', average_price, quantity)
end

puts orders
