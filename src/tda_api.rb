require 'rest-client'
require 'uri'

module Harvest
  module Order
    module_function

    def limit_equity(symbol, instruction, price, quantity)
      {
        orderType: 'LIMIT',
        session: 'NORMAL',
        duration: 'DAY',
        orderStrategyType: 'SINGLE',
        orderLegCollection: [
          {
            instruction: instruction,
            price: price,
            quantity: quantity,
            instrument: {
              symbol: symbol,
              assetType: 'EQUITY'
            }
          }
        ]
      }
    end
  end

  module TdaApi
    module_function

    BASE_URL = 'https://api.tdameritrade.com'

    def get_token(url)
      RestClient::Request.execute(
        method: :GET,
        url: url,
      ).body
    end

    def get_accounts(token, account_id = nil)
      RestClient::Request.execute(
        method: :GET,
        url: "#{BASE_URL}/v1/accounts/#{account_id}",
        headers: {
          authorization: "Bearer #{token}"
        }
      )
    end

    def get_quote(token, symbol)
      RestClient::Request.execute(
        method: :GET,
        url: "#{BASE_URL}/v1/marketdata/#{URI.www_form_encode_component(symbol)}/quotes",
        headers: {
          authorization: "Bearer #{token}"
        }
      )
    end

    def get_order(token, account_id, order_id)
      RestClient::Request.execute(
        method: :GET,
        url: "#{BASE_URL}/v1/accounts/#{account_id}/orders/#{order_id}",
        headers: {
          authorization: "Bearer #{token}"
        }
      )
    end

    def get_orders(token, account_id)
      RestClient::Request.execute(
        method: :GET,
        url: "#{BASE_URL}/v1/accounts/#{account_id}/orders",
        headers: {
          authorization: "Bearer #{token}"
        }
      )
    end

    def place_order(token, account_id, order)
      RestClient::Request.execute(
        method: :POST,
        url: "#{BASE_URL}/v1/accounts/#{account_id}/orders",
        payload: order.to_json,
        headers: {
          authorization: "Bearer #{token}",
          content_type: 'application/json'
        }
      )
    end

    def cancel_order(token, account_id, order_id)
      RestClient::Request.execute(
        method: :DELETE,
        url: "#{BASE_URL}/v1/accounts/#{account_id}/orders/#{order_id}",
        headers: {
          authorization: "Bearer #{token}"
        }
      )
    end
  end
end
