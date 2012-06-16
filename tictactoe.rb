require './player.rb'
require './board.rb'
require './game.rb'

require 'rubygems'
require 'ruby-debug'

def run_games(games)
	puts "Running #{games} games"

	p1 = Player.new(:X)
	p2 = Player.new(:O)
	
	g = Game.new(3, p1, p2)
	
	p1_win_count = 0
	p2_win_count = 0
	draw_count = 0
	
	games.times { |i|
		g.play
			
		if g.winner == p1
			p1_win_count+=1
		elsif g.winner == p2
			p2_win_count+=1
		else
			draw_count+=1
		end
		
		p1.learn(g)
		p2.learn(g)
		
		print "\r#{i+1}/#{games} complete. "
		print "#{p1_win_count} wins, #{p2_win_count} losses, #{draw_count} draws"
	
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

ARGV.each do |games|
	
	if games.to_i == 0
		puts "\"#{games}\" is not a valid number of games"
		Process.exit
	end
	
	run_games(games.to_i)
end