require 'constraint_sudoku.rb'
module LocalSearch
  include ConstraintSudoku
  def woo
    'just a looky loo'
  end
	#	Function: uniqueLocalCells
	#
	#	Determines the unique local cells who will be in contention for the specified's cells possible value.
	#	In the sudoku problem domain these cells may be from the collumn, row or block group.
	#
	#	Input:
	#		board           : the board to evaluate
	#		x               : the x position of the cell to evaluate
	#		y               : the y position of the cell to evaluate
	#	Returns: The unique cells in the collumn, row and block group.
	def uniqueLocalCells(board, x, y)
		cells=Array.new();
	
	
		#collumn cells
		for posY in 0...board[0].length()
			cellUniqueness=true;
			cells.each do |currentCell|
				if currentCell[:x]==x and currentCell[:y]==posY
					cellUniqueness=false;
					break;
				end
			end
			if cellUniqueness#add it if it is unique
				newCellEntry=Array.new(1);
				if board[x][posY].is_a?(Array)
					newCellEntry[0]={:x=>x, :y=>posY, :values=>board[x][posY].dup()};
				else
					newCellEntry[0]={:x=>x, :y=>posY, :values=>board[x][posY]};
				end
				cells.concat(newCellEntry);
			end
		end
	
		#row cells
		for posX in 0...board.length()
			cellUniqueness=true;
			cells.each do |currentCell|
				if currentCell[:x]==posX and currentCell[:y]==y
					cellUniqueness=false;
					break;
				end
			end
			if cellUniqueness#add it if it is unique
				newCellEntry=Array.new(1);
				if board[posX][y].is_a?(Array)
					newCellEntry[0]={:x=>posX, :y=>y, :values=>board[posX][y].dup()};
				else
					newCellEntry[0]={:x=>posX, :y=>y, :values=>board[posX][y]};
				end
				cells.concat(newCellEntry);
			end
		end
	
		#block group cells
	
		#TODO: figure out size of block groups in general (square root of width and height?) and finish this section
		blockXsize=Math.sqrt(board.length());
		blockYsize=Math.sqrt(board[0].length());
		blockXnumber=(x/blockXsize).floor;
		blockYnumber=(y/blockYsize).floor;
		xStartingPos=(blockXnumber*blockXsize).floor;#index starts at 0
		yStartingPos=(blockYnumber*blockYsize).floor;
	
		for posX in xStartingPos...xStartingPos+blockXsize
			for posY in yStartingPos...yStartingPos+blockYsize
				cellUniqueness=true;
				cells.each do |currentCell|
					if currentCell[:x]==posX and currentCell[:y]==posY
						cellUniqueness=false;
						break;
					end
				end
				if cellUniqueness#add it if it is unique
				newCellEntry=Array.new(1);
				if board[posX][posY].is_a?(Array)
					newCellEntry[0]={:x=>posX, :y=>posY, :values=>board[posX][posY].dup()};
				else
					newCellEntry[0]={:x=>posX, :y=>posY, :values=>board[posX][posY]};
				end
				cells.concat(newCellEntry);
			end
			end
		end
		return cells;
	end

	#uniqueLocalCells test code
	#board=Array.new(3);
	#for row in 0..3
	#	board[row]=Array.new(3)
	#	for collumn in 0..3
	#		entry=Array.new(1,collumn);
	#		board[row][collumn]=entry;
	#	end
	#end
	#p board;
	#p uniqueLocalCells(board,1,1);
	#p uniqueLocalCells(board,1,1).length();

	#	Function: numConflicts
	#
	#	Determines the number of conflicts generated by fixing a specified value to the given cell.
	#	Evaluated by getting the count of local cells who can be assigned {valueToEvaluate}.
	#
	#	This function is assisted by [uniqueLocalCells].
	#
	#	Input:
	#		board           : the board to evaluate
	#		x               : the x position of the cell to evaluate
	#		y               : the y position of the cell to evaluate
	#		valueToEvaluate : the value to attempt to substitute in order to determe the number of conflicting cells
	#	Returns: The number of cells conflicting with this attribute assignment.
	def numConflicts(board, x, y, valueToEvaluate)
		number=0;
		uniqueLocalCells(board,x,y).each{|currentCell|
			if currentCell[:values].is_a?(Array)
				if currentCell[:values].include?(valueToEvaluate)
					number=number+1;
				end
			else
				if currentCell[:values]==valueToEvaluate
					number=number+1;
				end
			end
		}
		return number;
	end

	#numConflicts test code
	#board=Array.new(3);
	#for row in 0..3
	#	board[row]=Array.new(3)
	#	for collumn in 0..3
	#		entry=Array.new(1,collumn);
	#		board[row][collumn]=entry;
	#	end
	#end
	#p board;
	#p numConflicts(board,0,0,1);



	#	Function: degree
	#
	#	Determines the degree or the number of constraints on unassigned variables of a variable.
	#	In other words it determines the number of unassigned local cells.
	#
	#	This function is assisted by [uniqueLocalCells].
	#
	#	Input:
	#		board           : the board to evaluate
	#		x               : the x position of the cell to evaluate
	#		y               : the y position of the cell to evaluate
	#	Returns: The degree of the cell.
	def degree(board, x, y)
		number=0;
		uniqueLocalCells(board,x,y).each{|currentCell|
			if currentCell[:values].is_a?(Array) and currentCell[:values].length()>1
				number=number+1;
			end
		}
		return number;
	end

	#degree test code
	#board=Array.new(3);
	#for row in 0..3
	#	board[row]=Array.new(3)
	#	for collumn in 0..3
	#		entry=Array.new(2,collumn);
	#		board[row][collumn]=entry;
	#	end
	#end
	#p board;
	#p degree(board,0,0);


	#	Function: leastConstrainingValue
	#
	#	Determines the least constraining value of a variable (cell in the sudoku problem domain).
	#	[numConflicts] is called for all possible values of the cell to determine the value with least constraint.
	#
	#	This function is assisted by [numConflicts].
	#
	#	Input:
	#		board           : the board to evaluate
	#		x               : the x position of the cell to evaluate
	#		y               : the y position of the cell to evaluate
	#	Returns: The least constraining value for the given cell.
	def leastConstrainingValue(board, x, y)
		leastConstraining={:value=>board[x][y][0],:heuristicValue=>numConflicts(board,x,y,board[x][y][0])}#initially asign least constraining value to first element possible
		if board[x][y].is_a?(Array)
			board[x][y].each{|possibleValue|
				currentHeuristic=numConflicts(board,x,y,possibleValue);
				if currentHeuristic<leastConstraining[:heuristicValue]
					leastConstraining[:value]=possibleValue;
					leastConstraining[:heuristicValue]=currentHeuristic;
				end
			}
		else
			leastConstraining[:value]=board[x][y];
			leastConstraining[:heuristicValue]=x*y+1;
		end
		return leastConstraining[:value];
	end

	#leastConstrainingValue testing code
	#board=Array.new(3);
	#for row in 0..3
	#	board[row]=Array.new(3)
	#	for collumn in 0..3
	#		entry=Array.new(4);
	#		for entryVal in 1..4
	#			entry[entryVal-1]=(entryVal);
	#		end
	#		board[row][collumn]=entry;
	#	end
	#end
	#board[0][1]=1;
	#p board;
	#p leastConstrainingValue(board,0,0);


	#	Function: modifyBoard
	#
	#	Returns a copy of the old board with the possibilities array modified to reflect the new board.
	#	This modification is the removal of the assigned value from the array of the possibilities (at the position changed) assigned to the new board.
	#
	#	Input:
	#		newBoard        : the new board to evaluate
	#		oldBoard        : the old board to evaluate
	#	Returns: The board with the value assigned to {newboard} removed from its possibilities array.
	def modifyBoard(newBoard,oldBoard)
		modifiedBoard=Array.new(newBoard.length());
		for row in 0...newBoard.length()
			modifiedBoard[row]=Array.new(newBoard.length());
			for collumn in 0...newBoard[0].length()
				if oldBoard[row][collumn].is_a?(Array) and newBoard[row][collumn].is_a?(Array)
					#both an array so one is not assigned
					#copy: this cell is not the changed one
					modifiedBoard[row][collumn]=oldBoard[row][collumn].dup();
				else
					#at least one is assigned
					if oldBoard[row][collumn].is_a?(Array)
						#need to remove assigned value
						modifiedBoard[row][collumn]=oldBoard[row][collumn].dup()-Array.new(1,newBoard[row][collumn]);
					else
						#copy: this cell is not the changed one
						modifiedBoard[row][collumn]=oldBoard[row][collumn];
					end
				end
			end
		end
		return modifiedBoard;
	end


	#modifyBoard test code
	#board=[[5,4,3,2],[3,2,1,0]];
	#board2=[[[5,2,3],4,3,2],[3,2,1,0]]
	#p modifyBoard(board,board2);

	# board=[[1,2,3],[4,5,6],[7,8,9]]
	# board2=[[1,[2,8],3],[4,5,6],[7,8,9]]
	# p modifyBoard(board,board2);

	#	Function: popBoard
	#
	#	Removes the first board from the queue.
	#
	#	Input:
	#		queue           : the queue to evaluate
	#	Returns: Updated copy of the queue.
	def popBoard(queue)
		resultingQueue=Array.new();
		resultingQueue.concat(queue);
		resultingQueue.delete_at(0);
		return resultingQueue;
	end

	#	popBoard functionality testing code
	#myar=Array.new(3);
	#myar[0]=0;
	#myar[1]=1;
	#myar[2]=2;
	#p myar;
	#p popBoard(myar);
	#p myar;


	#	Function: enqueueBoard
	#
	#	Returns a copy of the queue with the newBoard placed in front followed by the modified old board and then the queue.
	#	A queue should start off with the initial board for a new local search.
	#	Before {newBoard} is appended the old board is modified, poped off {queue} and reappended to the front of {queue} in its modified form.
	#
	#	This function is assisted by [modifyBoard] where {oldBoard} is the first element of the queue and [popBoard].
	#
	#	Input:
	#		newBoard        : the new board to evaluate
	#		queue           : the queue to evaluate
	#	Returns: Updated copy of queue.
	def enqueueBoard(newBoard,queue)
		updatedQueue=Array.new(2);
		updatedQueue[0]=newBoard;
		#entry 0 of queue is the old board
		updatedQueue[1]=modifyBoard(newBoard,queue[0]);
		updatedQueue.concat(popBoard(queue));
		return updatedQueue;
	end

	#enqueueBoard test code
	#myqueue=Array.new();
	#board=Array.new(3);
	#for row in 0..3
	#	board[row]=Array.new(3)
	#	for collumn in 0..3
	#		entry=Array.new(2,(collumn));
	#		entry[0]=2;
	#		board[row][collumn]=entry;
	#	end
	#end
	#queueentry=Array.new(1,board);
	#myqueue.concat(queueentry);
	#board2=Array.new(3);
	#for row in 0..3
	#	board2[row]=Array.new(3)
	#	for collumn in 0..3
	#		entry=Array.new(2,collumn);
	#		board2[row][collumn]=entry;
	#	end
	#end
	#board2[1][1]=1;
	#p queueentry=Array.new(1,board2);
	#p enqueueBoard(queueentry[0],myqueue);




	#	Function: cullBadBoards
	#
	#	Removes bad boards from queue by iteratively looking through games for nodes which cannot have a value.
	#
	#	Input:
	#		queue           : the queue to evaluate
	#	Returns: Updated copy of the queue without bad boards.
	def cullBadBoards(queue, xblks, yblks)
		badBoards=Array.new();
		queue.each{|board|
			goodBoard=true;
			checkBoard=Array.new()
			for row in 0...board.length()
				checkBoard[row]=Array.new();
				for collumn in 0...board[0].length()
					if board[row][collumn].is_a?(Array)#if it hasn't been assigned a value
						if board[row][collumn].length()==1
							checkBoard[row][collumn]=board[row][collumn][0];
						else
							checkBoard[row][collumn]=0;
						end
					else
						checkBoard[row][collumn]=board[row][collumn];
					end
				end
			end
			boardHash=create_node_consistent_board(checkBoard,xblks,yblks)
		
			if boardHash==false
				goodBoard=false;
			
			end
			board.each{|row|
				row.each{|cell|
					if cell.is_a?(Array)
						if cell.length==0#this is a bad board because this cell has 0 possibilities
							goodBoard=false;
							break;
						end
					end
					if cell==nil
						goodBoard=false;
			
					end
				}
			
			}
			if !goodBoard==false
				for row in 0...board.length()
					for collumn in 0...board[0].length()
						if !board[row][collumn].is_a?(Array)
							uniqueLocalCells(board,row,collumn).each{|cellToComp|
						
								if !(cellToComp[:values].is_a?(Array)) and cellToComp[:values]==board[row][collumn] and
								!(cellToComp[:x]==row and cellToComp[:y]==collumn)
						
									goodBoard=false
								
								elsif cellToComp[:values].is_a?(Array) and cellToComp.length()==1 and
									cellToComp[:values][0]==board[row][collumn] and !(cellToComp[:x]==row and 
									cellToComp[:y]==collumn)
								
										goodBoard=false
								
								end
							}
						elsif board[row][collumn].length()==1
							uniqueLocalCells(board,row,collumn).each{|cellToComp|
						
								if !(cellToComp[:values].is_a?(Array)) and cellToComp[:values]==board[row][collumn][0] and 
								   !(cellToComp[:x]==row and cellToComp[:y]==collumn)
								
									goodBoard=false
								
								elsif cellToComp[:values].is_a?(Array) and cellToComp.length()==1 and 
									cellToComp[:values][0]==board[row][collumn][0] and !(cellToComp[:x]==row and 
									cellToComp[:y]==collumn)
								
										goodBoard=false
								
								end
							}
						end
					end
				end
			end
			if goodBoard==false
				newBadEntry=Array.new(1,board);
				badBoards.concat(newBadEntry);
			end
		}
	
		return (queue-badBoards);
	end

	#cullBadBoards testing code
	# board=Array.new(3);
	# for row in 0..3
		# board[row]=Array.new(3)
		# for collumn in 0..3
			# entry=Array.new(1,(collumn));
			# board[row][collumn]=entry;
		# end
	# end
	# queue=Array.new(1,board);
	# queue[0][0][0]=Array.new();
	# queue[0][0][0]=nil;
	# board=Array.new(3);
	# for row in 0..3
		# board[row]=Array.new(3)
		# for collumn in 0..3
			# entry=Array.new(1,(collumn));
			# board[row][collumn]=entry;
		# end
	# end
	# queue.concat(Array.new(1,board));
	# p queue;
	# p cullBadBoards(queue);

	#	Function: minConflicts
	#
	#	Determines the best cell to select and value to substitute by determining the cell/value combo that generates the absolute minimum number of conflicts.
	#	This is determined by iterating over the entire board making calls to the function [numConflicts] using that cell's possible value.
	#
	#	Input:
	#		board           : the board to evaluate
	#	Returns: The board fulfilling this heuristic.
	def minConflicts(board)
		if board[0][0].is_a?(Array)
			bestCell={:x=>0,:y=>0,:value=>board[0][0][0],:heuristicEvaluation=>numConflicts(board,0,0,board[0][0][0])};#first cell is currently the best option
		else
			bestCell={:x=>0,:y=>0,:heuristicEvaluation=>board[0].length()*board.length()+1};#this cell already has a value so set it as the current best one with a conflict value greater than a completly unassigned cell grouping(the count of the entire board +1 is greater than any possible minConflicts value)
		end
	
		for row in 0...board.length()
			for collumn in 0...board[0].length()
				if board[row][collumn].is_a?(Array) and board[row][collumn].length()>1
					board[row][collumn].each{|possibleValue|
						evaluatedHeuristic=numConflicts(board,row,collumn,possibleValue);
						if evaluatedHeuristic<bestCell[:heuristicEvaluation]#new value is lower so its now the best
							bestCell[:x]=row;
							bestCell[:y]=collumn;
							bestCell[:heuristicEvaluation]=evaluatedHeuristic;
							bestCell[:value]=possibleValue;
						end
					}
				end
			end
		end
	
		#assigning best value to board
		newBoard=Array.new(board.length());
		for row in 0...board.length()
			newBoard[row]=Array.new(board[0].length());
			for collumn in 0...board[0].length()
				if board[row][collumn].is_a?(Array)
					newBoard[row][collumn]=board[row][collumn].dup();
				else
					newBoard[row][collumn]=board[row][collumn];
				end
			end
		en
		#newBoard=board.dup();
		newBoard[bestCell[:x]][bestCell[:y]]=bestCell[:value];
		return newBoard;#below not run
	end

	#minConflicts test code
	#board=Array.new(3);
	#for row in 0..3
	#	board[row]=Array.new(3)
	#	for collumn in 0..3
	#		entry=Array.new(4);
	#		for entryVal in 1..4
	#			entry[entryVal-1]=(entryVal);
	#		end
	#		board[row][collumn]=entry;
	#	end
	#end
	#board[0][1]=1;
	#p board;
	#p minConflicts(board);


	#	Function: mostHighlyConstrainedVariableWithLeastConstrainingValue
	#
	#	Determines the most highly constrained variable's least constraining value.
	#	This is evaluated by making calls to [degree] to determine the cell with the highest constraint or value.
	#	Then [leastConstrainingValue] is called for this cell to determine it's value with least constraint.
	#
	#	This function is assisted by [degree] and [leastConstrainingValue].
	#
	#	Input:
	#		board           : the board to evaluate
	#	Returns: The board fulfilling this heuristic.
	def mostHighlyConstrainedVariableWithLeastConstrainingValue(board)
		if board[0][0].is_a?(Array)
			mostConstrained={:degreeValue=>degree(board,0,0),:x=>0,:y=>0}#default first cell as most constrained
		else#already assigned a value
			mostConstrained={:degreeValue=>0,:x=>0,:y=>0}#default first cell as degree of 0 so anything else will be more constrained
		end
		for row in 0...board.length()
			for collumn in 0...board[0].length()
				if board[row][collumn].is_a?(Array) and board[row][collumn].length()>1
					evaluatedHeuristic=degree(board,row,collumn)
					if evaluatedHeuristic>mostConstrained[:degreeValue]#its more constrained
						mostConstrained[:degreeValue]=evaluatedHeuristic;
						mostConstrained[:x]=row;
						mostConstrained[:y]=collumn;
					end
				end
			end
		end
	
		#assigning best value to board
		newBoard=Array.new(board.length());
		for row in 0...board.length()
			newBoard[row]=Array.new(board[0].length());
			for collumn in 0...board[0].length()
				if board[row][collumn].is_a?(Array)
					newBoard[row][collumn]=board[row][collumn].dup();
				else
					newBoard[row][collumn]=board[row][collumn];
				end
			end
		end
	
		#newBoard=board.dup();
		newBoard[mostConstrained[:x]][mostConstrained[:y]]=leastConstrainingValue(board,mostConstrained[:x],mostConstrained[:y]);
		return newBoard;
	end

	#mostHighlyConstrainedVariableWithLeastConstrainingValue test code
	#board=Array.new(3);
	#for row in 0..3
	#	board[row]=Array.new(3)
	#	for collumn in 0..3
	#		entry=Array.new(4);
	#		for entryVal in 1..4
	#			entry[entryVal-1]=(entryVal);
	#		end
	#		board[row][collumn]=entry;
	#	end
	#end
	#board[0][1]=1;
	#p board;
	#p mostHighlyConstrainedVariableWithLeastConstrainingValue(board);


	#	Function: localSearch
	#
	#	Performs local search using given {board} and {heuristic}.
	#	Iterativly calls the given  board generating heuristic, updates the queue with the results, culls queue's bad boards and looks for a result.
	#
	#	This function is assisted by [cullBadBoards] , [{heuristic}] , and [enqueueBoard].
	#
	#	Input:
	#		board           : the board to evaluate, xblk and yblk values
	#		heuristic       : the heuristic to use when searching
	#	Returns: Search generated solved board.
	def localSearch(board,heuristic, xblks, yblks)
		solutionFound=false;
		queue=Array.new(1,board);
		checkBoard=Array.new()

		for row in 0...queue[0].length()
			checkBoard[row]=Array.new();
			for collumn in 0...queue[0][0].length()
				if queue[0][row][collumn].is_a?(Array)#if it hasn't been assigned a value
					checkBoard[row][collumn]=0;#don't assign to keep track of changes
				else
					checkBoard[row][collumn]=queue[0][row][collumn];
				end
			end
		end
	
	 	#create_node_consistent_board[1] represents the openlist
		if (create_node_consistent_board(checkBoard,xblks,yblks)[1].empty?)
			solutionFound=true;
		else
			queue=Array.new(1,create_node_consistent_board(checkBoard,xblks,yblks)[0])
	
		end
	
		while !solutionFound

			if heuristic=~/mostHighlyConstrainedVariableWithLeastConstrainingValue/
				newBoard=mostHighlyConstrainedVariableWithLeastConstrainingValue(queue[0]);
			end

			if heuristic=~/minConflicts/
				newBoard=minConflicts(queue[0]);
			end

			queue=enqueueBoard(newBoard,queue);
			queue=cullBadBoards(queue, xblks, yblks);
		
			if queue.include?(newBoard)#if its a valid board re-add it now that the last board's possibilities have been updated
				#remove possible entries for create_node_consistent_board's re-evaluation
				for row in 0...newBoard.length()
					for collumn in 0...newBoard[0].length()
						if newBoard[row][collumn].is_a?(Array)#if it hasn't been assigned a value
							newBoard[row][collumn]=0;#do not assign right now to keep track of changes			
						else
							newBoard[row][collumn]=newBoard[row][collumn];
						end
					end
				end

				#generate new board
				myboardHash=create_node_consistent_board(newBoard,xblks.floor,yblks);
			
				if myboardHash!=false
					for row in 0...myboardHash[0].length()
						for collumn in 0...myboardHash[0][0].length()

							if myboardHash[0][row][collumn].is_a?(Array) and queue[1][row][collumn].is_a?(Array) and 
							   myboardHash[0][row][collumn].length()>queue[1][row][collumn].length()

								myboardHash[0][row][collumn]=queue[1][row][collumn].dup();
							end
						end
					end
					updatedQueue=Array.new(1,myboardHash[0]);
					queue=updatedQueue.concat(popBoard(queue));#pull off the copy used to modify the old board's possibilities
				end
			
				p "queue length"
				p queue.length();
				print_board(queue[0]);
			end

			#remove possible entries for create_node_consistent_board's re-evaluation
			checkBoard=Array.new()
			for row in 0...queue[0].length()
				checkBoard[row]=Array.new();
				for collumn in 0...queue[0][0].length()
					if queue[0][row][collumn].is_a?(Array)#if it hasn't been assigned a value
						checkBoard[row][collumn]=0;
					else
					
						checkBoard[row][collumn]=queue[0][row][collumn];
					end
				end
			end
		
			boardHash=create_node_consistent_board(checkBoard,xblks,yblks)
			if (boardHash!=false and boardHash[1].empty?)
				solutionFound=true;
			
			elsif boardHash==false 
			
				queue=popBoard(queue);
				p queue[0];
			
			
				same=true;
				while same && queue.length>0
				
				
					if queue[0]==checkBoard
			
						queue=popBoard(queue);
					else
						same=false;
					end
				end
				if queue.length==0
					puts "No Solution"
					exit(0);
				end
			
			end
		
		end
		return checkBoard;
	
	end

	#localSearch test code
	#board=Array.new(3);
	#for row in 0..3
	#	board[row]=Array.new(3)
	#	for collumn in 0..3
	#		board[row][collumn]=0;
	#	end
	#end
	#board[0][1]=1;
	#board[0][2]=2;
	#board[1][0]=3;
	#board[1][1]=2;
	#board[1][2]=1;
	#board[2][2]=3;
	#board[2][3]=1;
	#board[3][0]=1;
	#board[3][1]=3;
	#p "Initial Board";
	#print_board(board);
	#p "Solution";
	#print_board(localSearch(create_node_consistent_board(board,Math.sqrt(board.length).floor,Math.sqrt(board[0].length).floor)[0],'minConflicts'));##mostHighlyConstrainedVariableWithLeastConstrainingValue

	#sample boards for now until we can generate from rails app:
	def example

	#board = [ [9,0,0,4,0,0,6,0,0], [0,0,7,0,0,0,0,0,3], [0,0,0,1,2,0,0,0,0], [1,2,0,0,4,3,0,5,0],
	#   [7,0,0,0,0,0,0,0,4], [0,4,0,7,6,0,0,8,9], [0,0,0,0,7,1,0,0,0], [6,0,0,0,0,0,9,0,0], [0,0,4,0,0,8,0,0,2]];


	# GLOBAL section for now,  this is where rails app will take over:

	#board = [[1,9,0,0,6,0,7,0,8], [0,0,0,0,0,7,0,0,5], [7,0,0,2,3,0,0,0,0], [0,1,0,0,0,0,5,0,0], [3,0,6,0,0,0,4,0,9], [0,0,9,0,0,0,0,7,0],
	#          [0,0,0,0,1,5,0,0,3], [5,0,0,9,0,0,0,0,0], [9,0,3,0,7,0,0,5,2]]



board =  [[1,0,0,0,0,2], [5,0,1,2,0,4], [3,2,0,0,1,5], [0,5,0,1,2,6], [2,0,0,5,0,1], [0,1,0,0,5,3]]

#board = [[4,0,2,1,6,5], [6,5,0,4,0,0], [0,1,5,6,4,3], [3,6,1,2,5,4], [0,2,4,0,1,6], [1,4,6,5,3,0]]

xblks = 3
yblks = 2

print_board (localSearch(create_node_consistent_board(board,xblks,yblks)[0],'minConflicts', xblks, yblks));
end

end

