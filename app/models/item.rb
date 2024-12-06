# frozen_string_literal: true

class Item < ActiveRecord::Base
  belongs_to :character
  validates :item_type, presence: true, inclusion: { in: %w[weapon shield armor artifact], message: "%{value} is not a valid type" }
  validates :name, presence: true
  validates :character_id, presence: true
end
