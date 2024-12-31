require 'json'
class WinnerLoader
  attr_reader :winners_a
  def initialize
    @winners = Dir.glob("winners/*.json")
    @filenames = []
    @winners_a = []
    parse_winners
  end
  def winner_h
    @winners_a.sort {|a,b| a["profit"].to_f <=> b["profit"].to_f}[-1]
  end
  def all_winners
    @winners_a.sort {|a,b| a["profit"].to_f <=> b["profit"].to_f}
  end
  def parse_winners
    @winners.each do |winner_file|
      open("./#{winner_file}") do |f|
        to_parse = f.read
        winner = JSON.parse(to_parse).to_h
        winner["filename"] = winner_file
        @winners_a << winner
      end
    end
    def parse_winner(filename)
      @winners_a.clear
      open("./winners/#{filename}") do |f|
        to_parse = f.read
        winner = JSON.parse(to_parse).to_h
        winner["filename"] = winner_file
        @winners_a << winner
      end
    end
  end
end
