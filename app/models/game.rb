class Game < ActiveRecord::Base
  belongs_to :user, foreign_key: :owner_id
  has_many :characters, dependent: :destroy
  has_many :users, through: :characters

  validates :owner_id, presence: true
  validates :name, presence: true, uniqueness: { scope: :owner_id } #Names are unique over a given owner.
end