require 'local_search'
class SudokuController < ApplicationController
  include LocalSearch
  def index
    #example
  end

  # stat a new board, should be ajax
  def init
  end

  # should be ajax call eventually to the background
  def solve
  end
end

