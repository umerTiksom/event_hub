class User < ApplicationRecord
  has_many :registrations
  has_many :events
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
end
