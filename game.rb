class Game	
	
	attr_accessor :history, :player_one, :player_two, :winner
	
	def initialize(size, player_one, player_two)
		@player_one = player_one
		@player_two = player_two
		@size = size
	end
	
	def opponent(current_player)
		if current_player == @player_one
			return @player_two
		else
			return @player_one
		end
	end
		
	def play
		played = 0
		board = Board.new(@size)
		@history = Array.new
		@winner = nil

		player = @player_one
		
		while played < board.number_of_squares
			board = player.make_move(board, opponent(player))
			@history.push(board)
			
			if player.did_win?(board)
				@winner = player
				break
			end
			
			player = opponent(player)
			played+=1
		end
	end
	
	def print_game
		
		@history.each { |board|
			turn = @history.index(board)
			player = player_for_turn(turn)
			print "\n"
			puts "Turn #{turn}: move by #{player.symbol}"
			puts "Board with value #{player.calculate_board_value(board, opponent(player))} chosen"
			print "\n"
			board.print_board
		}
		
		print "\n"
		print_game_summary
		print "\n"
	end
	
	def print_game_summary
		last_play = @history.last
		puts "Player #{@player_one.symbol}: #{last_play.game_status(@player_one, @player_two)}"
	end
	
	def player_for_turn(turn)
		if turn.even?
			@player_one
		else
			@player_two
		end
	end
	
	def player_for_board(board)
		turn = @history.index(board)
		player_for_turn(turn)
	end
	
end
