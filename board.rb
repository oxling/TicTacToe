class Board

	def initialize(new_size)
		@size = new_size
		@board = Array.new(@size) { Array.new(@size, nil) }
	end	
	
	def board
		@board
	end
	
	def board=(new_board)
		@board = new_board
	end
	
	def clone
		#Deep copy the board state
		clone = super
		clone.board = Array.new(clone.size) { |row|
			Array.new(clone.size) { |col|
				clone[col, row]
			}
		}
		clone
	end
						
	def clear_board
		@board.each do |row|
			row.each do |square|
				square = nil
			end
		end
	end
	
	def print_board
		rows.each do |row|
			row.each do |square|
				if square == nil
					print "-"
				else
					print square
				end
				print " "
			end
			print "\n"
		end
	end
	
	def play(col, row, player)
		@board[row][col] = player
	end
		
	def [] (col, row)
		@board[row][col]
	end
	
	def size
		@size
	end
	
	def rows
		return @board
	end
	
	def columns
		return @board.transpose
	end
	
	def diagonals
		d1 = Array.new(@size) { |i| @board[i][i] }
		d2 = Array.new(@size) { |i| @board[i][@size-1-i] }
		return [d1, d2]
	end
	
	def all_combinations
		return columns+rows+diagonals
	end
	
	def self.valid_next_moves(start_board)
		list = Array.new
			
			start_board.size.times { |row|
				start_board.size.times { |col|

					if start_board[col, row] == nil
						list.push([col, row])
					end
				}
			}
		list
	end
	
	def adjacent_squares(array, player)
		found = false
		adj = 0
		
		array.each do |square|
			if found and square == player
				adj+=1
			end
			found = (square == player)
		end
		
		adj	
	end
	
	def potential_win(array, player)
		square_count = array.count(player)
		if array.count(nil) == 1 and square_count == @size-1
			return true
		else
			return false
		end
	end
	
	#A row that is contested between two players
	def contested_row?(array, player, opponent)
		p_count = array.count(player)
		o_count = array.count(opponent)
		
		if p_count > 0 and o_count > 0
			return true
		else
			return false
		end
	end
	
	#A row that is only controlled by one player
	def potential_row?(array, player)
		p_count = array.count(player)
		nil_count = array.count(nil)
		
		if p_count > 0 and p_count+nil_count == @size
			return true
		else
			return false
		end
	end
	
	def total_adjacent(player)
		adj = 0
		(rows + columns + diagonals).each { |x|
			adj += adjacent_squares(x, player)
		}
		adj
	end
	
	def did_player_win?(player)
		win = false		
		(rows + columns + diagonals).each { |x|
			if adjacent_squares(x, player) == winning_size
				win = true
				break
			end
		}
		win
	end
	
	def potential_winning_squares(player)
		count = 0
		(rows + columns + diagonals).each { |x|
			if potential_win(x, player)
				count+=1
			end
		}
		count
	end
	
	def used_squares
		count = 0
		rows.each { |cols|
			cols.each { |square| 
				count+=1 unless square == nil
			}
		}
		count
	end
		
	def winning_size
		return @size - 1
	end
	
	def number_of_squares
		return @size * @size
	end
	
	def game_status(player, opponent)
		
		if did_player_win?(player.symbol) == true
			return :win
		elsif  did_player_win?(opponent.symbol) == true
			return :lose
		elsif used_squares == number_of_squares
			return :draw
		else
			return :in_progress
		end
		
	end


	protected :board
	protected :board=
	
	private :rows
	private :columns
	private :diagonals
		
end
