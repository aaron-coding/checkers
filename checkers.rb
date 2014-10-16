require_relative "piece"
require_relative "board"

class Game
  def initialize(player1_name = "Red", player2_name = "Black")
    @board = Board.new
    @red_player = HumanPlayer.new(player1_name, :red)
    @black_player = HumanPlayer.new(player2_name, :black)
    play
  end
  
  def play
    puts "Welcome to chess!"
    
    until @board.over?
      puts "#{@red_player.name} select a piece to move"
      piece_from = gets.chomp
    end
    
  end
  
end


class HumanPlayer
  attr_reader :color
  
  def initialize(name, color)
    @name = name
    @color = color
  end
  
end

class InvalidMoveError < ArgumentError 
end
  