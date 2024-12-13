require 'rails_helper'

RSpec.describe Chat, type: :model do
  # Define a factory for the `game` model for association testing
  let(:game) { Game.create!(name: "testUser", owner_id: "1", max_user_count: 3) }

  # Create a valid chat instance
  subject { Chat.create!(game_id: game.id, time_sent: DateTime.now, user: "testUser", message:"Hello") }

  describe 'attributes' do
    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'is invalid without a time_sent' do
      subject.time_sent = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:time_sent]).to include("can't be blank")
    end

    it 'belongs to a game' do
      expect(subject.game).to eq(game)
    end
  end
end
