require_relative 'winner_loader'
require_relative 'winner_builder'
require_relative 'trader'
require "pstore"
trading = true
args = ARGV
loader =  WinnerLoader.new
if args == ["--list"]
  trading = false
  i = 1
  loader.all_winners.each do |winner|
    puts "#{i} - #{winner}"
    i += 1
  end
end

winner_h = loader.winner_h
if args[0] == "--load"
  puts "now loading"
  win = loader.all_winners[args[1]-1]
  puts win
  winner_h = win
end

if args.any?("--latest")
  puts "now loading"
  store = PStore.new "status.pstore"
  filename = ""
  store.transaction do
    filename = store[:winner_file]
  end
  if filename == ""
    raise "this must be your first run - in that case run this script without arguments"
  end
  win = loader.parse_winner filename
  puts win
  winner_h = win
end

def trade(winner_struct_or_object)
  trader = Trader.new winner_struct_or_object,false
  trader.run
end

winner_struct = WinnerBuilder.new(winner_h)
puts "now trading"
puts "#{winner_h}"
while trading
  begin
    trade(winner_struct)
    if args.any?("--latest")
      trading == false
    end
  rescue
    trade(winner_struct)
    if args.any?("--latest")
      trading == false
    end
  end
end
loader =  WinnerLoader.new
winner_h = loader.winner_h
winner_struct = WinnerBuilder.new(winner_h)
if args.any?("--latest")
  while trading
    begin
      trade(winner_struct)
    rescue
      trade(winner_struct)
    end
  end
end