# frozen_string_literal: true

class CharactersController < ApplicationController
  before_action :require_login, :get_current_game

  def get_characters
    begin
      @characters = @current_game.characters
                                 .select("characters.id, characters.x_position, characters.y_position, users.username, users.recent_character")
                                 .joins(:user)
                                 .where("characters.id = users.recent_character")

      render json: { characters: @characters }
      return
    rescue Exception => error
      puts "===================="
      puts error
      puts "==================="
      render json: { characters: [] }
    end

  end

  def move_character
    x = params[:x]
    y = params[:y]
    @current_character.update!(x_position: x, y_position: y)
    head :no_content
  end

  def items
    character = @current_user.characters.find_by(game_id: @current_game.id)
    @items = character.items
    render json: { items: @items.as_json(only: [:id, :name, :item_type, :description, :level]) }
  end
end
