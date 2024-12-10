class ChatController < ApplicationController
  before_action :require_login, :get_current_game
  def create
    @current_game.chats.create!(user: @current_user.username, time_sent: Time.now.utc, message: params[:message])
    head :no_content
  end

  def list
    render json: @current_game.chats
  end
end