require_relative "piece"
require 'colorize'

class Board
  attr_reader :grid

  def initialize(fill = true)
    @grid = Array.new(8) { Array.new(8) }
    if fill
      populate(:red)
    end
  end

  def other_color(color)
    (color == :red) ? :black : :red
  end

  def move!(start_pos, end_pos)
     self[end_pos] = self[start_pos]
     self[start_pos] = nil
     self[end_pos].pos = end_pos 
     promote_if_deserved(end_pos)
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
          board_copy[[row,col]] = Piece.new(@grid[row][col].color, [row,col], board_copy, @grid[row][col].king)
        end
      end
    end
    board_copy
  end

  def over?
    winner?(:red) || winner?(:black)
  end
  
  def winner?(color)
    num_pieces(other_color(color)) == 0
  end

  def num_pieces(color)
    @grid.flatten.compact.count{ |piece| piece.color == color }
  end
  
  def render
    print "   0  1  2  3  4  5  6  7"
    (0..7).each do |row|
      puts ""
      print "#{row} "
      (0..7).each do |col|
        if row.even?
          if col.even? 
            if @grid[row][col].nil?
              print "   ".on_light_black
            else
              if @grid[row][col].color == :red
              print " #{@grid[row][col].inspect} ".red.on_light_black
              else
              print " #{@grid[row][col].inspect} ".on_light_black
              end
            end
          else
            print "   ".on_light_red
          end
        else
          if col.odd? 
            if @grid[row][col].nil?
              print "   ".on_light_black
            else
              if @grid[row][col].color == :red
              print " #{@grid[row][col].inspect} ".red.on_light_black
              else
              print " #{@grid[row][col].inspect} ".on_light_black
              end
            end
          else
            print "   ".on_light_red
          end
        end
      end
    end
  end
  
  def populate(color)
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
  
  private
  
    def promote_if_deserved(pos)
      piece = @grid[pos[0]][pos[1]]
      if piece.color == :red && pos[0] == 7
        piece.make_king
      elsif piece.color == :black && pos[0] == 0
        piece.make_king
      end
    end
  
end

