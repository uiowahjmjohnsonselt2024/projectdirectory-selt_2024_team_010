class ChatController < ApplicationController
  before_action :require_login, :get_current_game
  def create
    @current_game.chats.create!(user: @current_user.username, time_sent: Time.now.utc, message: params[:message])
    if @current_game.chats.count > 5
      @current_game.chats.order(time_sent: :asc).first.destroy # Only 6(?) messages should be kept around.
    end
    head :no_content
  end

  def list
    render json: {chatLog: @current_game.chats.all.order(time_sent: :asc)}
  end
end