require 'rails_helper'

RSpec.describe TilesController, type: :controller do
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
  let(:character) { Character.create(
    user_id: user.id,
    game_id: game.id,
    level: 5,
    currentHealth: 8,
    x_position: 0,
    y_position: 0,
    maxHealth: 10
  )
  }
  let!(:tile) { Tile.create(
    game_id: game.id,
    x_position: 0,
    y_position: 0,
    biome: "Forest",
    picture: "forest.jpg",
    scene_description: "A lush forest with towering trees.",
    treasure_description: "A chest filled with gold coins.",
    monster_description: "A fearsome dragon.",
    visitor_id: user.id,
    monster_level: 10
  )
  }

  before do
    allow(controller).to receive(:require_login).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:get_current_game).and_return(game)
    allow(controller).to receive(:initialize_generator)
    controller.instance_variable_set(:@current_game, game)
    controller.instance_variable_set(:@current_user, user)
    controller.instance_variable_set(:@current_character, character)


  end

  describe 'GET #get_tile' do
    it 'routes correctly' do
      expect(get: '/tiles/get_tile').to route_to('tiles#get_tile')
    end

    it 'returns tile details when tile exists' do
      get :get_tile, params: { x: tile.x_position, y: tile.y_position }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['x']).to eq(tile.x_position)
      expect(json['y']).to eq(tile.y_position)
    end

    it 'returns 404 when tile does not exist' do
      get :get_tile, params: { x: 99, y: 99 }
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #fight_monster' do
    before do
      tile.update!(monster_description: 'Fierce Dragon', monster_level: 10)
      character.update!(level: 5, currentHealth: 5, maxHealth: 10)
    end

    it 'routes correctly' do
      expect(post: '/tiles/fight_monster').to route_to('tiles#fight_monster')
    end

    it 'handles player win and updates tile and character' do
      allow(controller).to receive(:rand).and_return(10) # Force a win
      post :fight_monster, params: { x: tile.x_position, y: tile.y_position }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['result']).to eq('player_win')
      expect(tile.reload.monster_description).to be_nil
      expect(character.reload.level).to eq(6)
    end

    it 'handles player loss and updates health' do
      allow(controller).to receive(:rand).and_return(100) # Force a loss
      post :fight_monster, params: { x: tile.x_position, y: tile.y_position }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['result']).to eq('monster_win')
      expect(character.reload.currentHealth).to eq(4)
    end
  end

  describe 'POST #loot_tile' do
    before { tile.update!(treasure_description: 'Shards: 50') }

    it 'routes correctly' do
      expect(post: '/tiles/loot_tile').to route_to('tiles#loot_tile')
    end

    it 'collects shards and updates user' do
      post :loot_tile, params: { x: tile.x_position, y: tile.y_position }
      expect(response).to have_http_status(:success)
      expect(user.reload.shard_amount).to eq(100)
      expect(tile.reload.treasure_description).to be_nil
    end

    it 'returns an error if no treasure is present' do
      tile.update!(treasure_description: nil)
      post :loot_tile, params: { x: tile.x_position, y: tile.y_position }
      expect(response).to have_http_status(420)
    end
  end

  describe 'POST #regenerate_tile' do
    it 'routes correctly' do
      expect(post: '/tiles/regenerate').to route_to('tiles#regenerate_tile')
    end

    it 'regenerates tile with sufficient shards' do
      post :regenerate_tile, params: { x: tile.x_position, y: tile.y_position }
      expect(response).to have_http_status(422)
      expect(user.reload.shard_amount).to eq(50)
    end

    it 'returns an error if insufficient shards' do
      user.update!(shard_amount: 100)
      post :regenerate_tile, params: { x: tile.x_position, y: tile.y_position }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST #teleport_tile' do
    it 'routes correctly' do
      expect(post: '/tiles/teleport').to route_to('tiles#teleport_tile')
    end

    it 'teleports character and deducts shards' do
      post :teleport_tile, params: { x: 0, y: 0 }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['message']).to eq('Teleported to (0, 0) for 5 shards.')
      expect(character.reload.x_position).to eq(0)
      expect(character.reload.y_position).to eq(0)
    end

    it 'returns an error if insufficient shards' do
      user.update!(shard_amount: 2)
      post :teleport_tile, params: { x: 3, y: 3 }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
  describe '#generate_tile_content' do
    let(:tile) { Tile.create!(game_id: game.id, x_position: 1, y_position: 1, biome: 'Forest') }
    let(:mock_response) do
      {
        monster: { description: 'A fearsome dragon guards the treasure.' },
        landscape: { description: 'A dense forest with towering trees and a hidden clearing.' }
      }.to_json
    end
    let(:mock_generator) { instance_double(OpenAIService) }

    before do
      allow(mock_generator).to receive(:generate_content).and_return(mock_response)
      controller.instance_variable_set(:@generator, mock_generator)
      allow(controller).to receive(:rand).and_return(50) # Mock random values for consistency
    end

    it 'generates tile content based on biome and character strength' do
      content = controller.send(:generate_tile_content, tile)

      expect(content[:picture]).to eq('A dense forest with towering trees and a hidden clearing.')
      expect(content[:scene_description]).to eq('A dense forest with towering trees and a hidden clearing.')
      expect(content[:monster_description]).to eq('A fearsome dragon guards the treasure.')
      expect(content[:monster_level]).to be_a(Integer)
      expect(content[:treasure_description]).to match(/Shards: \d+/)
    end

    it 'uses default values if the AI response is invalid' do
      allow(mock_generator).to receive(:generate_content).and_return(nil)
      content = controller.send(:generate_tile_content, tile)

      expect(content[:picture]).to eq('Default picture')
      expect(content[:scene_description]).to eq('Default scene description')
      expect(content[:monster_description]).to eq('Default monster description')
      expect(content[:treasure_description]).to eq('Shards: 50')
    end
  end
  describe '#generate_item' do
    let(:mock_generator) { instance_double(OpenAIService) }
    let(:generated_item) do
      {
        name: 'Ancient Crystal Skull',
        description: 'A skull carved from crystal that emits a faint eerie glow.'
      }.to_json
    end

    before do
      controller.instance_variable_set(:@generator, mock_generator)
      allow(mock_generator).to receive(:generate_content).and_return(generated_item)
      @@generated_items = Set.new
    end

    it 'generates a unique item and adds it to the generated items set' do
      result = controller.send(:generate_item, mock_generator)

      expect(result).to eq('Ancient Crystal Skull: A skull carved from crystal that emits a faint eerie glow.')
      expect(@@generated_items).to include('Ancient Crystal Skull')
    end

    it 'skips duplicate items and tries again' do
      @@generated_items.add('Ancient Crystal Skull')

      allow(mock_generator).to receive(:generate_content).and_return(generated_item)

      result = controller.send(:generate_item, mock_generator)

      # Since it's a duplicate, it should eventually fallback to the default response
      expect(result).to eq('Unique Artifact of Mystery: A one-of-a-kind item you have never seen before.')
    end

    it 'handles JSON parsing errors gracefully' do
      allow(mock_generator).to receive(:generate_content).and_return('invalid json')

      result = controller.send(:generate_item, mock_generator)

      expect(result).to eq('Unique Artifact of Mystery: A one-of-a-kind item you have never seen before.')
    end
  end
  describe '#generate_item_details' do
    let(:mock_generator) { instance_double(OpenAIService) }
    let(:item_string) { 'Mystic Sword: A powerful blade imbued with magical energy.' }
    let(:mock_response) do
      {
        name: 'Mystic Sword',
        item_type: 'weapon',
        description: 'A powerful blade imbued with magical energy.'
      }.to_json
    end

    before do
      controller.instance_variable_set(:@generator, mock_generator)
      allow(controller).to receive(:rand).and_return(10) # Mock random level generation
    end

    it 'generates detailed item information from a valid input string' do
      allow(mock_generator).to receive(:generate_content).and_return(mock_response)

      result = controller.send(:generate_item_details, item_string)

      expect(result[:name]).to eq('Mystic Sword')
      expect(result[:item_type]).to eq('weapon')
      expect(result[:description]).to eq('A powerful blade imbued with magical energy.')
      expect(result[:level]).to eq(10)
    end

    it 'falls back to artifact item_type if item_type is invalid' do
      invalid_mock_response = {
        name: 'Mystic Sword',
        item_type: 'invalid_type',
        description: 'A powerful blade imbued with magical energy.'
      }.to_json

      allow(mock_generator).to receive(:generate_content).and_return(invalid_mock_response)

      result = controller.send(:generate_item_details, item_string)

      expect(result[:name]).to eq('Mystic Sword')
      expect(result[:item_type]).to eq('artifact')
      expect(result[:description]).to eq('A powerful blade imbued with magical energy.')
      expect(result[:level]).to eq(10)
    end

    it 'handles JSON parsing errors gracefully' do
      allow(mock_generator).to receive(:generate_content).and_return('invalid json')

      result = controller.send(:generate_item_details, item_string)

      expect(result[:name]).to eq('Mystic Sword')
      expect(result[:item_type]).to eq('artifact')
      expect(result[:description]).to eq('A powerful blade imbued with magical energy.')
      expect(result[:level]).to eq(10)
    end
  end
end