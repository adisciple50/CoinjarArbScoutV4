require_relative 'product'
require_relative 'currency_search'
# require_relative 'app'
require 'parallel'
class ProductFactory
  attr_reader :products
  def initialize(all_products_parsed_json,all_currency_objects)
    @json = all_products_parsed_json
    @currencies = all_currency_objects
    @products = []
  end
  def build
    @products = @products.clear
    @products = Parallel.map(@json) do |product|
      base_search = CurrencySearch.new.search(@currencies,product["base_currency"]["iso_code"])
      pair_search = CurrencySearch.new.search(@currencies,product["counter_currency"]["iso_code"])
      begin
        Product.new(base_search[0],pair_search[0],product["price_levels"])
      rescue
        next
      end
    end
    @products.compact!
  end
end