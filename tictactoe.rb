require './player.rb'
require './board.rb'
require './game.rb'

require 'rubygems'
require 'ruby-debug'

def run_games(games, verbose)
	puts "Running #{games} games"

	p1 = Player.new(:X)
	p2 = Player.new(:O)
	
	g = Game.new(3, p1, p2)
	
	p1_win_count = 0
	p2_win_count = 0
	draw_count = 0
	
	games.times { |i|
		g.play
		if verbose == true
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
		
		p1.learn(g)
		p2.learn(g)
		
		if verbose == false
			print "\r#{i+1}/#{games} complete. "
			print "#{p1_win_count} wins, #{p2_win_count} losses, #{draw_count} draws"
		end
	
		g.player_one = g.player_one == p1 ? p2 : p1
		g.player_two = g.player_two == p2 ? p1 : p2
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

verbose = false
num_games = 0
ARGV.each do |arg|
	if arg.to_i == 0
		if (arg == "-v" or arg == "-verbose")
			verbose = true
		else
			puts "\"#{arg}\" is not valid input"
			Process.exit
		end
	else
		num_games = arg.to_i
	end
end

run_games(num_games, verbose)