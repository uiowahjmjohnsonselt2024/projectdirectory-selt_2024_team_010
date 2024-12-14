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

  describe '.from_omniauth' do
    let(:auth) do
      {
        info: {
          email: 'oauth_user@example.com',
          nickname: 'oauth_user'
        }
      }
    end

    it 'returns the exception when user creation fails' do
      allow(User).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(User.new))

      result = User.from_omniauth(auth)

      expect(result).to be_a(ActiveRecord::RecordInvalid)
    end

    context 'when the user does not exist' do
      it 'creates a new user with valid attributes' do
        user = User.from_omniauth(auth)

        expect(user).to be_persisted
        expect(user.email).to eq('oauth_user@example.com')
        expect(user.username).to eq('oauth_user')
        expect(user.is_oauth).to be true
      end

      it 'handles duplicate usernames by appending a unique suffix' do
        User.create!(username: 'oauth_user', email: 'existing_user@example.com', password: 'password123')
        user = User.from_omniauth(auth)

        expect(user.username).not_to eq('oauth_user')
        expect(user.username).to match(/^oauth_user#.+$/)
      end
    end

    context 'when the user exists but is not an OAuth user' do
      it 'returns a NameError' do
        User.create!(username: 'oauth_user', email: 'oauth_user@example.com', password: 'password123', is_oauth: false)
        error = User.from_omniauth(auth)

        expect(error).to be_a(NameError)
      end
    end

    context 'when the user exists and is an OAuth user' do
      it 'returns the existing user' do
        existing_user = User.create!(username: 'oauth_user', email: 'oauth_user@example.com', password: 'password123', is_oauth: true)
        user = User.from_omniauth(auth)

        expect(user).to eq(existing_user)
      end
    end

    context 'when user creation fails' do
      before do
        allow(User).to receive(:create!).and_raise(ActiveRecord::RecordInvalid, 'Validation failed')
      end
    end
  end
  describe '#generate_password_reset_token!' do
    let(:user) { User.create!(username: 'testuser', email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }

    it 'generates a password reset token and sets the sent time' do
      user.generate_password_reset_token!

      expect(user.password_reset_token).not_to be_nil
      expect(user.password_reset_sent_at).to be_within(1.second).of(Time.zone.now)
    end
  end
  describe '#password_reset_valid?' do
    let(:user) { User.create!(username: 'testuser', email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }

    it 'returns true if the password reset token was sent within the last 2 hours' do
      user.update(password_reset_sent_at: 1.hour.ago)
      expect(user.password_reset_valid?).to be true
    end

    it 'returns false if the password reset token was sent more than 2 hours ago' do
      user.update(password_reset_sent_at: 3.hours.ago)
      expect(user.password_reset_valid?).to be false
    end
  end
  describe '#clear_password_reset_token!' do
    let(:user) { User.create!(username: 'testuser', email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }

    it 'clears the password reset token and sent time' do
      user.update(password_reset_token: 'token', password_reset_sent_at: Time.zone.now)
      user.clear_password_reset_token!

      expect(user.password_reset_token).to be_nil
      expect(user.password_reset_sent_at).to be_nil
    end
  end
end