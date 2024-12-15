require_relative 'coinjar_client'
class PrivateClient < CoinjarClient
  headers 'Authorization' => "Bearer #{ENV['COINJAR_TRADES']}",'accept' => 'application/json','Content-Type' => 'application/json'
  # {oid:"number"}
  base_uri "https://api.exchange.coinjar.com"
  def place_order(product_id,price,buy_or_sell,size,type = "LMT")
    JSON.parse(self.class.post('orders',body: JSON.generate({"type" => type.to_s,"size" => size.to_s,"product_id" => product_id.to_s,"side" => buy_or_sell.to_s,"price" => price.to_s})).to_s)
  end
  def get_order(order_id)
    JSON.parse(self.class.get("orders/#{order_id.to_s}").to_s).to_h
  end
end