class Game < ActiveRecord::Base
  belongs_to :user
  has_many :characters, dependent: :destroy
end