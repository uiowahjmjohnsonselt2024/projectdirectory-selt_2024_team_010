require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  let(:user) { User.create!(username: 'testuser', email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }

  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'when the email is found' do
      it 'generates a password reset token and sends an email' do
        expect_any_instance_of(User).to receive(:generate_password_reset_token!)
        expect(PasswordResetMailer).to receive_message_chain(:reset_email, :deliver_now)

        post :create, { email: user.email }
        expect(flash[:notice]).to eq('Check your email for reset instructions.')
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when the email is not found' do
      it 'renders the new template with an alert' do
        post :create, { email: 'nonexistent@example.com' }
        expect(flash[:alert]).to eq('Email address not found.')
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    context 'when the reset token is valid' do
      before do
        user.generate_password_reset_token!
      end

      it 'renders the edit template' do
        get :edit, { id: user.password_reset_token }
        expect(response).to render_template(:edit)
        expect(assigns(:user)).to eq(user)
      end
    end

    context 'when the reset token is invalid or expired' do
      it 'redirects to the new password reset path with an alert' do
        get :edit, { id: 'invalid_token' }
        expect(flash[:alert]).to eq('Reset link is invalid or expired.')
        expect(response).to redirect_to(new_password_reset_path)
      end
    end
  end

  describe 'PATCH #update' do
    before do
      user.generate_password_reset_token!
    end

    context 'when the reset token is valid' do
      it 'resets the password and redirects to the login path' do
        patch :update, {
          id: user.password_reset_token,
          user: { password: 'newpassword', password_confirmation: 'newpassword' }
        }

        expect(user.reload.authenticate('newpassword')).to eq(user)
        expect(flash[:notice]).to eq('Password successfully reset. Please log in.')
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when the reset token is invalid' do
      it 'redirects to the new password reset path with an alert' do
        patch :update, { id: 'invalid_token', user: { password: 'newpassword', password_confirmation: 'newpassword' } }
        expect(flash[:alert]).to eq('Invalid reset link.')
        expect(response).to redirect_to(new_password_reset_path)
      end
    end

    context 'when the password update fails' do
      it 're-renders the edit template' do
        patch :update, {
          id: user.password_reset_token,
          user: { password: 'short', password_confirmation: 'short' } # Invalid password length
        }

        expect(response).to render_template(:edit)
        expect(assigns(:user).errors[:password]).to include('is too short (minimum is 6 characters)')
      end
    end
  end
end
