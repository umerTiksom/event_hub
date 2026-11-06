
class User < ApplicationRecord
  has_many :events, dependent: :destroy
  has_many :registrations, dependent: :destroy

  has_secure_password

  validates :email, presence: true, uniqueness: true

  def user?
    role == "user"
  end

  def organizer?
    role == "organizer"
  end

  def admin?
    role == "admin"
  end

  # Generate secure password reset token
  def generate_password_reset_token
    token = SecureRandom.urlsafe_base64(32)

    update!(
      reset_password_token: BCrypt::Password.create(token),
      reset_password_sent_at: Time.current
    )

    token
  end

  # Check token expiry (15 minutes)
  def password_reset_token_valid?
    reset_password_sent_at.present? &&
      reset_password_sent_at > 15.minutes.ago
  end

  # Verify original token against hashed token
  def valid_password_reset_token?(token)
    return false if reset_password_token.blank?
    return false unless password_reset_token_valid?

    BCrypt::Password.new(reset_password_token).is_password?(token)
  end
end
