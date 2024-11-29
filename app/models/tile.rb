class Tile < ActiveRecord::Base
  belongs_to :game

  # X+Y are unique as a pair, but as long as X is unique, Y can be the same and vice versa.
  validates :x_position, presence: true, uniqueness: { scope: :y_position }
  validates :y_position, presence: true
end