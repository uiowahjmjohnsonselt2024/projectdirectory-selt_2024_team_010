require 'rails_helper'

RSpec.describe GameshopController, type: :controller do
  let(:user) { User.create!(username: 'testuser', email: 'test@example.com', password: 'password123', password_confirmation: 'password123', shard_amount: 100) }
  let(:game) { user.games.create!(name: 'Test Game', owner_id: user.id, max_user_count: 6) }
  let(:character) { user.characters.create!(game: game) }
  let(:openai_service) { instance_double(OpenAIService) }

  before do
    allow(OpenAIService).to receive(:new).and_return(openai_service)
    allow(openai_service).to receive(:generate_content).and_return(
      <<~JSON
        {
          "items": [
            { "name": "Excalibur", "category": "Weapon", "price": 50, "description": "A legendary sword" },
            { "name": "Dragon Armor", "category": "Armor", "price": 70, "description": "Armor made of dragon scales" },
            { "name": "Fireball", "category": "Abilities", "price": 40, "description": "Casts a fireball" }
          ]
        }
      JSON
    )
  end


  describe "POST #update_shards" do
    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "when the shard_amount parameter is valid" do
      it "deducts shards successfully and returns the updated amount" do
        post :update_shards, { shard: { shard_amount: 50 } }, format: :json

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["success"]).to be true
        expect(parsed_response["shard_amount"]).to eq(50.0) # Initial amount (100) - 50 = 50
      end

      it "prevents shard deduction if it would result in a negative amount" do
        post :update_shards, { shard: { shard_amount: 150 } }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["error"]).to eq("Insufficient shards. Cannot deduct -150.0 shards.")
      end
    end

    context "when the shard_amount parameter is missing" do
      it "returns a bad request error" do
        post :update_shards, {}, format: :json

        expect(response).to have_http_status(:bad_request)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["error"]).to eq("Missing shard parameters.")
      end
    end

    context "when the user update fails" do
      it "returns an internal server error" do
        allow(user).to receive(:update).and_return(false)

        post :update_shards, { shard: { shard_amount: 30 } }, format: :json

        expect(response).to have_http_status(:internal_server_error)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["error"]).to eq("Failed to update shards.")
      end
    end
  end

  describe 'POST #buy' do
    let(:user) { User.create!(username: 'testuser', email: 'test@example.com', password: 'password123', shard_amount: 100) }
    let(:game) { Game.create!(name: 'Test Game', owner_id: user.id, max_user_count: 6) }
    let!(:character) do
      Character.create!(user: user, game: game, level: 5, currentHealth: 50, maxHealth: 100).tap do |c|
        user.update!(recent_character: c.id)
      end
    end

    before do
      allow(controller).to receive(:current_user).and_return(user)
      controller.instance_variable_set(:@current_game, game)
      controller.instance_variable_set(:@current_user, user)
      controller.instance_variable_set(:@current_character, character)
    end

    context 'when no character is found' do
      before do
        user.update!(recent_character: nil)
      end

      it 'returns an error if no character is found' do
        post :buy, { item: { name: 'Sword', price: 50 } }, format: :json
        expect(response).to have_http_status(:bad_request)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['error']).to eq('No character found to assign item to.')
      end
    end

    context 'when the user does not have enough shards' do
      it 'returns an error for insufficient shards' do
        post :buy, { item: { name: 'Sword', price: 150, category: 'weapons' } }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['error']).to eq('You do not have enough shards.')
      end
    end

    context 'when the category is invalid' do
      it 'returns an error for invalid category' do
        post :buy, { item: { name: 'Sword', price: 50, category: 'invalid_category' } }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['error']).to eq('invalid_category is not a valid category')
      end
    end

    context 'when buying a weapon, armor, or artifact' do
      it 'deducts shards and creates an item' do
        post :buy, { item: { name: 'Sword', price: 50, category: 'weapons', description: 'A sharp blade' } }, format: :json
        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['success']).to be true
        expect(parsed_response['item']['name']).to eq('Sword')
        expect(parsed_response['shard_amount']).to eq(50.0) # Initial 100 - price 50
      end
    end

    context 'when buying healing items' do
      it 'applies Full Heal to the character' do
        post :buy, { item: { name: 'Full Heal', price: 50, category: 'healing' } }, format: :json
        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['success']).to be true
        expect(parsed_response['message']).to eq('You have been fully healed!')
        expect(character.reload.currentHealth).to eq(character.maxHealth)
        expect(parsed_response['shard_amount']).to eq(50.0)
      end

      it 'increases max health and heals the character for Max HP Boost' do
        post :buy, { item: { name: 'Max HP Boost', price: 50, category: 'healing' } }, format: :json
        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['success']).to be true
        expect(parsed_response['message']).to eq('Your maximum HP has increased by 10, and you are fully healed!')
        expect(character.reload.maxHealth).to eq(110)
        expect(character.reload.currentHealth).to eq(110)
        expect(parsed_response['shard_amount']).to eq(50.0)
      end

      it 'returns an error for unknown healing options' do
        post :buy, { item: { name: 'Unknown Heal', price: 50, category: 'healing' } }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['error']).to eq('Unknown healing option.')
      end
    end
  end

  describe "GET #generate_items" do
    it "returns a list of generated items in JSON format" do
      get :generate_items, format: :json
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["items"].size).to eq(3)
      expect(parsed_response["items"].first["category"]).to eq("Weapon")
    end
  end
end
