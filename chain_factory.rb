require_relative 'chain'
class ChainFactory
  attr_reader :chains
  def initialize(all_product_objects,fiat_currency_object,stake_amount)
    @start_currency = fiat_currency_object
    @stake = stake_amount
    # puts @stake
    unless @start_currency.is_fiat?
      raise "start currency is not a fiat currency object - it is a #{@start_currency.class.name}"
    end
    @starts = []
    @middles = []
    @products = all_product_objects
    @chains = []
  end
  def build
    @starts = @products.select{ |product| product.pair.id_or_iso_code == @start_currency.id_or_iso_code}
    @middles = @products
    @starts.each do |product|
      @middles.delete(product)
    end
    Parallel.each(@starts,in_threads:@starts.count) do |start|
      base_currency = start.base.id_or_iso_code
      mids_branches = @middles.select {|mid| mid.base.id_or_iso_code == base_currency || mid.pair.id_or_iso_code == base_currency }
      mids_branches.each do |mid|
        if mid.base.id_or_iso_code == base_currency
          end_currency = mid.pair.id_or_iso_code
          ending = @starts.select {|start| start.base.id_or_iso_code == end_currency}
        elsif mid.pair.id_or_iso_code == base_currency
          end_currency = mid.base.id_or_iso_code
          ending = @starts.select {|start| start.base.id_or_iso_code == end_currency}
        end
        if ending[0].nil?
          next
        end
        @chains << Chain.new(start,mid,ending[0])
      end
    end
    @chains.compact!
  end
end