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
    #@board = Board.new()
    @board.value = Board.generate_value(@board.value.chomp(','), @board.width, @board.height)

    if @board.save
      head :created
    else
      render :json => @board.errors
    end
  end

  # should be ajax call eventually to the background
  def solve
    @board = Board.new(params[:board])
    @board.value = Board.generate_value(@board.value.chomp(','), @board.width, @board.height)

    puts 'running the local search'

    # height and width flipped since passing the number of blocks not dimensions
    # this just happens to work that way
    solve = (solve_sudoku(@board.value, :xblks => @board.height,:yblks => @board.width));

    if solve[:error]
      render :json => {:error => solve[:error]}
    else
      @sol = Solution.new(:value=>solve['board'])
      @board.solutions << @sol
      # TODO: May want to return the board that was passed in so can check if that's what originally entered?'
      if @board.save
        render :text => @sol.decode
      else
        render :json => @board.errors
      end
    end
  end

  def hint
    puts 'try hint!'

    value = Board.generate_value(params[:value].chomp(','),
              params[:width],
              params[:height])

    data = create_node_consistent_board(value,params[:height].to_i, params[:width].to_i)

    render :json => data
  end

  # TODO: add a save button to keep saving boards perhaps and put in sessions
  def update
  end
end

