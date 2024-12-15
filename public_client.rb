require_relative 'coinjar_client'
require 'json'
class PublicClient < CoinjarClient
  def get_all_products
    @base_uri =  "https://api.exchange.coinjar.com/"
    request = self.class.get('/products?all=false',format: :plain)
    response = request.body.to_s
    # puts "all products response is #{response}"
    JSON.parse(response)
  end
  def ticker(id)
    @base_uri = ""
    id = id.to_s.upcase
    request = self.class.get("https://data.exchange.coinjar.com/products/#{id}/ticker",format: :plain)
    response = request.body.to_s
    # puts "ticker response is #{response} and id is #{id}"
    JSON.parse(response)
  end
end