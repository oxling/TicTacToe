require './player.rb'
require './board.rb'
require './game.rb'

require 'rubygems'
require 'ruby-debug'

games = 100

puts "Running #{games} games"

p1 = Player.new(:X)
p2 = Player.new(:O)

g = Game.new(3, p1, p2)

p1_win_count = 0
p2_win_count = 0

games.times { |i|
	g.play
	puts "----------------------------------"
	print "Game #{i+1}:\n"
	puts "----------------------------------"
	g.print_game
	
	if g.winner == p1
		p1_win_count+=1
	elsif g.winner == p2
		p2_win_count+=1
	end
	
	p1.learn(g)
	p2.learn(g)
	
}

puts "#{p1.symbol} wins: #{p1_win_count}"
puts "#{p2.symbol} wins: #{p2_win_count}"
print "#{p1.symbol} weights: "
p1.print_weights
print "#{p2.symbol} weights: "
p2.print_weights
