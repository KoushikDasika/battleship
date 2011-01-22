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
    elsif symbol == '+' #if the symbol is an open spot
      board[location] = 'M' #mark a miss
      output << 'Miss.'
    else
        output << 'You have already gone there.'
    end

    #check for remaining ships
    if (board =~ /\d/).nil?
        output << ' Game over!'
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
    '00111222++333344444+' + '+' * 80
  end

  #the cpu's shooting strategy
  def cpu_shot
    location = 0
    player_board.each_char do |c|
      if c != 'M' and c != 'H'
        break
      else
        location += 1
      end
    end
    puts location
    return location
  end

end
