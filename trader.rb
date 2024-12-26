require_relative 'helpers'
require_relative 'private_client'
require_relative 'private_sandbox'
require 'json'
class Trader
  include Helpers
  attr_accessor :chain
  def initialize(chain_to_trade,testing=true)
    @chain = chain_to_trade
    if testing
      @coinbase = PrivateSandbox.new
    else
      @coinbase = PrivateClient.new
    end
  end
  def wait_until_trade_is_complete(orderid)
    puts JSON.parse @coinbase.get_order(orderid)
    wait 1
  end
  def run
    start_price = determine_price(@chain.start_trade_direction,@chain.start)
    middle_price = determine_price(@chain.middle_trade_direction,@chain.middle)
    ending_price = determine_price(@chain.ending_trade_direction,@chain.ending)
    @start_oid = @coinbase.place_order @chain.start.id,start_price,@chain.start_trade_direction,@chain.start_amount
    wait_until_trade_is_complete(@start_oid)
    @middle_oid = @coinbase.place_order @chain.middle.id,middle_price,@chain.middle_trade_direction,@chain.middle_amount
    wait_until_trade_is_complete(@middle_oid)
    @ending_oid = @coinbase.place_order @chain.ending.id,ending_price,@chain.ending_trade_direction,@chain.ending_amount
    wait_until_trade_is_complete(@ending_oid)
  end
end