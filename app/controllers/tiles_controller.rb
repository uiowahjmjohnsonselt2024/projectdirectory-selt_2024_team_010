# frozen_string_literal: true
class TilesController < ApplicationController
  before_action :require_login, :get_current_game
  BIOMES = [:white, :green, :yellow, :gray, :blue]
  def create
    x = params[:x]
    y = params[:y]
    # This is just a check to prevent overwriting a tile using CREATE. UPDATE should be used if that is needed.
    unless @current_game&.tiles&.where("x_position = ? AND y_position = ?",x,y) then return end
    # Replace biome selector with something fancier if we have the time.
    @current_game.tiles.create!(x_position: x, y_position: y, biome: BIOMES.sample)
  end

  def index
    @tiles = {}
    @current_game.tiles.each do |tile|
      @tiles.assoc([tile.x_position, tile.y_position] => [tile.biome])
    end


  end

  def show
    # TODO: prompt the AI for the details about the tile if details are not found here.
  end
end
