module ConstraintSudoku
  def con_ex
    'just anohter thing'
  end

  #prints the sudoku board
  def print_board(board)
    puts "PRINTING BOARD- START\n\n"

    if (board == false)
      #	puts "INVALID SUDOKU BOARD... check input"
	    return
    end

    for x in 0..board.length-1
   		for y in 0..board.length-1
            print board[x][y] ,    "  | "
      end
      puts
    end
    puts "\n\nPRINTING BOARD END"
  end

  # if any values have just one potential, assign it and remove it from a constraint
  # this is arc consistency
  # node  a and b by definition have arc consistency if both have > 2 possible values
  # therefore if node b only has 1 value, and node a must not assign that value
  # this function is assigning b it's only value, and removing value from A's domain
  def make_arc_consistent(board, open, closed, xblks, yblks)
     change_made = true
    while(change_made == true)
	    change_made = false
	    for position in open
		    if board[position[0]][position[1]].length == 1
			    if (!assign_spot(board, open, closed, position[0], position[1], board[position[0]][position[1]][0], xblks, yblks))
			       return false
                                   end
			    change_made = true
		    end
	    end
      end
   	return [board, open, closed]
  end


# validate function, also to do,  have localsearch return the time as a struct passbakc via hash
  def validate(board, xblks, yblks)
     # row in valid

  	for x in 0..board.length-1
    		col = Array.new
 		row = Array.new(board[x]) #need new array not modify board via reference
		block = Array.new(board.length) {Array.new}
    		for y in 0..board.length-1
                        if (board[y][x] != 0)

      				col.concat([board[y][x]])
			end

			puts [y, x]
 			puts ""
			if (board[x][y] != 0)
 				blk = (x/xblks).floor + yblks * (y/yblks).floor
				block[blk-1].concat([board[x][y]])
			end
   	 	end
		row.delete(0)

    		if (col.uniq! != nil or row.uniq! != nil)


			return false
		end


  	end

        for each in block
		if each.uniq! != nil
			return false
		end
	end
	return true
   end








  # fixes an element, this is only called for initial input
  # or assignments that are deduced with 100% certainty through constraint propogation
  # This function is the key that leads to node-consistent boards by default
  def assign_spot(board,open, closed, x, y,val, xblks, yblks)
    open.delete([x,y])
    closed.concat([x,y])
    board[x][y] = val
    for position in open
	    # the last part of this is is checking blocks  mapping of x,y -> blk = x/xblks + yblks*(y/yblks)  using integer division
	    if (position[0] == x or position[1] == y or    (position[0]/xblks +yblks*(position[1]/yblks) == x/xblks + yblks*(y/yblks)  ) )
		    #This segment is a little tricky and deserves further explanation:
		    #This function is called when you are assign a value to a cell
		    #with 100% certaintiy, either through initial input or through constraint inference
		    #Consequently, propogation removes this value from all constrainted cells

		    #The first scenario is where the constrainted cell has only one value, matching
		    #the value we know the updating cell to be.  This represents an invalid sudoku board

		    #The second check is a programming check to avoid the situation where a constrained
		    #cell has only a length 1 array
		    #If this value happens to be the one we're deleting we're back to case 1
		    #Even if it's a different value:
		    #If unchecked, this would crash since delete operates on an array
		    #However delete would "fail" silently anyway since the value we intended to delete
		    #would not be found, so we lose nothing by skipping this case
		    #By default delete just returns nil if the value is not found in list, which
		    #we chose to silently ignore, this is essentially saying:
		    # delete the value from constrainted cells IF it exists in them
  if board[position[0]][position[1]]== val or
        (board[position[0]][position[1]].length == 1 and board[position[0]][position[1]][0] ==val)
                               #   puts "WE HAVE A PROBLEM", position[0], position[1], val
			    return false
		    end
		    if board[position[0]][position[1]].is_a?(Array) == true
			    board[position[0]][position[1]].delete(val)
		    end

	    end
    end
    return true
  end

  #set up initial board from input, return arc-consistent board
  def create_node_consistent_board(input,xblks, yblks)
    dim = input.length

    board = []
    open = []
    closed = []

    	#initial configuration assigns each cell all possible values and lists all cells as open
    for x in 0..dim-1
   		board[x] = []
	    for y in 0..dim-1

		    board[x][y] = (1..dim).to_a
		    open[open.length] = []
              open[open.length-1].concat( [x,y])
	    end
    end

    for x in 0..dim-1
	    for y in 0..dim-1
		    inval = input[x][y]
		    if (inval != 0)

			    #assigns cell and removes cell from open list,
   				# and removes value from cells involved in
			    #constraints with this one
			    if (!assign_spot(board,open,closed, x, y, inval, xblks, yblks))
				    #puts "INVALID SUDOKU BOARD", x, y, inval
   					print_board(board)
				    return false
			    end
		    end
   		end
    end
     boardhash = [board, open]
      if (board != false)
      	boardhash = make_arc_consistent(board, open, closed, xblks, yblks)
      end
      if (boardhash == false)
         return false
      end


      return [boardhash[0], boardhash[1], boardhash[2]]

  end

  def con_example
    #driver code:
    #board =  [ [0, 1, 2, 0], [3,2,1,0], [0,0,3,1], [1,3,0,0] ]
    board = [ [9,0,0,4,0,0,6,0,0], [0,0,7,0,0,0,0,0,3], [0,0,0,1,2,0,0,0,0], [1,2,0,0,4,3,0,5,0],
       [7,0,0,0,0,0,0,0,4], [0,4,0,7,6,0,0,8,9], [0,0,0,0,7,1,0,0,0], [6,0,0,0,0,0,9,0,0], [0,0,4,0,0,8,0,0,2]]
    #board = [[0,1,2,0], [3,2,1,0], [0,0,0,0], [0,0,0,0]]

    boardhash = create_node_consistent_board( board,3,3)
    #boardhash[0] is the board,  boardhash[1] is the open spots

    if (boardhash!= false)
      print_board(boardhash[0])
            #puts "EXITING CONSTRAINT CODE"
            puts "printing closed list", (boardhash[2]) #print closedlist
    else
      #print "Invalid sudoku board input"
    end
  end

  # open.empty?  and boardhash!= false implies puzzle is solved  otherwise if boardhash != false
  # remaining open spots cannot be resolved through constraint propogation perform hureistic search
  # open works nicely for min-conflicts hureistic becuase like I've done above, you can iterate through
  # open spots and check their index to see how many conflict with current node during search

  def hureistic_search (board)   #open useful in finding min conflicts
  end
end

