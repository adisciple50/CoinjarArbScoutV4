require_relative 'currency'
require_relative "public_client"
require_relative "currency_factory"
require_relative "product_factory"
require_relative "chain_factory"
require 'date'
require 'awesome_print'
require 'json'
require 'tty-spinner'
STAKE = 200.00
START_CURRENCY = "GBP"



fiat_currency_object = Currency.new(START_CURRENCY,STAKE)
last_winner = nil
profit = 0

SPINNER = ["+","x"]
spinner_count = 0
spinner = TTY::Spinner.new("Scanning [:spinner]", format: :bouncing)
while true
  spinner.auto_spin
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
  last_winner = winner
  profit = last_winner.profit
  spinner.stop
  if profit > 0
    ap last_winner.to_h
    File.write("winners/#{DateTime.now.to_s}.json",JSON.unparse(last_winner.to_h),mode:'a')
    system('gst-play-1.0 /usr/share/sounds/Yaru/stereo/system-ready.oga')
  end
end
