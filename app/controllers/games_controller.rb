# frozen_string_literal: true
class GamesController < ApplicationController
  before_action :require_login, :get_games_list
  def index
    @games = @current_user.games
  end

  def new

  end

  def create
    new_game = @current_user.games.create(name: params[:server_name], owner_id: @current_user.id)
    if new_game.save
      flash[:message] = 'Game successfully created'
      @current_user.characters.create(game_id: params[:id])
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
      @found_games = Game.where(name: params[:server_name])
    end
  end

  def add
    new_character = @current_user.characters.create(game_id: params[:id])
    if new_character.errors.include?(:user_id)
      flash[:message] = 'Already added game'
    end
    redirect_to games_path
  end

  def show
    @game = Game.find(params[:id])
  end
end