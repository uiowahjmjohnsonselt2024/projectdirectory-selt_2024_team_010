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
  # note that github oauth scope requires some nonsense
  def self.from_omniauth(auth)
    user = find_by(email: auth['info']['email'])
    unless user
      begin
        # choose a good name and password.
        name =
          if find_by(username: auth['info']['name'])
            # add a discriminator at the end if theres an issue
            "#{auth['info']['name']&.gsub(/\s+/, '')}\##{SecureRandom.base64(4)}"
          else
            auth['info']['name']
          end
        password = SecureRandom.base64(16)

        user = self.create!(
          name: name,
          email: "#{auth.uid}@#{auth.provider}.com", # @todo this is a fake ass email
          password: password,
          password_confirmation: password,
          session_token: SecureRandom.hex(16)
        )
      rescue ActiveRecord::RecordInvalid => e
        return e
      end
    user
    end
  end
end
