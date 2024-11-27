class Character < ActiveRecord::Base
  belongs_to :user
  belongs_to :game

  validates :user_id, presence: true, uniqueness: { scope: :game_id }
  validates :game_id, presence: true
end