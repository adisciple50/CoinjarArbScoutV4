require_relative 'chain'
require_relative 'currency'
class WinnerBuilder
  attr_reader :start,:start_price,:start_trade_direction,:start_amount,:middle,:middle_price,:middle_amount,:middle_trade_direction,:ending,:ending_price,:ending_amount,:ending_trade_direction
  def initialize(winner_hash)
    @stake = winner_hash["stake"]
    @amount = winner_hash["amount"]
    @start = winner_hash["start_id"]
    @start_trade_direction = winner_hash["start_trade_direction"]
    @start_price = winner_hash["start_price"]
    @start_amount = winner_hash["start_amount"]
    @middle = winner_hash["middle_id"]
    @middle_price = winner_hash["middle_price"]
    @middle_amount = winner_hash["middle_amount"]
    @middle_trade_direction = winner_hash["middle_trade_direction"]
    @ending = winner_hash["ending_id"]
    @ending_price = winner_hash["ending_price"]
    @ending_amount = winner_hash["ending_amount"]
    @ending_trade_direction = winner_hash["ending_trade_direction"]
  end
end