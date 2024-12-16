class Chain
  attr_reader :profit
  def initialize(start_product,middle_product,end_product)
    @start = start_product
    @start_trade_direction = :buy
    @middle = middle_product
    @middle_trade_direction = :undetermined
    @ending = end_product
    @ending_trade_direction = :sell
    start_trade_direction
    start_trade
    middle_trade_direction
    middle_trade
    ending_trade_direction
    ending_trade
    calculate_profit
  end
  def start_trade_direction
    unless @start.pair.is_fiat?
      @start_trade_direction = :sell
    end
  end
  def middle_trade_direction
    if @start.base.id_or_iso_code == @middle.base.id_or_iso_code
      @middle_trade_direction = :sell
    else
      @middle_trade_direction = :buy
    end
  end
  def ending_trade_direction
    unless @ending.pair.is_fiat?
        @ending_trade_direction = :sell
    end
  end
  def buy(product,amount)
    amount / product.ask.to_f
  end
  def sell(product,amount)
    amount * product.bid.to_f
  end
  def floor(product,amount,buy_or_sell)
    if buy_or_sell == :buy
      tick_exp = product.determine_ask_tick_exponent[:tick_exponent].to_i * -1
      # puts "tick exponent is #{tick_exp}"
      amount.to_f.floor(tick_exp)
    else
      tick_exp = product.determine_bid_tick_exponent[:tick_exponent].to_i * -1
      # puts "tick exponent is #{tick_exp}"
      amount.to_f.floor(tick_exp)
    end
  end
  def calculate_dust(product,amount,buy_or_sell)
    0 - floor(product,amount,buy_or_sell) + amount
  end

  def calculate_fee(result,buy_or_sell,type=:fiat)
    if :fiat
      apply_fiat_fee(result)
    elsif :crypto
      apply_crypto_fee(result,buy_or_sell)
    end
  end
  def apply_fiat_fee(amount)
    fee= 1-0.001
    amount * fee
  end
  def apply_crypto_fee(amount,buy_or_sell,maker=1,taker=1-0.0006)
    if buy_or_sell == :buy
      amount * taker
    elsif buy_or_sell == :sell
      amount * maker
    end
  end
  def start_trade
    start_trade_direction
    if @start_trade_direction == :buy
      @start_result = buy(@start,@start.pair.amount)
      @start_amount = floor(@start,@start_result,:buy)
      @start_fee = calculate_fee(@start_result,:buy)
      @start_result = apply_fiat_fee(@start_result)
      # @start.base.amount = @start_result
      @start_dust = calculate_dust(@start,@start_result,:buy)
    elsif @start_trade_direction == :sell
      @start_result = sell(@start,@start.base.amount)
      @start_amount = floor(@start,@start_result,:sell)
      @start_fee = calculate_fee(@start_result,:sell)
      @start_result = apply_fiat_fee(@start_result)
      # @start.pair.amount = @start_result
      @start_dust = calculate_dust(@start,@start_result,:sell)
    end
  end
  def middle_trade
    middle_trade_direction
    if @middle_trade_direction == :buy
      @middle_result = buy(@middle,floor(@middle,@start_result,:buy))
      @middle_amount = floor(@middle,@middle_result,:buy)
      @middle_fee = calculate_fee(@middle_result,:buy)
      if @middle.is_fiat_trade
        @middle_result = apply_crypto_fee(@middle_result,:buy)
      else
        @middle_result = apply_fiat_fee(@middle_result)
      end
      # @middle.pair.amount = @middle_result
      # @middle.base.amount = @start_result
      @middle_dust = calculate_dust(@middle,@middle_result,:buy)
    elsif @middle_trade_direction == :sell
      floor = floor(@middle,@start_result,:sell)
      # puts "middle:#{floor}"
      @middle_result = sell(@middle,floor)
      @middle_amount = floor(@middle,@middle_result,:sell)
      @middle_fee = calculate_fee(@middle_result,:sell)
      if @middle.is_fiat_trade
        @middle_result = apply_crypto_fee(@middle_result,:buy)
      else
        @middle_result = apply_fiat_fee(@middle_result)
      end
      # @middle.pair.amount = @middle_result
      @middle_dust = calculate_dust(@middle,@middle_result,:sell)
    end
  end
  def ending_trade
    ending_trade_direction
    if @ending_trade_direction == :buy
      @ending_result = buy(@ending,floor(@ending,@middle_result,:buy))
      @ending_amount = floor(@ending,@ending_result,:buy)
      @ending_fee = calculate_fee(@ending_result,:buy)
      @ending_result = apply_fiat_fee(@ending_result)
      # @ending.pair.amount = @middle_result
      # @ending.base.amount = @ending_result
      @ending_dust = calculate_dust(@ending,@ending_result,:buy)
    elsif @ending_trade_direction == :sell
      @ending_result = sell(@ending,floor(@ending,@middle_result,:sell))
      @ending_amount = floor(@ending,@ending_result,:sell)
      @ending_fee = calculate_fee(@ending_result,:sell)
      @ending_result = apply_fiat_fee(@ending_result)
      # @ending.base.amount = @middle_result
      # @ending.pair.amount = @ending_result
      @ending_dust = calculate_dust(@ending,@ending_result,:sell)
    end
  end
  def calculate_profit
    @profit = @ending_result - @start.pair.amount.to_f
  end

  def to_s
    if @start_trade_direction == :buy
      start_price = @start.ask
    else
      start_price = @start.bid
    end
    if @middle_trade_direction == :buy
      middle_price = @middle.ask
    else
      middle_price = @middle.bid
    end
    if @ending_trade_direction == :buy
      ending_price = @ending.ask
    else
      ending_price = @ending.bid
    end

    "
    \n
    \n====
    \nstake: #{@start.pair.amount.to_f}
    \nfinal result:#{@ending_result}
    \nprofit: #{@profit}
    \n           |       |     |currency |amount in opposing currency    |result minus |
    \n           |id     |price|for price|to currency for price|direction|dust and fees|
    \n- start    |#{@start.id} |#{start_price}  |#{@start.display_currency} |#{@start_amount}|#{@start_trade_direction}|#{@start_result}
    \n- middle   |#{@middle.id}|#{middle_price} |#{@middle.display_currency}|#{@middle_amount}|#{@middle_trade_direction}|#{@middle_result}
    \n- end      |#{@ending.id}|#{ending_price} |#{@ending.display_currency}|#{@ending_amount} |#{@ending_trade_direction}|#{@ending_result}
    \n====
    "
  end
  def to_h
    if @start_trade_direction == :buy
      start_price = @start.ask
    else
      start_price = @start.bid
    end
    if @middle_trade_direction == :buy
      middle_price = @middle.ask
    else
      middle_price = @middle.bid
    end
    if @ending_trade_direction == :buy
      ending_price = @ending.ask
    else
      ending_price = @ending.bid
    end

    {
      stake:@start.pair.amount.to_f,
      result:@ending_result,
      profit:@profit,
      start_id:@start.id,start_price:start_price,start_display_currency:@start.display_currency,start_amount:@start_amount,start_trade_direction:@start_trade_direction,start_result:@start_result,
      middle_id:@middle.id,middle_price:middle_price,middle_display_currency:@middle.display_currency,middle_amount:@middle_amount,middle_trade_direction:@middle_trade_direction,middle_result:@middle_result,
      ending_id:@ending.id,ending_price:ending_price,ending_display_currency:@ending.display_currency,ending_amount:@ending_amount,ending_trade_direction:@ending_trade_direction,ending_result:@ending_result
    }
  end
end