require "httparty"
class CoinjarClient
  include HTTParty
  headers {'accept' => 'application/json'}
  base_uri "https://api.exchange.coinjar.com/"
end