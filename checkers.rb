# encoding: utf-8
class InvalidMoveError < ArgumentError 
end
  
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
      puts "invalid slide"
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
      false
    end
  end
  
  def perform_moves(move_sequence)
    if valid_move_seq?(move_sequence)
      perform_moves!(move_sequence)
    else
      raise InvalidMoveError
    end
  end
  
  def perform_moves!(move_sequence)
    if move_sequence.count == 1
      dest = move_sequence.flatten
      return true if perform_slide(dest)
      return true if perform_jump(dest)
      raise InvalidMoveError 
    elsif move_sequence.count > 1
      move_sequence.each do |end_dest|
        if perform_jump(end_dest) == false
          raise InvalidMoveError      
        end
      end 
    end
    true
  end
  
  def valid_move_seq?(move_sequence)
    begin
      board_copy = @board.deep_dup
      board_copy[@pos].perform_moves!(move_sequence)
    rescue
      return false
    end
    true
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

  def initialize(fill = true)
    @grid = Array.new(8) { Array.new(8) }
    if fill
    populate(:red)
    #testing_populate(:red)
    end
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
  end
  
  def deep_dup
    board_copy = Board.new(false)
    (0..7).each do |row|
      (0..7).each do |col|
        if @grid[row][col]
          board_copy[[row,col]] = Piece.new(@grid[row][col].color, [row,col], board_copy)
        end
      end
    end
    board_copy
  end

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
  
  
  
  def testing_populate(color)
    (0..0).each do |row|
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
    
    (1..1).each do |row|
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

  
    (3..3).each do |row|
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

