# frozen_string_literal: true
class GamesController < ApplicationController
  before_action :require_login, :get_games_list, :get_current_game

  def index
    @games = @current_user.games
  end

  def new
  end

  def create
    new_game = @current_user.games.create(name: params[:server_name], owner_id: @current_user.id, max_user_count: 6)
    if new_game.save
      flash[:notice] = 'Game successfully created'
      @current_user.characters.create(game_id: new_game.id)

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
    game = Game.find(params[:id])
    if game.characters.count >= game.max_user_count
      flash[:alert] = 'Game is full'
      redirect_to list_games_path
    else
      new_character = @current_user.characters.create(game_id: params[:id])
      if new_character.errors.include?(:user_id)
        flash[:alert] = 'Already added game'
        redirect_to list_games_path
      else
        flash[:notice] = 'Successfully added game'
        redirect_to games_path
      end
    end
  end

  def show
    game = Game.find(params[:id])
    # Update the user's recent_character to the character in this game
    @current_user.update!(recent_character: @current_user.characters.find_by(game_id: game.id).id)
    get_current_game

    # Fetch the current character in this game for the logged-in user
    @character = @current_user.characters.find_by(game_id: @current_game.id)
    # Fetch the character's items (assuming you have a has_many :items association on Character)
    @items = @character.items if @character

    @tiles = {}
    @current_game.tiles.each do |tile|
      @tiles[[tile.x_position, tile.y_position]] = tile.biome
    end

    # Fetch all characters in this game, if needed
    #@characters = @current_game.characters.all
  end


  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    respond_to do |format|
      format.json { head :no_content }
      format.html { redirect_to items_path, notice: 'Item was successfully deleted.' }
    end
  end
end