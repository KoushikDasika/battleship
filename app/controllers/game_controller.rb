class GameController < ApplicationController

  #the main game page
  def index
    @game = Game.new
    @game.save

    respond_to do |format|
      format.html
    end
  end

  #called by remote form in index. shoots the desired grid square.
  def shoot
    @game = Game.find(params[:game_id])
    @player_message = @game.shoot(params[:coord]) #player shoots
    #if the game isn't over and the player didn't do a repeat, the cpu shoots
    if not (@player_message =~ /over/) and not (@player_message =~ /already/)
      @cpu_message = @game.shoot
    end
    @game.save

    respond_to do |format|
      format.js
    end
  end

end
