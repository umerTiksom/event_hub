class User < ApplicationRecord
  has_many :registrations
  has_many :events
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: %w[user organizer admin] }
  def user?
    role == "user"
  end

  def organizer?
    role == "organizer"
  end

  def admin?
    role == "admin"
  end
end
