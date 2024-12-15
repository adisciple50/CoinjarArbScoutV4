require_relative 'currency'
require_relative "public_client"
require_relative "currency_factory"
require_relative "product_factory"
require_relative "chain_factory"

STAKE = 1000.00

fiat_currency_object = Currency.new("GBP",STAKE)
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
puts winner.inspect
