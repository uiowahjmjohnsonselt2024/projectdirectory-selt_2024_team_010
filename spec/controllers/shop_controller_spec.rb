require 'rails_helper'

RSpec.describe ShopController, type: :controller do
  let(:user) { User.create!(username: 'testuser', email: 'test@example.com', password: 'password123', password_confirmation: 'password123', shard_amount: 50, money_usd: 100) }

  before do
    allow(controller).to receive(:require_login).and_return(true)
    allow(controller).to receive(:get_current_game)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'assigns shard_amount and money_usd for the current user' do
      get :index
      expect(assigns(:shard_amount)).to eq(50)
      expect(assigns(:money_usd)).to eq(100)
    end
  end

  describe 'GET #balance' do
    it 'returns the shard amount and money balance of the user' do
      get :balance, format: :json
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['shard_amount']).to eq(50)
      expect(parsed_response['money_usd']).to eq(100)
    end
  end

  describe 'POST #purchase' do
    context 'when quantity is not an integer' do
      it 'returns an error' do
        post :purchase, { quantity: 'invalid', cost: 10 }
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['error']).to eq('Quantity must be an integer.')
      end
    end

    context 'when quantity or cost is invalid' do
      it 'returns an error for invalid quantity' do
        post :purchase, { quantity: 0, cost: 10 }
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['error']).to eq('Invalid quantity or cost.')
      end

      it 'returns an error for invalid cost' do
        post :purchase, { quantity: 5, cost: 0 }
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['error']).to eq('Invalid quantity or cost.')
      end
    end

    context 'when the user has insufficient balance' do
      it 'returns an error' do
        post :purchase, { quantity: 5, cost: 200 }
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['error']).to eq('Insufficient balance.')
      end
    end

    context 'when the purchase is successful' do
      it 'updates the user balance and shard amount' do
        post :purchase, { quantity: 10, cost: 50 }
        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['shard_amount']).to eq(60)
        expect(parsed_response['money_usd']).to eq(50)
      end
    end
  end

  describe 'POST #payment' do
    context 'when the amount is invalid' do
      it 'returns an error for amount less than or equal to zero' do
        post :payment, { currency: 'USD', amount: -10 }
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['error']).to eq('Invalid amount.')
      end
    end

    context 'when the payment is successful' do
      it 'creates a payment and updates the user balance' do
        expect do
          post :payment, { currency: 'USD', amount: 50 }
        end.to change(Payment, :count).by(1)
        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['money_usd']).to eq(150)
      end
    end
  end

  describe 'GET #payment_history' do
    let!(:payment1) { Payment.create!(user: user, money_usd: 50, currency: 'USD') }
    let!(:payment2) { Payment.create!(user: user, money_usd: 25, currency: 'USD') }

    it 'returns the user’s payment history in JSON format' do
      get :payment_history, format: :json
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response.size).to eq(2)
      expect(parsed_response.first['money_usd']).to eq(25) # Most recent first
    end
  end
end
