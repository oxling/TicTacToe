require './board.rb'

class Player

	attr_accessor :symbol, :opponent
	@@calc_count=0
	
	#Each calculation has a function (x0, x1, ...) and an associated weight (w0, w1, ...)
	def self.add_calculation(&block)
		define_method("x"+@@calc_count.to_s, &block)
		attr_accessor ("w"+@@calc_count.to_s).to_sym
		@@calc_count+=1
	end
	
	#Adding different types of board calculations to the player
	add_calculation { |board|
		val = board.check_all_sets { |arr|
			board.controlled_set?(arr, @opponent.symbol, @symbol)
		}
	}
	
	add_calculation { |board|
		board.check_all_sets { |arr|
			board.potential_winning_set?(arr, @opponent.symbol, @symbol)
		}
	}
	
	add_calculation { |board|
		board.total_adjacent_squares(@opponent.symbol)
	}
				
	def initialize(symbol)
		@symbol = symbol
		each_w { |sym|
			instance_variable_set(sym, Random.rand(-1..1))
		}
	end

	#The player will always play the board with the highest estimated value
	def calculate_board_value(board)
		status = board.game_status(self, @opponent)
		
		if status == :win
			return 100
		elsif status == :lose
			return -100
		elsif status == :draw
			return 0
		else
		
			#The valuation function takes the form
			# w0 * x0 + w1 * x1 ... wn * xn
			board_val = 0
			each_w_and_x {	|w, x|
				weight = instance_variable_get(w)
				val = send x, board
				
				board_val += weight*val
			}
			
			# Make sure the value of a non-winning/losing board is bounded correctly
			if board_val > 100
				99
			elsif board_val < -100
				-99
			else
				board_val
			end
			
		end
	end
	
	def value_for_move(board, move)
			board.play(move[0], move[1], @symbol)
			val = calculate_board_value(board)
			board.play(move[0], move[1], nil)
			
			val
	end

	def choose_move(board)
		moves = Board.valid_next_moves(board)
		
		best_move = moves.sample
		best_val = value_for_move(board, best_move)
		
		moves.each { |move|
			val = value_for_move(board, move)
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
	
	#Iteratively adjust the weights of the valuation function
	def self.learn(game, verbose)
				
		board = game.board_at_turn(game.history.length-2)
		next_board = game.board.clone
		
		game.history.reverse.each { |move|
			turn = game.history.index(move)
			player = game.player_for_turn(turn)
			
			if (turn > 0)
				if verbose
					player.adjust_weights_verbose(board, next_board)
					player.opponent.adjust_weights_verbose(board, next_board)
				else
					player.adjust_weights(board, next_board)
					player.opponent.adjust_weights(board, next_board)
				end
				previous_move = game.history[turn-1]
				board.play(previous_move[0], previous_move[1], nil)										
			end
			
			next_board.play(move[0], move[1], nil)
		}	
		
		if verbose
			puts "\n"
		end
		
	end
			
	def adjust_weights(board, next_board)
	
		#The weights are adjusted based on a "training" value for each board.
		#The training value is the value estimate for the following play.
	
		board_val = calculate_board_value(board)
		next_board_val = calculate_board_value(next_board)

		adj = 0.005*(next_board_val-board_val)
		
		each_w_and_x { |w, x|
			val = send x, board
			new_weight = instance_variable_get(w)+(adj*val)
			instance_variable_set(w, new_weight)
		}	
					
		next_board_val
	end
	
	
	def adjust_weights_verbose(board, next_board)
		next_board_val = adjust_weights(board, next_board)
		
		puts "Player #{@symbol} learning:"
		puts "Training value for board = #{next_board_val}"
		print_functions(board)
		
		board.print_board
		print "\n"
		next_board.print_board
		puts "\n"
	end
	
	def print_weights
		print "["
		each_w { |w|
			print " #{instance_variable_get(w)};"
		}
		print " ]\n"
	end
	
	def print_functions(board)
		print "["
		each_x { |x|
			val = send x, board
			print " #{x.to_s}=#{val};"
		}
		print " ]\n"
	end

	
	protected
	
	#Iterator (each weight)
	def each_w
		@@calc_count.times { |i|
			sym = ("@w"+i.to_s).to_sym
			yield sym
		}
	end
	
	#Iterator (each function)
	def each_x
		@@calc_count.times { |i|
			sym = ("x"+i.to_s).to_sym
			yield sym
		}
	end
	
	#Iterator (each weight and function)
	def each_w_and_x
		@@calc_count.times { |i|
			x_sym = ("x"+i.to_s).to_sym
			w_sym = ("@w"+i.to_s).to_sym
			
			yield w_sym, x_sym
		}
	end

			
end