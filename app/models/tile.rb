class Tile < ActiveRecord::Base
  belongs_to :game

  # X must be unique with regards to Y and game_id so that no 2 tiles can have the same X,Y,game at the same time.
  validates :x_position, presence: true, uniqueness: { scope: [:y_position, :game_id] }
  validates :y_position, presence: true
end