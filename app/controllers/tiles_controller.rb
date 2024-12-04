# frozen_string_literal: true
class TilesController < ApplicationController
  before_action :require_login, :get_current_game
  BIOMES = [:plains, :forest, :desert, :mountains, :ocean]
  def create
    x = params[:x]
    y = params[:y]
    # This is just a check to prevent overwriting a tile using CREATE. UPDATE should be used if that is needed.
    unless @current_game&.tiles&.where("x_position = ? AND y_position = ?",x,y) then return end
    # Replace biome selector with something fancier if we have the time.
    @current_game.tiles.create!(x_position: x, y_position: y, biome: BIOMES.sample)
  end
end
