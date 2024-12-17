module Helpers
  def determine_price(trade_direction,product_object)
    if trade_direction == :buy
      product_object.ask
    else
      product_object.bid
    end
  end
end
