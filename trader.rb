require_relative 'helpers'
require_relative 'private_client'
require_relative 'private_sandbox'
require 'json'
require 'pstore'
class Trader
  include Helpers
  attr_accessor :chain
  def initialize(winner_builder_to_trade,testing=true)
    @chain = winner_builder_to_trade
    @status_store = PStore.new('status.pstore')
    if testing
      @coinbase = PrivateSandbox.new
    else
      @coinbase = PrivateClient.new
    end
  end
  def set_status(status_code)
    @status_store.transaction do
      @status_store[:code] = status_code
    end
  end
  def get_status
    status = ''
    @status_store.transaction do
      status = @status_store[:code]
    end
    status
  end
  def wait_until_trade_is_complete(order)
    order = @coinbase.get_order(order["oid"])
    status = order["status"]
    puts JSON.parse order.to_s
    while status != "filled"
      order = @coinbase.get_order(order["oid"])
      puts "order status is\n ===="
      puts JSON.parse order.to_s
      status = order["status"].to_s
      sleep 1
    end
  end
  def run
    begin
    if get_status != 1 || get_status !=2 || get_status !=3
      set_status 1
    end
    rescue
      set_status 1
    end
    if get_status == 1
      @start_oid = @coinbase.place_order(@chain.start,@chain.start_price,@chain.start_trade_direction,@chain.start_amount)
      puts @start_oid
      wait_until_trade_is_complete(@start_oid)
      set_status 2
    end
    if get_status == 2
      @middle_oid = @coinbase.place_order(@chain.middle,@chain.middle_price,@chain.middle_trade_direction,@chain.middle_amount)
      puts @middle_oid
      wait_until_trade_is_complete(@middle_oid)
      set_status 3
    end
    if get_status == 3
      @ending_oid = @coinbase.place_order(@chain.ending,@chain.ending_price,@chain.ending_trade_direction,@chain.ending_amount)
      puts @ending_oid
      wait_until_trade_is_complete(@ending_oid)
    end
  end
end