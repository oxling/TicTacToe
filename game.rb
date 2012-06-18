class Game	
	
	attr_accessor :history, :player_one, :player_two, :winner, :board
	
	def initialize(size)
		@size = size
	end
	
	def opponent(current_player)
		current_player == @player_one ? @player_two : @player_one
	end
		
	def play(player_one, player_two)
		played = 0
		@board = Board.new(@size)
		@history = Array.new
		@winner = nil

		@player_one = player_one
		@player_two = player_two
		
		player = @player_one
		
		while played < @board.number_of_squares
			move = player.choose_move(@board)
			@board.play(move[0], move[1], player.symbol)
			@history.push(move)
			
			if player.did_win?(@board)
				@winner = player
				break
			end
			
			player = opponent(player)
			played+=1
		end
	end
	
	def print_game
		board = Board.new(@board.size)
		@history.each { |move|
			turn = @history.index(move)
			player = player_for_turn(turn)
			
			board.play(move[0], move[1], player.symbol)
			
			print "\n"
			puts "Turn #{turn}: move by #{player.symbol}"
			puts "Board with value #{player.calculate_board_value(board)} chosen"
			print "\n"
			
			board.print_board
		}
		
		print "\n"
		print_game_summary
		print "\n"
	end
	
	def print_game_summary
		puts "Player #{@player_one.symbol}: #{@board.game_status(@player_one, @player_two)}"
	end
	
	def player_for_turn(turn)
		if turn.even?
			@player_one
		else
			@player_two
		end
	end
	
	def board_at_turn(turn)
		board = Board.new(@board.size)
		
		i=0
		while i<=turn
			player = player_for_turn(i)
			move = @history[i]
			board.play(move[0], move[1], player.symbol)
			i+=1
		end
		board
	end
	
	def player_for_board(board)
		turn = @history.index(board)
		player_for_turn(turn)
	end
	
end
