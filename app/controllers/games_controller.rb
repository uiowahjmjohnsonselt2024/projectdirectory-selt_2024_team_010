# frozen_string_literal: true
class GamesController < ApplicationController
  before_action :require_login, :get_games_list, :get_current_game
  def index
    @games = @current_user.games
  end

  def new

  end

  def create
    new_game = @current_user.games.create(name: params[:server_name], owner_id: @current_user.id)
    if new_game.save
      flash[:notice] = 'Game successfully created'
      @current_user.characters.create(game_id: params[:id])

      colors = ['gray', 'green', 'yellow', 'blue']
      (-3..3).each do |y|
        (-3..3).each do |x|
          Tile.create(game_id: new_game.id, x_position: x, y_position: y, biome: colors.sample)
        end
      end

      redirect_to games_path
    else
      if new_game.errors.include?(:name)
        flash[:alert] = 'Name already used'
      else
        flash[:alert] = 'Server creation failed'
      end
      redirect_to new_game_path
      # This will be conditional based on why a game couldn't be created, could be because the title was already used,
      # or could be because they hit a limit on how many games they can have at once, etc.
    end
  end

  def list
    if params[:server_name]
      @search = params[:server_name]
      games = Game.arel_table
      @found_games = Game.where(games[:name].matches("%#{@search}%"))
    end
  end

  def add
    new_character = @current_user.characters.create(game_id: params[:id])
    if new_character.errors.include?(:user_id)
      flash[:notice] = 'Already added game'
    end
    redirect_to games_path
  end

  def show
    game = Game.find(params[:id])
    @current_user.update!(recent_character: @current_user.characters.find_by(game_id: game.id).id)
    get_current_game

    @tiles = {}
    @current_game.tiles.each do |tile|
      @tiles[[tile.x_position, tile.y_position]] = tile.biome
    end
  end

  def move_character
    x = params[:x]
    y = params[:y]
    @current_character.update!(x_position: x, y_position: y)
  end
end