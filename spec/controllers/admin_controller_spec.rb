require 'rails_helper'

RSpec.describe AdminController, type: :controller do
  let(:admin) { User.create!(username: 'admin', email: 'admin@example.com', password: 'password123', isAdmin: true) }
  let(:session_token) { SecureRandom.urlsafe_base64 }

  before do
    admin.create_session!(session_token: session_token)
    session[:session_token] = session_token
  end

  describe 'GET #index' do
    it 'renders the index page and assigns all users and games' do
      game = Game.create!(name: 'Test Game', owner_id: admin.id, max_user_count: 6)
      user = User.create!(username: 'testuser', email: 'test@example.com', password: 'password123')

      get :index, {}

      expect(response).to render_template(:index)
      expect(assigns(:users)).to include(user)
      expect(assigns(:games)).to include(game)
    end
  end

  describe 'GET #edit_user' do
    let(:user) { User.create!(username: 'testuser', email: 'testuser@example.com', password: 'password123') }

    it 'assigns the requested user to @user' do
      get :edit_user, { :id => user.id }

      expect(assigns(:user)).to eq(user)
      expect(response).to render_template(:edit_user)
    end
  end

  describe 'POST #add_user_form' do
    context 'with valid parameters' do
      it 'creates a new user and redirects to the admin index' do
        post :add_user_form, { :user => { :username => 'newuser', :email => 'newuser@example.com', :password => 'password123', :shard_amount => 100.0, :isAdmin => false } }

        expect(User.last.username).to eq('newuser')
        expect(response).to redirect_to(admin_path)
        expect(flash[:notice]).to eq('User created successfully')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new user and re-renders the add_user template' do
        post :add_user_form, { :user => { :username => '', :email => '', :password => '' } }

        expect(response).to render_template(:add_user)
        expect(flash.now[:alert]).to include('Failed to create user')
      end
    end
  end

  describe 'GET #add_user' do
    it 'assigns a new User to @user' do
      get :add_user, {}

      expect(assigns(:user)).to be_a_new(User)
      expect(response).to render_template(:add_user)
    end
  end

  describe 'POST #edit_user_form' do
    let(:user) { User.create!(username: 'testuser', email: 'testuser@example.com', password: 'password123') }

    context 'with valid parameters' do
      it 'updates the user and redirects to the admin index' do
        post :edit_user_form, { :id => user.id, :user => { :username => 'updateduser', :shard_amount => 50.0 } }

        expect(user.reload.username).to eq('updateduser')
        expect(user.reload.shard_amount).to eq(50.0)
        expect(response).to redirect_to(admin_path)
        expect(flash[:notice]).to eq('User updated successfully')
      end
    end

    context 'with invalid parameters' do
      it 'does not update the user and re-renders the edit_user template' do
        post :edit_user_form, { :id => user.id, :user => { :username => '' } }

        expect(user.reload.username).to eq('testuser')
        expect(response).to render_template(:edit_user)
        expect(flash.now[:alert]).to include('Failed to update user')
      end
    end
  end

  describe 'DELETE #delete_user_form' do
    let!(:user) { User.create!(username: 'testuser', email: 'testuser@example.com', password: 'password123') }

    it 'deletes the user and redirects to the admin index' do
      expect { delete :delete_user_form, { :id => user.id } }.to change(User, :count).by(-1)
      expect(response).to redirect_to(admin_path)
      expect(flash[:notice]).to eq('User deleted successfully.')
    end

    it 'handles failed deletion and sets an alert' do
      allow_any_instance_of(User).to receive(:destroy).and_return(false)
      delete :delete_user_form, { :id => user.id }

      expect(response).to redirect_to(admin_path)
      expect(flash[:alert]).to include('Failed to delete user')
    end

    it 'handles non-existent users gracefully' do
      delete :delete_user_form, { :id => 9999 }

      expect(response).to redirect_to(admin_path)
      expect(flash[:alert]).to eq('User not found.')
    end
  end
end
