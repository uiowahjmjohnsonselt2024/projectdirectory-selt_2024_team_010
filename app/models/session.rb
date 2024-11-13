class Session < ActiveRecord::Base
  belongs_to :user
  validates :session_token, presence: true, uniqueness: true #Never have multiple sessions with the same token!
  validates :user_id, presence: true
  def create_session_token
    self.session_token = SecureRandom.urlsafe_base64
  end
end
