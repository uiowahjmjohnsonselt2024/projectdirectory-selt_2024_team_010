# frozen_string_literal: true
class GamesController < ApplicationController
  before_action :require_login
  def index
    @games = @current_user.characters
    @games << @current_user.games
  end

  def new

  end

  def create
    puts @current_user.inspect
    if @current_user.games.create(name: params[:title])
      flash[:message] = 'Game successfully created'
      render :index
      redirect_to servers_path
    else
      flash[:alert] = 'Invalid parameters'
      render :new
      # This will be conditional based on why a game couldn't be created, could be because the title was already used,
      # or could be because they hit a limit on how many games they can have at once, etc.
    end
  end
end