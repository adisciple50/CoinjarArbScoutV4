require_relative 'winner_loader'
require_relative 'winner_builder'
require_relative 'trader'

while true
  winner_h = WinnerLoader.new.winner_h
  winner_struct = WinnerBuilder.new(winner_h)
  trader = Trader.new winner_struct,false
  trader.run
end