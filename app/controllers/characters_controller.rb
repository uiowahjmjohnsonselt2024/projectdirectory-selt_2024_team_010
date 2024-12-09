# frozen_string_literal: true

class CharactersController < ApplicationController
  before_action :require_login, :get_current_game

  def get_characters
    @characters = @current_game.characters
                               .select("characters.id, characters.x_position, characters.y_position, users.username")
                               .joins(:user).all
    puts @characters.inspect
    render json: { characters: @characters }
  end

  def move_character
    x = params[:x]
    y = params[:y]
    @current_character.update!(x_position: x, y_position: y)
    head :no_content
  end
end
