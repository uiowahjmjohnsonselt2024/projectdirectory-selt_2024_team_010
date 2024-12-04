# frozen_string_literal: true

class Item < ActiveRecord::Base
  belongs_to :character
  validates :type, presence: true, inclusion: { in: %w[weapon armor], message: "%{value} is not a valid type" }
  validates :name, presence: true
  validates :character_id, presence: true
end
