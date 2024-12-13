require 'rails_helper'

RSpec.describe ShopController, type: :controller do
  let(:user) { User.create(username: 'testuser', email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
  let(:session_token) { SecureRandom.urlsafe_base64 }

  before do
    user.create_session!(session_token: session_token)
    session[:session_token] = session_token # Simulate a logged-in user
  end

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end
end