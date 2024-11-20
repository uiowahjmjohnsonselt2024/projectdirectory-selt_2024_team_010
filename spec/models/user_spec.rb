require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    let(:valid_attributes) do
      {
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      }
    end

    it 'is valid with valid attributes' do
      user = User.new(valid_attributes)
      expect(user).to be_valid
    end

    it 'is invalid without a username' do
      user = User.new(valid_attributes.except(:username))
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("can't be blank")
    end

    it 'is invalid without an email' do
      user = User.new(valid_attributes.except(:email))
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is invalid with an improperly formatted email' do
      user = User.new(valid_attributes.merge(email: 'invalid-email'))
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end

    it 'is invalid with a duplicate email' do
      User.create!(valid_attributes)
      duplicate_user = User.new(valid_attributes)
      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include('has already been taken')
    end

    it 'is invalid without a password' do
      user = User.new(valid_attributes.except(:password, :password_confirmation))
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it 'is invalid with a password less than 6 characters' do
      user = User.new(valid_attributes.merge(password: 'short', password_confirmation: 'short'))
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
    end

    it 'is invalid with a password longer than 25 characters' do
      long_password = 'a' * 26
      user = User.new(valid_attributes.merge(password: long_password, password_confirmation: long_password))
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too long (maximum is 25 characters)')
    end
  end

  describe 'secure password' do
    it 'authenticates with the correct password' do
      user = User.create!(username: 'testuser', email: 'test@example.com', password: 'password123', password_confirmation: 'password123')
      expect(user.authenticate('password123')).to eq(user)
    end

    it 'does not authenticate with an incorrect password' do
      user = User.create!(username: 'testuser', email: 'test@example.com', password: 'password123', password_confirmation: 'password123')
      expect(user.authenticate('wrongpassword')).to be_falsey
    end
  end

  describe 'associations' do
    it 'destroys the associated session when the user is destroyed' do
      user = User.create!(username: 'testuser', email: 'test@example.com', password: 'password123', password_confirmation: 'password123')
      session = user.create_session!(session_token: SecureRandom.urlsafe_base64)
      expect { user.destroy }.to change { Session.count }.by(-1)
    end
  end
end