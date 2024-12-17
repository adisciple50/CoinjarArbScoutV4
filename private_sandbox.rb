class PrivateSandbox
  headers 'Authorization' => "Bearer #{ENV['COINJAR_SANDBOX']}",'accept' => 'application/json','Content-Type' => 'application/json'
  base_uri "https://api.exchange.coinjar-sandbox.com/"

  def create_order(product_id)

  end
end