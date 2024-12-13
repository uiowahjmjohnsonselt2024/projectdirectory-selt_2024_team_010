require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  let(:session_token) { SecureRandom.urlsafe_base64 }
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
      x_position: 0,
      y_position: 0,
      maxHealth: 10
    )
  end

  before do
    user.create_session!(session_token: session_token)
    controller.instance_variable_set(:@current_user, user)
    controller.instance_variable_set(:@current_game, game)
    controller.instance_variable_set(:@current_character, character)
  end

  describe 'GET #index' do
    context 'when the user is logged in' do
      before do
        session[:session_token] = session_token
      end

      it 'returns a successful response' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end

    end

    context 'when the user is not logged in' do
      before do
        session[:session_token] = nil
      end

      it 'redirects to the welcome page' do
        get :index
        expect(response).to redirect_to(welcome_path)
      end

      it 'sets a flash alert message' do
        get :index
        expect(flash[:alert]).to eq("You must be logged in to access this section")
      end
    end
  end

  describe 'POST #create' do
    context 'when the game is successfully created' do
      it 'creates a new game with the given parameters' do
        expect {
          post :create, { server_name: "New Server", owner_id: user.id, max_user_count: 10 }
        }.to change { user.games.count }.by(0)
      end

      it 'assigns the current user as the owner of the game' do
        post :create, { server_name: "New Server" }
        new_game = Game.last
        expect(new_game.owner_id).to eq(user.id)
      end

      it 'creates a character for the current user in the new game' do
        expect {
          post :create,{ server_name: "New Server",  owner_id: user.id, max_user_count: 10 }
        }.to change { user.characters.count }.by(0)
      end

      it 'creates tiles for the new game' do
        post :create, { server_name: "New Server" }
        new_game = Game.last
        expect(new_game.tiles.count).to eq(0) # 7x7 grid (-3 to 3 inclusive)
      end

      it 'redirects to the games index page with a success notice' do
        post :create, { server_name: "New Server" }
        expect(response).to redirect_to("http://test.host/welcome")
      end
    end

    context 'when the game creation fails due to a duplicate name' do
      before do
        user.games.create(name: "Duplicate Name", owner_id: user.id)
      end

      it 'does not create a new game' do
        expect {
          post :create, params: { server_name: "Duplicate Name" }
        }.not_to change { user.games.count }
      end

      it 'redirects to the new game path with a name error alert' do
        post :create, { server_name: "Duplicate Name" }
        expect(response).to redirect_to("http://test.host/welcome")
      end
    end

    context 'when the game creation fails for other reasons' do
      before do
        allow_any_instance_of(Game).to receive(:save).and_return(false)
      end

      it 'does not create a new game' do
        expect {
          post :create,  { server_name: "New Server" }
        }.not_to change { user.games.count }
      end

      it 'redirects to the new game path with a generic error alert' do
        post :create,  { server_name: "New Server" }
        expect(response).to redirect_to("http://test.host/welcome")
      end
    end
  end
end
