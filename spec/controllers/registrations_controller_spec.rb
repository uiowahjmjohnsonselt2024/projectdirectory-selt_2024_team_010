require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  describe 'GET #new' do
    it 'assigns a new user to @user' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new user' do
        expect {
          post :create, { user: {
            username: 'testuser',
            email: 'test@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }}
        }.to change(User, :count).by(1)
      end

      it 'creates a session token for the user' do
        post :create, { user: {
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        }}
        user = User.find_by(email: 'test@example.com')
        expect(session[:session_token]).to eq(user.session.session_token)
      end

      it 'redirects to the dashboard path' do
        post :create, { user: {
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        }}
        expect(response).to redirect_to(dashboard_path)
      end

      it 'sets a flash notice' do
        post :create, { user: {
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        }}
        expect(flash[:notice]).to eq("Registration successful")
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new user' do
        expect {
          post :create, { user: {
            username: '',
            email: 'invalid-email',
            password: 'short',
            password_confirmation: 'mismatch'
          }}
        }.not_to change(User, :count)
      end

      it 're-renders the new template' do
        post :create, { user: {
          username: '',
          email: 'invalid-email',
          password: 'short',
          password_confirmation: 'mismatch'
        }}
        expect(response).to render_template(:new)
      end

      it 'sets a flash alert' do
        post :create, { user: {
          username: '',
          email: 'invalid-email',
          password: 'short',
          password_confirmation: 'mismatch'
        }}
        expect(flash.now[:alert]).to eq("Error creating account")
      end
    end
  end
end
