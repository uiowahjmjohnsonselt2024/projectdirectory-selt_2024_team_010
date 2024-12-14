require 'rails_helper'

RSpec.describe SettingsController, type: :controller do
  let(:user) { User.create!(username: 'testuser', email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }

  before do
    allow(controller).to receive(:require_login).and_return(true)
    allow(controller).to receive(:get_current_game)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'assigns the current user and renders the index template' do
      get :index
      expect(response).to render_template(:index)
      expect(assigns(:current_user)).to eq(user)
    end
  end

  describe 'PATCH #update_username' do
    context 'when the username is updated successfully' do
      it 'updates the username and sets a success flash message' do
        patch :update_username, { new_username: 'newusername' }
        expect(user.reload.username).to eq('newusername')
        expect(flash[:notice]).to eq('Username successfully updated!')
        expect(response).to redirect_to(settings_path)
      end
    end

    context 'when the username update fails' do
      it 'sets an alert flash message with errors' do
        allow_any_instance_of(User).to receive(:update).and_return(false)
        allow_any_instance_of(User).to receive_message_chain(:errors, :full_messages).and_return(['Username is invalid'])

        patch :update_username, { new_username: '' }
        expect(flash[:alert]).to eq('Failed to update username. Username is invalid')
        expect(response).to redirect_to(settings_path)
      end
    end
  end

  describe 'PATCH #update_password' do
    context 'when the current password is incorrect' do
      it 'sets an alert flash message and redirects to settings' do
        patch :update_password, { current_password: 'wrongpassword', new_password: 'newpassword', confirm_password: 'newpassword' }
        expect(flash[:alert]).to eq('Current password is incorrect.')
        expect(response).to redirect_to(settings_path)
      end
    end

    context 'when the new password and confirmation do not match' do
      it 'sets an alert flash message and redirects to settings' do
        patch :update_password, { current_password: 'password123', new_password: 'newpassword', confirm_password: 'differentpassword' }
        expect(flash[:alert]).to eq('New password and confirmation do not match.')
        expect(response).to redirect_to(settings_path)
      end
    end

    context 'when the password is updated successfully' do
      it 'updates the password and sets a success flash message' do
        patch :update_password, { current_password: 'password123', new_password: 'newpassword', confirm_password: 'newpassword' }
        expect(user.reload.authenticate('newpassword')).to eq(user)
        expect(flash[:notice]).to eq('Password successfully updated!')
        expect(response).to redirect_to(settings_path)
      end
    end

    context 'when the password update fails' do
      it 'sets an alert flash message with errors' do
        allow_any_instance_of(User).to receive(:update).and_return(false)
        allow_any_instance_of(User).to receive_message_chain(:errors, :full_messages).and_return(['Password is too short'])

        patch :update_password, { current_password: 'password123', new_password: 'short', confirm_password: 'short' }
        expect(flash[:alert]).to eq('Failed to update password. Password is too short')
        expect(response).to redirect_to(settings_path)
      end
    end
  end
end
