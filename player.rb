require './board.rb'

class Player

	attr_accessor :symbol, :opponent
	@@calc_count=0
	
	#Each calculation has a function (x1, x2, etc) and an associated weight (w1, w2, etc)
	def self.add_calculation(&block)
		define_method("x"+@@calc_count.to_s, &block)
		attr_accessor ("w"+@@calc_count.to_s).to_sym
		@@calc_count+=1
	end

	add_calculation { |board|
			board.total_adjacent(@symbol)
	}
	
	add_calculation { |board|
		board.total_adjacent(@opponent.symbol)
	}
	
	add_calculation { |board|
		board.potential_winning_squares(@symbol)
	}

	add_calculation { |board|
		board.potential_winning_squares(@opponent.symbol)
	}
			
	def initialize(symbol)
		@symbol = symbol
		each_w { |sym|
			instance_variable_set(sym, Random.rand(-1..1))
		}
	end

	def calculate_board_value(board)
		status = board.game_status(self, @opponent)
		
		if status == :win
			return 100
		elsif status == :lose
			return -100
		elsif status == :draw
			return 0
		else
			board_val = 0
			each_w_and_x {	|w, x|
				weight = instance_variable_get(w)
				val = send x, board
				
				board_val += weight*val
			}
			board_val
		end
	end

	def choose_move(board)
		moves = Board.valid_next_moves(board)
		
		best_move = moves.sample
		best_val = 0
		
		moves.each { |move|
			board.play(move[0], move[1], @symbol)
			val = calculate_board_value(board)
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
					adjust_weights_verbose(board, next_board)
				else
					adjust_weights(board, next_board)
				end
				
			end
		}	
		
		if verbose
			puts "\n"
		end
		
	end
		
	def print_weights
		print "["
		each_w { |w|
			print " #{instance_variable_get(w)};"
		}
		print " ]\n"
	end

	protected
	
	def adjust_weights(board, next_board)
		board_val = calculate_board_value(board)
		next_board_val = calculate_board_value(next_board)

		adj = 0.01*(next_board_val-board_val)
		
		each_w_and_x { |w, x|
			val = send x, board
			new_weight = instance_variable_get(w)+(adj*val)
			instance_variable_set(w, new_weight)
		}	
					
		next_board_val
	end
	
	def adjust_weights_verbose(board, next_board)
		next_board_val = adjust_weights(board, next_board)
				
		puts "Training value for board = #{next_board_val}"
		board.print_board
		puts "\n"
	end
	
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
			yield x
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