# encoding: utf-8

class Piece
  attr_reader :color, :pos
  def initialize(color, pos, board, king = false)
    @color = color
    @directions = ((color == :red) ? [[1, -1], [1, 1]] : [[-1, -1], [-1, 1]])
    @pos = pos
    @board = board
    @king = king
  end
      
  def perform_slide(end_pos)
    ok_to_move = @directions.any? do |delta| 
      [(@pos[0] + delta[0]), (@pos[1] + delta[1])] == end_pos
    end
    
    if ok_to_move
      p "Yes, you can jump there!"
      original_spot = @pos.dup
      @board[end_pos] = self
      # @board[end_pos] = color
      @board.make_pos_nil(original_spot)
    else
      puts "invalid move"
    end
  end
  
  def on_board?(pos)
    pos.all? {|coord| coord.between?(0,7)}
  end
  
  def perform_jump(end_pos)
    enemy_spots = []
    
    ###
    @directions.each  do |delta| 
      pos_plus_one = [(@pos[0] + delta[0]), (@pos[1] + delta[1])]
      unless @board[pos_plus_one].nil? || !(on_board?(pos_plus_one)) ##only jump over pieces
        if @board[pos_plus_one].color != color #only jump over enemy pieces
          enemy_spots += [pos_plus_one]
        end
      end
    end
    ###
    pos_jumps = []
    enemy_spots.each do |enemy_spot|
      move_diff = [enemy_spot[0] - @pos[0], enemy_spot[1] - @pos[1]]
      pos_jumps << [enemy_spot[0] + move_diff[0], enemy_spot[1] + move_diff[1]]      
    end
    pos_jumps.reject! {|pos_spot| @board[pos_spot] != nil}
    if pos_jumps.include?(end_pos)
      one_jump_diff = [((end_pos[0] - @pos[0]) / 2), ((end_pos[1] - @pos[1]) / 2)]
      del_piece = [(@pos[0] + one_jump_diff[0]), (@pos[1] + one_jump_diff[1])]
      original_spot = @pos.dup
      @board.make_pos_nil(del_piece)
      p "Yes, you can jump there!"
      p "you jumped the piece at #{del_piece}"
      @board[end_pos] = color
      @board.make_pos_nil(original_spot)
      return true
    else
      p "Sorry you can't jump there"
      return false
    end
  end
  

  def inspect
    (@color == :red) ? "⛄" : "☸"
  end
  
end



class Board
  attr_reader :grid

  def initialize
    @grid = Array.new(8) { Array.new(8) }
    populate(:red)
  end

  def other_color(color)
    (color == :red) ? :black : :red
  end

  def move
    
  end

  def [](pos)
    @grid[pos[0]][pos[1]]
  end
  
  def []=(pos, piece)
    @grid[pos[0]][pos[1]] = piece
        #
    # if pos.nil? || color.nil?
    #   @grid[pos] = nil
    # else
    #   @grid[pos[0]][pos[1]] = Piece.new(color, pos, self)
    #   #@grid[pos] = Piece.new(color, pos, self)
    # end
  end

  def make_pos_nil(pos) 
    @grid[pos[0]][pos[1]] = nil
  end
  def populate(color)
    #    rows = ((color == :red) ? (0..2) : )
    (0..1).each do |row|
      (0..7).each do |col|
        if row % 2 == 0
          if col % 2 == 0
            @grid[row][col] = Piece.new(color, [row,col], self)
          end
        else
          if col % 2 != 0
            @grid[row][col] = Piece.new(other_color(color), [row,col], self)
          end
        end
      end
    end

  
    (5..7).each do |row|
      (0..7).each do |col|
        if row % 2 == 0
          if col % 2 == 0
            @grid[row][col] = Piece.new(other_color(color), [row,col], self)
          end
        else
          if col % 2 != 0
            @grid[row][col] = Piece.new(other_color(color), [row,col], self)
          end
        end
      end
    end
  end

end

