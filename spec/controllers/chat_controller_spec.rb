require 'rails_helper'

RSpec.describe ChatController, type: :controller do
  let(:user) { User.create(
    username: "PlayerOne",
    email: "playerone@example.com",
    password_digest: BCrypt::Password.create("password123"),
    shard_amount: 50.0,
    money_usd: 100.0,
    created_at: Time.now,
    updated_at: Time.now,
    recent_character: 1,
    isAdmin: false,
    is_oauth: false
  )
  }
  let(:game) { Game.create(
    name: "Adventure Quest",
    owner_id: user.id,
    max_user_count: 10
  )
  }

  before do
    allow(controller).to receive(:require_login).and_return(true)
    allow(controller).to receive(:get_current_game).and_return(game)
    allow(controller).to receive(:current_user).and_return(user)
    controller.instance_variable_set(:@current_game, game)
    controller.instance_variable_set(:@current_user, user)
  end

  describe 'POST #create' do
    context 'when a valid message is provided' do
      it 'creates a new chat message' do
        expect {
          post :create, params: { message: 'Hello, world!' }
        }.to change { game.chats.count }.by(1)
      end

      it 'does not exceed the chat limit of 5 messages' do
        post :create, params: { message: 'Hello, new message1!' }
        post :create, params: { message: 'Hello, new message2!' }
        post :create, params: { message: 'Hello, new message3!' }
        post :create, params: { message: 'Hello, new message4!' }
        post :create, params: { message: 'Hello, new message5!' }
        expect(game.chats.count).to eq(5)

        post :create, params: { message: 'Hello, new message!' }
        expect(game.chats.count).to eq(5)
      end

      it 'removes the oldest message when exceeding the limit' do
        chats = 6.times.map { Chat.create(game: game, time_sent: 1.minutes.ago) }
        oldest_chat = chats.first

        post :create, params: { message: 'This is a new message!' }

        expect(game.chats).not_to include(oldest_chat)
        expect(game.chats.count).to eq(6)
      end

      it 'returns a no content response' do
        post :create, params: { message: 'Testing no content' }
        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe 'GET #list' do
    it 'returns a JSON response with all chat messages' do
      Chat.create(game: game, message: 'First message', time_sent: 2.minutes.ago)
      Chat.create(game: game, message: 'Second message', time_sent: 1.minute.ago)

      get :list

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq('application/json')
      json = JSON.parse(response.body)
      expect(json['chatLog'].length).to eq(2)
      expect(json['chatLog'].first['message']).to eq('First message')
    end

    it 'returns chat messages in ascending order of time_sent' do
      chat1 = Chat.create(game: game, message: 'Earlier message', time_sent: 5.minutes.ago)
      chat2 = Chat.create(game: game, message: 'Later message', time_sent: 1.minute.ago)

      get :list

      json = JSON.parse(response.body)
      expect(json['chatLog'].first['message']).to eq(chat1.message)
      expect(json['chatLog'].last['message']).to eq(chat2.message)
    end
  end
end
