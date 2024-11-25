# frozen_string_literal: true
class GamesController < ApplicationController
  before_action :require_login, :get_games_list
  def index
    @games = @current_user.games
  end

  def new

  end

  def create
    puts @current_user.inspect
    new_game = @current_user.games.create(name: params[:server_name], owner_id: @current_user.id)
    if new_game.save
      flash[:message] = 'Game successfully created'
      redirect_to servers_path #Return with a redirect so that the URL doesn't read 'create'.
    else
      flash[:alert] = 'Invalid parameters'
      render :new
      # This will be conditional based on why a game couldn't be created, could be because the title was already used,
      # or could be because they hit a limit on how many games they can have at once, etc.
    end
  end
end