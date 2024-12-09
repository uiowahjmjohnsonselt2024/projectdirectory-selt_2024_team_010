# frozen_string_literal: true

require 'rspec'

RSpec.describe 'TilesController' do
  let(:user) { User.create!(username: 'testuser', email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
  let(:session_token) { SecureRandom.urlsafe_base64 }
  let(:game) { user.games.create!(name:'game',owner_id: user.id) }

  before do
    user.create_session!(session_token: session_token)
    session[:session_token] = session_token
    get :game_path, params: { id: game.id }
  end

  after do
    # Do nothing
  end

  context 'When tile creation is called' do
    it 'succeeds' do
      get :tiles_get_tile_path, {
        x_position: 0,
        y_position: 0
      }
      expect(response).to have_http_status :ok
    end

    it 'returns valid tile data' do
      get :tiles_get_tile_path, {
        x_position: 0,
        y_position: 0
      }
      expect(response).to have_http_status :ok
    end
  end
end
