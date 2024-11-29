require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  # Create a test user and session for testing
  let(:user) { User.create!(username: 'testuser', email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
  let(:session_token) { SecureRandom.urlsafe_base64 }

  before do
    user.create_session!(session_token: session_token)
  end

  describe '#current_user' do
    context 'when session token is valid' do
      it 'returns the current user' do
        session[:session_token] = session_token
        expect(controller.current_user).to eq(user)
      end
    end

    context 'when session token is missing' do
      it 'returns nil' do
        session[:session_token] = nil
        expect(controller.current_user).to be_nil
      end
    end
  end

  describe '#logged_in?' do
    context 'when the user is logged in' do
      it 'returns true' do
        session[:session_token] = session_token
        expect(controller.logged_in?).to be true
      end
    end

    context 'when the user is not logged in' do
      it 'returns false' do
        session[:session_token] = nil
        expect(controller.logged_in?).to be false
      end
    end
  end

  describe '#require_login' do
    controller do
      before_action :require_login

      def test_action
        render plain: "Success"
      end
    end

    context 'when the user is logged in' do
      it 'allows access to the action' do
        session[:session_token] = session_token
        routes.draw { get 'test_action' => 'anonymous#test_action' }
        get :test_action
        expect(response.body).to eq("Success")
      end
    end

    context 'when the user is not logged in' do
      it 'redirects to the welcome path with an alert' do
        session[:session_token] = nil
        routes.draw { get 'test_action' => 'anonymous#test_action' }
        get :test_action
        expect(response).to redirect_to(welcome_path)
        expect(flash[:alert]).to eq("You must be logged in to access this section")
      end
    end
  end

  describe '#create_session_token' do
    it 'creates a session token and sets it in the session' do
      # Clear any existing session token in the controller's session
      session[:session_token] = nil

      # Call the method to create a new session token for the user
      controller.send(:create_session_token, user)

      # Verify that the session token was set correctly
      expect(session[:session_token]).to eq(user.session.session_token)
      expect(user.session.session_token).not_to be_nil
    end
  end
end