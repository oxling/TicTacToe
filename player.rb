require './board.rb'


class Player
	@@learn_adj=0.1
	
	attr_accessor :symbol
		
	def initialize(symbol)
		@symbol = symbol
		@w1 = Random.rand(-5..5)
		@w2 = Random.rand(-5..5)
		@w3 = Random.rand(-5..5)
		@w4 = Random.rand(-5..5)
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

	def choose_move(board, opponent)
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
		
		best_move
		
	end

	def did_win?(board)
		if board.did_player_win?(@symbol)
			return true
		else
			return false
		end
	end
	
	def learn(game, verbose)
	
		if verbose
			puts "Player #{@symbol} learning:"
		end
		
		opponent = game.opponent(self)
		
		board = Board.new(game.board.size)
		next_board = game.board_at_turn(1)
		
		game.history.each { |move|
			turn = game.history.index(move)
			player = game.player_for_turn(turn)
			
			board.play(move[0], move[1], player.symbol)

			if (turn < game.history.length-1)
				next_move = game.history[turn+1]
				next_player = game.player_for_turn(turn+1)
				next_board.play(next_move[0], next_move[1], next_player.symbol)
				
				if verbose
					adjust_weights_verbose(opponent, board, next_board)
				else
					adjust_weights(opponent, board, next_board)
				end
				
			end
		}	
		
		if verbose
			puts "\n"
		end
		
	end
	
	def adjust_weights(opponent, board, next_board)
		board_val = calculate_board_value(board, opponent)
		next_board_val = calculate_board_value(next_board, opponent)

		adj = @@learn_adj*(next_board_val-board_val)	
			
		@w1 = @w1+(adj*x1(board))
		@w2 = @w2+(adj*x2(board, opponent))
		@w3 = @w3+(adj*x3(board))
		@w4 = @w4+(adj*x4(board, opponent))
		
		next_board_val
	end
	
	def adjust_weights_verbose(opponent, board, next_board)
		next_board_val = adjust_weights(opponent, board, next_board)
				
		puts "Training value for board = #{next_board_val}"
		board.print_board
		puts "\n"
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