# encoding: utf-8
require_relative "board"
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
      
  def make_king
    @king = true
    @directions = [[1, -1], [1, 1], [-1, -1], [-1, 1]]
  end
      
  def perform_slide(end_pos)
    ok_to_move = @directions.any? do |delta| 
      [(@pos[0] + delta[0]), (@pos[1] + delta[1])] == end_pos
    end
    if ok_to_move
      @board.move!(@pos, end_pos)
      true
    else
      false
    end
  end
  
  def on_board?(pos)
    pos.all? { |coord| coord.between?(0, 7) }
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
      raise InvalidMoveError.new("Cannot perform that set of moves")
    end
  end
  
  def perform_moves!(move_sequence)
    if move_sequence.count == 1
      dest = move_sequence.flatten
      return true if perform_slide(dest)
      return true if perform_jump(dest)
      raise InvalidMoveError.new("Cannot slide onto that piece") 
    elsif move_sequence.count > 1
      move_sequence.each do |end_dest|
        if perform_jump(end_dest) == false
          raise InvalidMoveError.new("Cannot make that series of jumps")       
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
#    return (@color == :red) ? "R" : "B" unless @king
    #return (@color == :red) ? "⛄" : "☸" unless @king
    return (@color == :red) ? "☻" : "☻" unless @king
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