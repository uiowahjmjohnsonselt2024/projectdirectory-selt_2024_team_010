class Game < ActiveRecord::Base
  belongs_to :user, foreign_key: :owner_id
  has_many :characters, dependent: :destroy
  has_many :users, through: :characters
end