require 'rails_helper'

RSpec.describe PasswordResetMailer, type: :mailer do
  before do
    Rails.application.routes.default_url_options[:host] = 'localhost:3000'
  end

  describe 'reset_email' do
    let(:user) do
      double(
        'User',
        email: 'user@example.com',
        password_reset_token: '12345token',
        name: 'Test User'
      )
    end
    let(:mail) { PasswordResetMailer.reset_email(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Password Reset Instructions')
      expect(mail.to).to eq(['user@example.com'])
      expect(mail.from).to eq(['no-reply@shardsofthegrid.com'])
    end

    it 'renders the body with the reset URL' do
      expect(mail.body.encoded).to include('Password Reset Instructions')
      expect(mail.body.encoded).to include(edit_password_reset_url(user.password_reset_token))
    end
  end
end