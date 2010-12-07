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
    val = params[:board][:value].chomp(',')
    puts Board.new(:value=>Board.generate_value(val), :width=>3,:height=>3)

    render :text => 'ok'
  end

  # should be ajax call eventually to the background
  def solve

  end
end

