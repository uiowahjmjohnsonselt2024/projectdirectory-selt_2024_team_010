class Game < ActiveRecord::Base
  belongs_to :user, foreign_key: :owner_id
  has_many :characters, dependent: :destroy
  has_many :users, through: :characters
  has_many :tiles, dependent: :destroy
  has_many :chats, dependent: :destroy

  validates :owner_id, presence: true
  validates :name, presence: true, uniqueness: { scope: :owner_id } #Names are unique over a given owner.
  validates :max_user_count, presence: true, numericality: { only_integer: true , greater_than: 0 }
end