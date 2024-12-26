require 'json'
class WinnerLoader
  attr_reader :winners_a
  def initialize
    @winners = Dir.glob("winners/*.json")
    @winners_a = []
    @winners.each do |winner_file|
      open("./#{winner_file}") do |f|
        to_parse = f.read
        @winners_h << JSON.parse(to_parse)
      end
    end
  end
  def winner_h
    @winners_a.sort {|a,b| a["profit"].to_f <=> b["profit"].to_f}[-1]
  end
end
