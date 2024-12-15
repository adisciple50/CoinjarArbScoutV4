require_relative 'currency'
require_relative 'public_client'
class Product
  attr_reader :id,:bid,:ask,:last,:display_currency,:base,:pair,:is_fiat_trade
  def initialize(currency_object_base,currency_object_pair,price_levels)
    unless currency_object_base.class.name == "Currency"
      raise "Currency Base Is Not A Currency Object - it is a: #{currency_object_base.class.name}"
      end
    unless currency_object_pair.class.name == "Currency"
      raise "Currency Pair Is Not A Currency Object - it is a: #{currency_object_pair.class.name}"
    end
    @base = currency_object_base
    @pair = currency_object_pair
    @is_fiat_trade = @base.is_fiat? || @pair.is_fiat?
    @id = "#{currency_object_base.id_or_iso_code}#{currency_object_pair.id_or_iso_code}"
    @json = PublicClient.new.ticker(@id)
    parsed = @json
    @display_currency = currency_object_pair.id_or_iso_code
    @bid = parsed["bid"].to_f
    @ask = parsed["ask"].to_f
    # @last = parsed["last"].to_f
    @price_levels = price_levels
    @ask_tick = determine_ask_tick_exponent
    @bid_tick = determine_bid_tick_exponent
  end
  def determine_bid_tick_exponent
    result = false
    @price_levels.each do |level|
      if @bid >= level["price_min"].to_f && @bid <= level["price_max"].to_f
        result = {
          tick_size:level["tick_size"],
          tick_exponent:level["tick_size_exponent"],
          min_trade_size:level["trade_size"],
          trade_size_exponent:level["trade_size_exponent"]
        }
      end
    end
    unless result
      raise "price level could not be determined - tick size exponent is calculated by '-E4' - this bid is #{@bid.to_s} for product id:#{@id}\n=level is=\n#{@price_levels}"
    end
    result
  end
  def determine_ask_tick_exponent
    result = false
    @price_levels.each do |level|
      if @ask >= level["price_min"].to_f && @ask <= level["price_max"].to_f
        result = {
          tick_size:level["tick_size"],
          tick_exponent:level["tick_size_exponent"],
          min_trade_size:level["trade_size"],
          trade_size_exponent:level["trade_size_exponent"]
         }
      end
    end
    unless result
      raise "price level could not be determined - tick size exponent is calculated by '-E4' - this ask is #{@ask.to_s} for product id:#{@id} \n=level is=\n#{@price_levels}"
    end
    result
  end
  def to_s
    "base:#{@base.id_or_iso_code} - pair:#{@pair.id_or_iso_code} - id:#{@id} - bid:#{@bid} - ask:#{@ask} - quoted currency:#{display_currency}"
  end
end