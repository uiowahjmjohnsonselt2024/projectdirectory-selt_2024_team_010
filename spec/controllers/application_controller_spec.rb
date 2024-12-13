require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let(:user) do
    User.create!(
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end
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
      session[:session_token] = nil
      controller.send(:create_session_token, user)
      expect(session[:session_token]).to eq(user.session.session_token)
      expect(user.session.session_token).not_to be_nil
    end
  end

  describe '#is_admin?' do
    let(:admin_user) do
      User.create!(
        username: 'adminuser',
        email: 'admin@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        isAdmin: true
      )
    end

    let(:non_admin_user) do
      User.create!(
        username: 'regularuser',
        email: 'regular@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        isAdmin: false
      )
    end

    context 'when current_user is an admin' do
      it 'returns true' do
        session[:session_token] = SecureRandom.urlsafe_base64
        admin_user.create_session!(session_token: session[:session_token])
        expect(controller.is_admin?).to be true
      end
    end

    context 'when current_user is not an admin' do
      it 'returns false' do
        session[:session_token] = SecureRandom.urlsafe_base64
        non_admin_user.create_session!(session_token: session[:session_token])
        expect(controller.is_admin?).to be false
      end
    end

    context 'when there is no current_user' do
      it 'returns nil' do
        session[:session_token] = nil
        expect(controller.is_admin?).to be_nil
      end
    end
  end

  describe '#require_admin' do
    controller do
      before_action :require_admin

      def admin_action
        render plain: "Admin access granted"
      end
    end

    let(:admin_user) do
      User.create!(
        username: 'adminuser',
        email: 'admin@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        isAdmin: true
      )
    end

    let(:non_admin_user) do
      User.create!(
        username: 'regularuser',
        email: 'regular@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        isAdmin: false
      )
    end

    before do
      routes.draw { get 'admin_action' => 'anonymous#admin_action' }
    end

    context 'when the user is an admin' do
      it 'allows access' do
        session[:session_token] = SecureRandom.urlsafe_base64
        admin_user.create_session!(session_token: session[:session_token])
        get :admin_action
        expect(response.body).to eq("Admin access granted")
      end
    end

    context 'when the user is not an admin' do
      it 'redirects with an alert' do
        session[:session_token] = SecureRandom.urlsafe_base64
        non_admin_user.create_session!(session_token: session[:session_token])
        get :admin_action
        expect(response).to redirect_to(dashboard_path)
        expect(flash[:alert]).to eq("You must be an admin to access this section")
      end
    end

    context 'when no user is logged in' do
      it 'redirects with an alert' do
        session[:session_token] = nil
        get :admin_action
        expect(response).to redirect_to(dashboard_path)
        expect(flash[:alert]).to eq("You must be an admin to access this section")
      end
    end
  end

  describe '#get_games_list' do
    controller do
      before_action :require_login
      before_action :get_games_list

      def games_action
        render plain: @games.map(&:name).join(", ")
      end
    end

    let(:game_user) do
      User.create!(
        username: 'gameuser',
        email: 'game@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )
    end

    let!(:game1) { Game.create!(name: 'Game 1', owner_id: game_user.id, max_user_count: 10) }
    let!(:game2) { Game.create!(name: 'Game 2', owner_id: game_user.id, max_user_count: 5) }

    before do
      session[:session_token] = SecureRandom.urlsafe_base64
      game_user.create_session!(session_token: session[:session_token])
      routes.draw { get 'games_action' => 'anonymous#games_action' }
    end
  end
end
