class ItemsController < ApplicationController

  def index
    character = current_user.characters.first
    @items = character.items



    respond_to do |format|
      format.html
      format.json { render json: @items }
    end
  end
end
