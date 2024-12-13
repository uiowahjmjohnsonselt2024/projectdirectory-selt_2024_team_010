require 'rails_helper'

RSpec.describe Tile, type: :model do
  describe 'associations' do
    it 'belongs to a game' do
      tile = Tile.reflect_on_association(:game)
      expect(tile.macro).to eq(:belongs_to)
    end
  end

  describe 'validations' do
    let(:game) { Game.create!(name: 'Test Game', owner_id: 1, max_user_count: 6) }

    it 'is valid with valid attributes' do
      tile = Tile.new(x_position: 1, y_position: 1, game: game)
      expect(tile).to be_valid
    end

    it 'is invalid without an x_position' do
      tile = Tile.new(y_position: 1, game: game)
      expect(tile).not_to be_valid
      expect(tile.errors[:x_position]).to include("can't be blank")
    end

    it 'is invalid without a y_position' do
      tile = Tile.new(x_position: 1, game: game)
      expect(tile).not_to be_valid
      expect(tile.errors[:y_position]).to include("can't be blank")
    end

    it 'is invalid if another tile exists with the same x_position, y_position, and game_id' do
      Tile.create!(x_position: 1, y_position: 1, game: game)
      duplicate_tile = Tile.new(x_position: 1, y_position: 1, game: game)

      expect(duplicate_tile).not_to be_valid
      expect(duplicate_tile.errors[:x_position]).to include('has already been taken')
    end

    it 'is valid if another tile exists with the same x_position and y_position but different game_id' do
      another_game = Game.create!(name: 'Another Game', owner_id: 1, max_user_count: 6)
      Tile.create!(x_position: 1, y_position: 1, game: game)
      valid_tile = Tile.new(x_position: 1, y_position: 1, game: another_game)

      expect(valid_tile).to be_valid
    end
  end
end
