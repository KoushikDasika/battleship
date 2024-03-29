class GameController < ApplicationController

  #the main game page
  def index
    @game = Game.new
    @game.save

    respond_to do |format|
      format.html
    end
  end

  #called by ajax post when a grid square is clicked
  def shoot
    @game = Game.find(params[:game_id])
    @pMes, @pLoc = @game.shoot(params[:coord]) #player shoots
    #if the game isn't over and the player didn't do a repeat, the cpu shoots
    if not (@pMes =~ /over/) and not (@pMes =~ /already/)
      @cMes, @cLoc = @game.shoot
    end
    @game.save

    respond_to do |format|
      format.js
    end
  end

end
