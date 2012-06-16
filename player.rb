require './board.rb'

class Player

	attr_accessor :symbol
		
	def initialize(symbol)
		@symbol = symbol
		@w1 = 1
		@w2 = 1
		@w3 = 1
		@w4 = 1
	end

	def calculate_board_value(board, opponent)
		status = board.game_status(self, opponent)
		
		if status == :win
			return 100
		elsif status == :lose
			return -100
		elsif status == :draw
			return 0
		else		
			return @w1*x1(board)
						+@w2*x2(board, opponent)
						+@w3*x3(board)
						+@w4*x4(board, opponent)
		end
	end

	def make_move(board, opponent)
		moves = Board.valid_next_moves(board)
		
		best_move = moves.sample
		best_val = 0
		
		moves.each { |move|
			board.play(move[0], move[1], @symbol)
			val = calculate_board_value(board, opponent)
			board.play(move[0], move[1], nil)
			
			if val > best_val
				best_move = move
				best_val = val
			end
		}
		
		best_board=board.clone
		best_board.play(best_move[0], best_move[1], @symbol)
		best_board
		
	end

	def did_win?(board)
		if board.did_player_win?(@symbol)
			return true
		else
			return false
		end
	end
	
	def learn(game)
		opponent = game.opponent(self)
		game.history.reverse.each { |board|
			turn = game.history.index(board)
			#find the next turn
			if (turn > 0)
				next_board = game.history[turn]
				board = game.history[turn-1]
				adjust_weights(opponent, board, next_board)
			end
		}
	end
	
	def adjust_weights(opponent, board, next_board)
		board_val = calculate_board_value(board, opponent)
		next_board_val = calculate_board_value(next_board, opponent)

		adj = 0.001*(next_board_val-board_val)	
			
		@w1 = @w1+(adj*x1(board))
		@w2 = @w2+(adj*x2(board, opponent))
		@w3 = @w3+(adj*x3(board))
		@w4 = @w4+(adj*x4(board, opponent))
	end
	
	def adjust_weights_verbose(opponent, board, next_board)
		board_val = calculate_board_value(board, opponent)
		next_board_val = calculate_board_value(next_board, opponent)
				
		adj = 0.1*(next_board_val-board_val)	
			
		@w1 = @w1+(adj*x1(board))
		@w2 = @w2+(adj*x2(board, opponent))
		@w3 = @w3+(adj*x3(board))
		@w4 = @w4+(adj*x4(board, opponent))
		
		puts "Player #{@symbol} learning:"
		puts "Training value for board = #{next_board_val}"
		print "Adjusted function: "
		print "(%0.1f * #{x1(board)})" % @w1
		print "+(%0.1f * #{x2(board,opponent)})" % @w2
		print "+(%0.1f * #{x3(board)})" % @w3 
		print "+(%0.1f * #{x4(board, opponent)})\n" % @w4
		board.print_board
	end
	
	def print_weights
		puts "[#{@w1}, #{@w2}, #{@w3}, #{@w4}]"
	end
	
	private :adjust_weights
	
	private
	
	def x1(board)
		board.total_adjacent(@symbol)
	end
	
	def x2(board, opponent)
		board.total_adjacent(opponent.symbol)
	end
	
	def x3(board)
		board.potential_winning_squares(@symbol)
	end
	
	def x4(board, opponent)
		board.potential_winning_squares(opponent.symbol)
	end

		
end