require_relative "piece"
require_relative "board"

class Game
  def initialize(player1_name = "Red", player2_name = "Black")
    @board = Board.new
    @red_player = HumanPlayer.new(player1_name, :red)
    @black_player = HumanPlayer.new(player2_name, :black)
    @current_player = @red_player
    play
  end
  
  def play
    puts "Welcome to chess!"
    
    until @board.over?
      @board.render
      begin
      piece_from = get_from_piece
      puts "Where do you want to move it to?"
      piece_to = gets.chomp.split("").map(&:to_i)
      p piece_from
      # piece_from = [2,0]
      # piece_to = [[3,1]]
      @board[piece_from].perform_moves([piece_to])
        rescue  => e
          @board.render
          puts "\n#{e.message}"
#           puts "You can't move there"
          retry
      end
      switch_players
    end
    
    winner = ((@board.winner?(:red)) ? @red_player : @black_player) 
    
    puts "#{winner.name} is the winner!!"
  end
  
  def switch_players
    @current_player = ((@current_player == @red_player) ? @black_player : @red_player)
  end
  
  def get_from_piece
    begin
    puts "\n#{@current_player.name}, select a #{@current_player.color} piece to move"
    piece_from = gets.chomp.split("").map(&:to_i)
    if @board[piece_from].nil? || (@board[piece_from].color != @current_player.color)
      raise NotYourPieceError.new("That is not your piece")
    end
      rescue => e
        @board.render
        puts "\n#{e.message}"
        retry
      end
    piece_from
  end
end


class HumanPlayer
  attr_reader :color, :name
  
  def initialize(name, color)
    @name = name
    @color = color
  end
  
end

class InvalidMoveError < ArgumentError 
end
  
class NotYourPieceError < ArgumentError 
end

Game.new