require 'rails_helper'

RSpec.describe Item, type: :model do
  # Define a factory for the `Character` model for association testing
  let(:character) { Character.create!(
    user_id: 1,
    game_id: 1,
    level: 5,
    currentHealth: 8,
    x_position: 10,
    y_position: 20,
    maxHealth: 15
  )
  }

  # Create a valid Item instance
  subject do
    described_class.new(
      name: "Excalibur",
      item_type: "weapon",
      character: character
    )
  end

  describe 'attributes' do
    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'is invalid without a name' do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without an item_type' do
      subject.item_type = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:item_type]).to include("can't be blank")
    end

    it 'is invalid with an incorrect item_type' do
      subject.item_type = "potion"
      expect(subject).not_to be_valid
      expect(subject.errors[:item_type]).to include("potion is not a valid type")
    end

    it 'is invalid without a character_id' do
      subject.character = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:character_id]).to include("can't be blank")
    end
  end
end
