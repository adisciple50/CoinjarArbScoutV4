require_relative 'helpers'
require_relative 'private_client'
class Trader
  include Helpers
  attr_accessor :chain
  def initialize(chain_to_trade)
    @chain = chain_to_trade
    @coinbase = PrivateClient.new
  end
  def run
    determine_price(@chain.start_trade_direction,@chain.start)
    determine_price(@chain.middle_trade_direction,@chain.middle)
    determine_price(@chain.ending_trade_direction,@chain.ending)
    @coinbase.place_order @chain.start.id

    @chain.middle.id
    @chain.start.id
  end
end