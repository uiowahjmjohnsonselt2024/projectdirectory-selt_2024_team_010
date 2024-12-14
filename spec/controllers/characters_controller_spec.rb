require 'rails_helper'

RSpec.describe CharactersController, type: :controller do
  let(:user) do
    User.create(
      username: "PlayerOne",
      email: "playerone@example.com",
      password_digest: BCrypt::Password.create("password123"),
      shard_amount: 50.0,
      money_usd: 100.0,
      created_at: Time.now,
      updated_at: Time.now,
      recent_character: 1,
      isAdmin: false,
      is_oauth: false
    )
  end
  let(:game) do
    Game.create(
      name: "Adventure Quest",
      owner_id: user.id,
      max_user_count: 10
    )
  end
  let(:character) do
    Character.create(
      user_id: user.id,
      game_id: game.id,
      level: 5,
      currentHealth: 8,
      x_position: 5,
      y_position: 10,
      maxHealth: 10
    )
  end
  let(:another_character) do
    Character.create(
      user_id: user.id,
      game_id: 2,
      level: 5,
      currentHealth: 8,
      x_position: 0,
      y_position: 0,
      maxHealth: 10
    )
  end

  before do
    allow(controller).to receive(:require_login).and_return(true)
    allow(controller).to receive(:get_current_game).and_return(game)
    controller.instance_variable_set(:@current_character, character)
    controller.instance_variable_set(:@current_game, game)
    controller.instance_variable_set(:@current_user, user)
  end

  describe 'GET #get_characters' do
    it 'returns the current game characters associated with the current user' do
      user.update(recent_character: character.id)
      another_user = # Create an example user
        User.create!(
          username: "ExampleUser",
          email: "exampleuser@example.com",
          password: "password123",
          password_confirmation: "password123",
          shard_amount: 50.0,
          money_usd: 100.0,
          recent_character: nil,
          isAdmin: false,
          password_reset_token: nil,
          password_reset_sent_at: nil,
          is_oauth: false
        )


      get :get_characters

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['characters']).to include(
                                                           include('id' => character.id, 'username' => user.username)
                                                         )
      expect(JSON.parse(response.body)['characters']).not_to include(
                                                               include('id' => another_character.id)
                                                             )
    end
  end

  describe 'POST #move_character' do
    it 'updates the character position' do
      post :move_character, params: { x: 5, y: 10 }

      expect(response).to have_http_status(:no_content)
      expect(character.reload.x_position).to eq(nil)
      expect(character.reload.y_position).to eq(nil)
    end
  end

  describe 'GET #items' do
    it 'returns items for the current user character in the game' do
      item = Item.create!(item_type: "artifact", name: "TestItem", description: "This is an item", level: 1, character_id: character.id )

      get :items

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['items']).to include(
                                                      include('id' => item.id, 'name' => item.name, 'item_type' => item.item_type)
                                                    )
    end

    it 'returns an empty list if the character has no items' do
      get :items

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['items']).to eq([])
    end
  end
end
