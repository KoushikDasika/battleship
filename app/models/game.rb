class Game < ActiveRecord::Base

  before_create :set_vars

  #takes a shot at the grid square specified by coord. if no coordinates are
  #given, the cpu shoots at the player. returns a message and the shot location.
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

    return [output, location]
  end

  private

  #set ship hitpoints and initial board layout
  def set_vars
    self.cpu_ships = '23345'
    self.player_ships = '23345'
    self.cpu_board = generate_board
    self.player_board = generate_board
  end

  #the cpu's shooting strategy. right now the cpu checks all spaces sequentially.
  def cpu_shot
    player_board.scan(/./).each_with_index do |symbol, i|
      return i if symbol != 'M' and symbol != 'H'
    end
  end

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

  #automatically places ships. each ship is placed by selecting a random
  #grid square and then using that square as a pivot point. All possible
  #orientations are tried, and if one is found that doesn't conflict with
  #another ship, the ship is placed. Otherwise, a new pivot is tried.
  def generate_board
    board = 'O' * 100
    ship_hash = {0 => 2, 1 => 3, 2 => 3, 3 => 4, 4 => 5} #ship sybol => size
    ship_hash.each do |symbol, size|
      while true
        #find a free pivot point
        pivot = rand(100)
        while board[pivot] != 'O'
          pivot = rand(100)
        end
        #figure out possible ship orientations based on the start point
        directions = [-1, 1, -10, 10] #left, right, up, down
        #can it go left?
        directions.delete(-1) if (pivot-size-1)/10 < pivot/10 or (pivot-size-1) < 0
        #right?
        directions.delete(1) if (pivot+size-1)/10 > pivot/10
        #up?
        directions.delete(-10) if (pivot-10*(size-1)) < 0
        #down?
        directions.delete(10) if (pivot+10*(size-1)) > 99

        while not directions.empty? #try all possible orientations
          direction = directions[rand(directions.size-1)]
          ship = (0..size-1).collect{ |i| pivot+i*direction }
          if conflict(ship, board)
            directions.delete(direction)
          else
            break #no conflict, so place the ship
          end
        end

        if directions.empty?
          next #no possible orientations, so try again
        else
          #place the ships symbols on the board
          ship.each{ |loc| board[loc] = symbol.to_s }
          break
        end
      end
    end
    return board
  end

  #returns true if the proposed ship location conflicts with another ship
  def conflict(ship, board)
    if ship.empty?
      return true
    end
    ship.each do |loc|
      return true if board[loc] =~ /\d/
    end
    return false
  end

end
