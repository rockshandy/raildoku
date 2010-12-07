require 'local_search'
class SudokuController < ApplicationController
  include LocalSearch
  def index
    @board = Board.new
    #example
  end

  # stat a new board, should be ajax, perhaps should start solving in background
  def init
    # the javascript puts an extra comma at end so get rid of it
    #val = Board.generate_value(params[:board][:value].chomp(','))

    #TODO: try to make this an initialize thing?
    @board = Board.new(params[:board])
    @board.value = Board.generate_value(@board.value.chomp(','), @board.width, @board.height)

    if @board.save
      message = 'okay'
    else
      message = 'bad'
    end

    render :text => message
  end

  # should be ajax call eventually to the background
  def solve
    @board = Board.new(params[:board])
    @board.value = Board.generate_value(@board.value.chomp(','), @board.width, @board.height)

    puts 'running the local search'

    # height and width flipped since passing the number of blocks not dimensions
    # this just happens to work that way
    solve = (solve_sudoku(@board.value, :xblks => @board.height,:yblks => @board.width));
    @board.solutions << Solution.new(:value=>solve) if solve.kind_of?(Array)

    @board.save
    render :text => 'bah'
  end

  # TODO: add a save button to keep saving boards perhaps and put in sessions
  def update
  end
end

