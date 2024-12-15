require_relative 'currency'
require_relative 'public_client'
class CurrencyFactory
  attr_reader :currencies
  def initialize(all_products_parsed_json,fiat_starting_currency_object)
    @start = fiat_starting_currency_object
    @parsed = all_products_parsed_json
    @currencies = []
  end
  def build
    @currencies = @currencies.clear
    base_currencies = @parsed.map{|raw_product| raw_product["base_currency"]["iso_code"] }
    pair_currencies = @parsed.map{|raw_product| raw_product["counter_currency"]["iso_code"]}
    merged = base_currencies + pair_currencies
    merged.uniq!
    merged.map do |iso_code|
      if iso_code == @start.id_or_iso_code
        @currencies << Currency.new(iso_code,@start.amount)
      else
        @currencies << Currency.new(iso_code,0)
      end
    end
  end
end