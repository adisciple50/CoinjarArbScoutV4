require_relative 'currency'
require_relative "public_client"
require_relative "currency_factory"
require_relative "product_factory"
require_relative "chain_factory"

STAKE = 200.00
START_CURRENCY = "GBP"



fiat_currency_object = Currency.new(START_CURRENCY,STAKE)
last_winner = nil
profit = 0

SPINNER = ["+","x"]
spinner_count = 0
while profit <= 0
  puts "Scanning ...#{SPINNER[spinner_count]}"
  if spinner_count >= SPINNER.count - 1
    spinner_count = 0
  else
    spinner_count += 1
  end
  all_products_parsed_json = PublicClient.new.get_all_products
  currency_factory = CurrencyFactory.new(all_products_parsed_json,fiat_currency_object)
  currency_factory.build
  all_currency_objects = currency_factory.currencies
  product_factory = ProductFactory.new(all_products_parsed_json,all_currency_objects)
  product_factory.build
  all_product_objects = product_factory.products
  chain_factory = ChainFactory.new(all_product_objects,fiat_currency_object,STAKE)
  chain_factory.build
  chains = chain_factory.chains
  sorted = chains.sort {|a,b| a.profit <=> b.profit}
  winner = sorted[-1]
  puts winner.to_s
  last_winner = winner
  profit = last_winner.profit
end
puts last_winner.to_s
File.write('winner.txt',last_winner.to_s,mode:'a')
system('gst-play-1.0 /usr/share/sounds/Yaru/stereo/system-ready.oga')