# encoding: utf-8

class Piece
  attr_reader :color
  attr_accessor :pos
  def initialize(color, pos, board, king = false)
    @color = color
    @king = king
    if @king
      @directions = [[1, -1], [1, 1], [-1, -1], [-1, 1]]
    else
      @directions = ((color == :red) ? [[1, -1], [1, 1]] : [[-1, -1], [-1, 1]])
    end
    @pos = pos
    @board = board
  end
      
  def perform_slide(end_pos)
    ok_to_move = @directions.any? do |delta| 
      [(@pos[0] + delta[0]), (@pos[1] + delta[1])] == end_pos
    end
    if ok_to_move
      @board.move!(@pos, end_pos)
      true
    else
      puts "invalid move"
      false
    end
  end
  
  def on_board?(pos)
    pos.all? {|coord| coord.between?(0,7)}
  end
  
  def perform_jump(end_pos)
    enemy_spots = find_jumpable_enemies
    pos_jumps = find_jump_destinations(enemy_spots)
    
    if pos_jumps.include?(end_pos)
      @board[(find_jumped_piece(@pos, end_pos))] = nil
      @board.move!(@pos, end_pos)
      true
    else
      p "Sorry you can't jump there"
      false
    end
  end
  
  def inspect
    return (@color == :red) ? "⛄" : "☸" unless @king
    (@color == :red) ? "♔" : "♚"
  end
  
  private
  
  def find_jumpable_enemies
    enemy_spots = []
    @directions.each do |delta|
      pos_plus_one = [(@pos[0] + delta[0]), (@pos[1] + delta[1])]
      unless @board[pos_plus_one].nil? || !(on_board?(pos_plus_one)) ##only jump over pieces, exclude negative values
        if @board[pos_plus_one].color != color #only jump over enemy pieces
          enemy_spots += [pos_plus_one]
        end
      end
    end
    enemy_spots
  end

  def find_jump_destinations(enemy_spots)
    pos_jumps = []
    enemy_spots.each do |enemy_spot|
      move_diff = [enemy_spot[0] - @pos[0], enemy_spot[1] - @pos[1]]
      pos_jumps << [enemy_spot[0] + move_diff[0], enemy_spot[1] + move_diff[1]]      
    end
    pos_jumps.select {|pos_spot| @board[pos_spot] == nil}
  end
  
  def find_jumped_piece(start_pos, end_pos)
    one_jump_diff = [((end_pos[0] - @pos[0]) / 2), ((end_pos[1] - @pos[1]) / 2)]
    [(@pos[0] + one_jump_diff[0]), (@pos[1] + one_jump_diff[1])]
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

  def move!(start_pos, end_pos)
     self[end_pos] = self[start_pos]
     self[start_pos] = nil
     self[end_pos].pos = end_pos 
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

  # def make_pos_nil(pos)
  #   @grid[pos[0]][pos[1]] = nil
  # end
  
  def populate(color)
    #    rows = ((color == :red) ? (0..2) : )
    (0..2).each do |row|
      (0..7).each do |col|
        if row.even?
          if col.even?
            @grid[row][col] = Piece.new(color, [row,col], self)
          end
        else
          if col.odd?
            @grid[row][col] = Piece.new(color, [row,col], self)
          end
        end
      end
    end

  
    (5..7).each do |row|
      (0..7).each do |col|
        if row.even?
          if col.even?
            @grid[row][col] = Piece.new(other_color(color), [row,col], self)
          end
        else
          if col.odd?
            @grid[row][col] = Piece.new(other_color(color), [row,col], self)
          end
        end
      end
    end
  end

end

