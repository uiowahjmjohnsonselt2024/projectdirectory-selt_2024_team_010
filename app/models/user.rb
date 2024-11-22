class User < ActiveRecord::Base
  has_secure_password
  has_one :session, dependent: :destroy

  validates :username, presence: true, uniqueness: true, length: { maximum: 25 }
  validates :email, presence: true, uniqueness: true,
            format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  validates :password, length: { minimum: 6, maximum: 25 }, allow_nil: true
end