require 'rails_helper'

RSpec.describe Session, type: :model do
  let(:user) { User.create(username: 'testuser', email: 'test@example.com', password: 'password', password_confirmation: 'password') }

  describe 'validations' do
    it 'is valid with a session_token and user_id' do
      session = Session.new(session_token: SecureRandom.urlsafe_base64, user: user)
      expect(session).to be_valid
    end

    it 'is invalid without a session_token' do
      session = Session.new(user: user)
      expect(session).not_to be_valid
      expect(session.errors[:session_token]).to include("can't be blank")
    end

    it 'is invalid without a user_id' do
      session = Session.new(session_token: SecureRandom.urlsafe_base64)
      expect(session).not_to be_valid
      expect(session.errors[:user_id]).to include("can't be blank")
    end

    it 'is invalid with a duplicate session_token' do
      token = SecureRandom.urlsafe_base64
      Session.create(session_token: token, user: user)
      duplicate_session = Session.new(session_token: token, user: user)
      expect(duplicate_session).not_to be_valid
      expect(duplicate_session.errors[:session_token]).to include("has already been taken")
    end
  end

  describe '.create_session_token' do
    it 'returns a unique session token' do
      token = Session.create_session_token
      expect(token).to be_a(String)
      expect(token).not_to be_empty
    end
  end
end
