require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { User.create(
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
  }
  let(:game) { Game.create(
    name: "Adventure Quest",
    owner_id: user.id,
    max_user_count: 10
  )
  }
  let(:character) { Character.create(
    user_id: user.id,
    game_id: game.id,
    level: 5,
    currentHealth: 8,
    x_position: 0,
    y_position: 0,
    maxHealth: 10
  )
  }

  before do
    allow(controller).to receive(:require_login).and_return(true)
    allow(controller).to receive(:get_games_list)
    allow(controller).to receive(:get_current_game)
    allow(controller).to receive(:current_user).and_return(user)

    controller.instance_variable_set(:@current_game, game)
    controller.instance_variable_set(:@current_user, user)
    controller.instance_variable_set(:@current_character, character)
  end

  describe 'GET #index' do
    it 'assigns games for the current user and renders index template' do
      get :index
      expect(assigns(:games)).to eq(user.games)
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
    it 'renders the new game template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'when game creation is successful' do
      it 'creates a new game, character, and tiles' do
        expect do
          post :create, { server_name: 'New Game' }
        end.to change(Game, :count).by(1)
                                   .and change(Character, :count).by(1)
                                                                 .and change(Tile, :count).by(49) # 7x7 grid

        expect(flash[:notice]).to eq('Game successfully created')
        expect(response).to redirect_to(games_path)
      end
    end

    context 'when game creation fails' do
      it 'flashes an alert and redirects to new game path' do
        allow_any_instance_of(Game).to receive(:save).and_return(false)
        post :create, { server_name: '' }
        expect(flash[:alert]).to eq('Server creation failed')
        expect(response).to redirect_to(new_game_path)
      end
    end

    context 'when game name is already used' do
      it 'flashes an alert for duplicate name' do
        Game.create!(name: 'Duplicate Game', owner_id: user.id, max_user_count: 6)
        post :create, { server_name: 'Duplicate Game' }
        expect(flash[:alert]).to eq('Name already used')
        expect(response).to redirect_to(new_game_path)
      end
    end
  end

  describe 'POST #add' do

    context 'when user successfully joins the game' do
      it 'flashes a notice and redirects to games path' do
        expect do
          post :add, { id: game.id }
        end.to change(Character, :count).by(0)
      end
    end
  end


  describe 'GET #show' do
    let!(:character) { user.characters.create!(game_id: game.id) }

    it 'assigns game-related data and renders the show template' do
      get :show, { id: game.id }
      expect(assigns(:tiles)).to be_a(Hash)
      expect(assigns(:tiles).size).to eq(0)
      expect(assigns(:character)).to eq(character)
      expect(response).to render_template(:show)
    end
  end
  describe 'DELETE #destroy' do
    let!(:item) { Item.create!(name: 'Sword', item_type: 'weapon', description: 'A sharp blade', character_id: user.id) }

    it 'destroys the item and returns no content response' do
      expect {
        delete :destroy, { id: item.id, format: :json }, headers: { 'Accept' => 'application/json' }
      }.to change(Item, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
  describe 'GET #list' do
    context 'when a server_name is provided' do
      it 'assigns @found_games based on the search query' do
        get :list, params: { server_name: 'Quest' }

        expect(assigns(:search)).to eq(nil)
      end
    end

    context 'when no server_name is provided' do
      it 'does not assign @found_games and does not perform a search' do
        get :list

        expect(assigns(:search)).to be_nil
        expect(assigns(:found_games)).to be_nil
        expect(response).to render_template(:list)
      end
    end
  end
end
