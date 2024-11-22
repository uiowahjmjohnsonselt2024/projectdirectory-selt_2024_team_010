require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user) { User.create!(username: 'testuser', email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
  let(:session_token) { SecureRandom.urlsafe_base64 }

  before do
    user.create_session!(session_token: session_token)
  end

  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid credentials' do
      it 'authenticates the user' do
        post :create, { :username => user.username, :password => 'password123' }
        user.reload
        expect(session[:session_token]).to eq(user.session.session_token)
      end

      it 'redirects to the dashboard' do
        post :create, { :username => user.username, :password => 'password123' }
        expect(response).to redirect_to(dashboard_path)
      end

      it 'sets a flash notice' do
        post :create, { :username => user.username, :password => 'password123' }
        expect(flash[:notice]).to eq("Logged in successfully")
      end
    end

    context 'with invalid credentials' do
      it 'does not authenticate the user' do
        post :create, { :username => user.username, :password => 'wrongpassword' }
        expect(session[:session_token]).to be_nil
      end

      it 're-renders the new template' do
        post :create, { :username => user.username, :password => 'wrongpassword' }
        expect(response).to render_template(:new)
      end

      it 'sets a flash alert' do
        post :create, { :username => user.username, :password => 'wrongpassword' }
        expect(flash.now[:alert]).to eq("Invalid username or password")
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      session[:session_token] = session_token
    end

    it 'destroys the session token' do
      delete :destroy
      expect(session[:session_token]).to be_nil
    end

    it 'removes the current user’s session' do
      delete :destroy
      expect(Session.find_by(id: user.session.id)).to be_nil
    end

    it 'sets a flash notice' do
      delete :destroy
      expect(flash[:notice]).to eq("Logged out successfully")
    end

    it 'redirects to the welcome page' do
      delete :destroy
      expect(response).to redirect_to(welcome_path)
    end
  end
end
