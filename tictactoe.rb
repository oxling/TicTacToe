require './player.rb'
require './board.rb'
require './game.rb'

require 'rubygems'
require 'ruby-debug'

def run_games(games, game_verbose, learn_verbose)
	puts "Running #{games} games"

	p1 = Player.new(:X)
	p2 = Player.new(:O)
	
	g = Game.new(3)
	
	p1_win_count = 0
	p2_win_count = 0
	draw_count = 0
	
	first_player = p1
	second_player = p2
	
	games.times { |i|
		
		g.play(first_player, second_player)
		
		if game_verbose == true
			puts "----------"
			puts "Game #{i+1}:"
			puts "----------"
			g.print_game
		end

			
		if g.winner == p1
			p1_win_count+=1
		elsif g.winner == p2
			p2_win_count+=1
		else
			draw_count+=1
		end
		
		Player.learn(g, learn_verbose)
		#p1.learn(g, learn_verbose)
		#p2.learn(g, learn_verbose)
		
		if game_verbose == false and learn_verbose == false
			print "\r#{i+1}/#{games} complete. "
			print "#{p1_win_count} wins, #{p2_win_count} losses, #{draw_count} draws"
		end
	
		first_player = first_player == p1 ? p2 : p1
		second_player = second_player == p2 ? p1 : p2
	}
	
	print "\n\n"
	puts "#{p1.symbol} won #{p1_win_count} games"
	puts "#{p2.symbol} won #{p2_win_count} games"
	puts "Draws: #{games-p1_win_count-p2_win_count}"
	print "#{p1.symbol} weights: "
	p1.print_weights
	print "#{p2.symbol} weights: "
	p2.print_weights
	puts "\n"
end

# Main method
game_verbose = false
learn_verbose = false
num_games = 0

if ARGV.length == 0
	puts "Usage:"
	puts "tictactoe [-options] <number_of_games>"
	puts "Options:"
	puts "	-v or -verbose: Print all games and learning information."
	puts "	-g or -game: Print all games"
	puts "	-l or -learn: Print all learning information"
	
	Process.exit
end

ARGV.each do |arg|
	
	if arg.to_i == 0
		
		if (arg == "-v" or arg == "-verbose")
			game_verbose = true
			learn_verbose = true
		elsif (arg == "-g" or arg == "-game")
			game_verbose = true
		elsif (arg == "-l" or arg == "-learn")
			learn_verbose = true
		else
			puts "\"#{arg}\" is not valid input"
			Process.exit
		end
		
	else
		num_games = arg.to_i
	end
	
end

run_games(num_games, game_verbose, learn_verbose)