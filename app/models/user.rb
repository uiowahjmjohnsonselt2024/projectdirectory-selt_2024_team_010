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

  # helper func that logs in via info response from omniauth
  # note that this requires we use the 'user' scope for oauth, see config/initializers/omniauth.rb for its usage
  def self.from_omniauth(auth)
    user = find_by(email: auth[:info][:email])
    unless user
      begin
        # choose a good name and password.
        name = "#{auth['info']['login']&.gsub(/\s+/, '')}\##{SecureRandom.base64(4)}"
        unless find_by(username: auth['info']['login'])
          name = auth['info']['login'] # if we can, just use the normal username
        end
        password = SecureRandom.base64(16)

        user = self.create!(
          username: name,
          email: auth[:info][:email],
          password: password,
        )
        user.update(money_usd: 0, shard_amount: 0)
      rescue ActiveRecord::RecordInvalid => e
        return e
      end
    end
    user
  end
end
