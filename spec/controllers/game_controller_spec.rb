require 'rails_helper'

RSpec.describe GameController, type: :controller do
  let(:user) { User.create!(username: 'testuser', email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
  let(:session_token) { SecureRandom.urlsafe_base64 }

  before do
    user.create_session!(session_token: session_token)
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
    end

    context 'when the user is not logged in' do
      before do
        session[:session_token] = nil
      end

      it 'redirects to the welcome page with an alert' do
        get :index
        expect(response).to redirect_to(welcome_path)
        expect(flash[:alert]).to eq("You must be logged in to access this section")
      end
    end
  end
end