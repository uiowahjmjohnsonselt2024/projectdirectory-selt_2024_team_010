class User < ActiveRecord::Base
  has_secure_password
  has_one :session, dependent: :destroy
  has_many :games, dependent: :destroy
  has_many :characters, dependent: :destroy
  has_many :games, through: :characters

  validates :username, presence: true, uniqueness: true, length: { maximum: 25 }
  validates :email, presence: true, uniqueness: true,
            format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  validates :password, length: { minimum: 6, maximum: 25 }, allow_nil: true
  has_many :payments, dependent: :destroy

  def generate_password_reset_token!
    self.password_reset_token = SecureRandom.urlsafe_base64
    self.password_reset_sent_at = Time.zone.now
    save!
  end

  def password_reset_valid?
    password_reset_sent_at > 2.hours.ago
  end

  def clear_password_reset_token!
    self.update!(password_reset_token: nil, password_reset_sent_at: nil)
  end
end