class Character < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  has_many :items

  validates :user_id, presence: true, uniqueness: { scope: :game_id }
  validates :game_id, presence: true
  validates :health, presence: true
  validates :level, presence: true
end