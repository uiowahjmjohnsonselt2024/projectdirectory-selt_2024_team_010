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

  context 'Tile Creation' do
    it 'Succeeds on an empty tile' do
      post :get_tile_path, params: { x: 0, y: 0}
      expect(game.tiles.exists?(x: 0, y: 0)).to be_truthy
    end
  end
end
