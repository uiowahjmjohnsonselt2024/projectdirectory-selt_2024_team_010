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
  end

  describe "POST #buy" do
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
