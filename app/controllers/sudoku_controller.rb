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
      render :json => {:error => @board.errors}
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

    if solve['error']
      render :json => {:error => solve['error']}
    else
      @sol = Solution.new(:value=>solve['board'])
      @board.solutions << @sol
      # TODO: May want to return the board that was passed in so can check if that's what originally entered?'
      @board.save
      # TODO: make the local search return what the board was if a limit was reached
      solve['board'] = @sol.decode
      render :json => solve
    end
  end

  def hint
    value = Board.generate_value(params[:value].chomp(','),
              params[:width],
              params[:height])
    data = create_node_consistent_board(value, params[:height].to_i, params[:width].to_i)

    render :json => data
  end

  # TODO: add a save button to keep saving boards perhaps and put in sessions
  def update
  end

  # Easy test setup to run the boards for our report
  def test
    #each board is an array entry, the comma string simple board representation
    cases = [
      # 2x2 blocks example for completeness, solves with constraints
      '1,2,3,,,4,,,,,1,,2,,,0',
      # 3x2 blocks example to show unsymettric solving ability
      '1,,,,,,,3,,,,,,,6,,,,,,,1,,,4,,,,2,,6,,,,,4',
      # easy 3x3 block from hw
      '6,,,7,,3,,,9,2,,,,,,,,4,,3,,9,,1,,2,,,5,,2,,6,,8,,8,,,,3,,,,2,,1,,4,,9,,6,,,2,,5,,4,,7,,3,,,,,,,,6,1,,,3,,7,,,5',
      # medium 3x3 blocks from hw
      '1,9,,,6,,7,,8,,,,,,7,,,5,7,,,2,3,,,,,,1,,,,,5,,,3,,6,,,,4,,9,,,9,,,,,7,,,,,,1,5,,,3,5,,,9,,,,,,9,,3,,7,,,5,2',
      # hard 3x3 blocks from hw
      '9,,,4,,,6,,,,,7,,,,,,3,,,,1,2,,,,,1,2,,,4,3,,5,,7,,,,,,,,4,,4,,7,6,,,8,9,,,,,7,1,,,,6,,,,,,9,,,,,4,,,8,,,2'
      # A 4x4 block puzzle for the heck of it
      ]
    lengths = [[2,2],[3,2],[3,3],[3,3],[3,3]]
    errs = []

    cases.each_with_index do |val, i|
      puts lengths[i][0].to_s + lengths[i][1].to_s
      @board = Board.new(:value => Board.generate_value(val, lengths[i][0], lengths[i][1]),
                     :width => lengths[i][0],
                     :height => lengths[i][1])
      @board.save

      # for loop through heuristics, minConflicts and the default better heuristic
      ['minConflicts', nil].each do | hn |
        solve = (solve_sudoku(@board.value,
                              :xblks => @board.height,
                              :yblks => @board.width,
                              :heuristic => hn));

          if solve['error']
            errs.push "@#{i},#{hn || 'mostConstrained'}: " + solve['error']
            @sol = Solution.new(:time => solve['time'],
                                :generated => solve['num_boards'],
                                :hn => hn || 'mostConstrained' )
          else
            @sol = Solution.new(:value=> solve['board'],
                                :time => solve['time'],
                                :generated => solve['num_boards'],
                                :hn => hn || 'mostConstrained')
            @board.solutions << @sol

            # TODO: May want to return the board that was passed in so can check if that's what originally entered?'
            @board.save

            puts "\n"
          end
        end
      end

    render :index
  end
end

