class Game < ActiveRecord::Base

  before_create :set_vars

  #takes a shot at the grid square specified by coord. if no coordinates are
  #given, the cpu shoots at the player.
  def shoot(*coord)
    location = 0 #shot location
    ships = '' #ship hitpoints
    board = '' #board layout
    output = '' #message to be displayed to the player

    #fill the above variables with the opponents setup
    if not coord.empty? #player is shooting
      ships = cpu_ships.clone
      board = cpu_board.clone
      location = coord[0].to_i
    else #cpu is shooting
      ships = player_ships.clone
      board = player_board.clone
      location = cpu_shot
    end

    symbol = board[location] #symbol occupying the shooting spot
    if symbol =~ /[0-4]/ #if symbol is a ship
      board[location] = 'H' #mark a hit
      output << ship_hit(symbol.to_i, ships)
    elsif symbol == 'O' #if the symbol is an open spot
      board[location] = 'M' #mark a miss
      output << 'Miss.'
    else
        output << 'You have already gone there.'
    end

    #check for remaining ships
    if (board =~ /\d/).nil?
        output << ' Game over! Refresh to play again.'
    end

    #set the oponents board to its new state
    if not coord.empty?
      self.cpu_ships = ships
      self.cpu_board = board
    else
      self.player_ships = ships
      self.player_board = board
    end

    return output
  end

  private

  #runs if a ship is hit
  def ship_hit(number, ships)
    #hash of ship numbers => names
    ship_hash = {0 => 'Patrol boat', 1 => 'Submarine', 2 => 'Destroyer',
    3 => 'Battleship', 4 => 'Aircraft carrier'}
    #decrement ship's hitpoints
    ships[number.to_i] = (ships[number.to_i].to_i - 1).to_s
    #check if the hit sunk the ship
    outcome = ships[number] == '0' ? ' sunk!' : ' hit!'
    #return message
    return ship_hash[number] + outcome
  end

  #set ship hitpoints and initial board layout
  def set_vars
    self.cpu_ships = '23345'
    self.player_ships = '23345'
    self.cpu_board = generate_board
    self.player_board = generate_board
  end

  #automatically places ships
  def generate_board
#    board = 'O' * 100
#    ship_hash = {0 => 2, 1 => 3, 2 => 3, 3 => 4, 4 => 5} #ship sybol => size
#    directions = [10, -10, 1, -1] #possible ship orientations
#    ship_hash.each do |symbol, size|
#      while true
#        first = rand(100) #look for an opening at which to start
#        if board[first] != 'O'
#          next
#        end
#        spaces = [first] #keep track of the spaces the ship will occupy
#        direction = directions[rand(3)] #choose a random orientation
#        last = first + direction * (size-1) #end of the ship
#        #make sure the end is within the board
#        if last > 99 or last < 0 or board[last] != 'O'
#          next
#        elsif direction.abs == 1 and last/10 != first/10
#          next
#        elsif direction.abs == 10 and last%10 != first%10
#          next
#        end
#        #make sure the space between the start and is empty
#        (2..size).each do |spot|
#          if board[first+direction*(spot-1)] == 'O'
#            spaces << first+direction*(spot-1)
#          else
#            break
#          end
#        end
#        if spaces.size == size #all the space is free, so place the ship
#          spaces.each { |space| board[space] = symbol.to_s }
#          break
#        else #the space wasn't free, so try again
#          next
#        end
#      end
#    end
    board = '00111222OO333344444O' + 'O'*80
    return board
  end

  #the cpu's shooting strategy. right now the cpu checks all spaces sequentially.
  def cpu_shot
    player_board.scan(/./).each_with_index do |symbol, i|
      return i if symbol != 'M' and symbol != 'H'
    end
  end

end
