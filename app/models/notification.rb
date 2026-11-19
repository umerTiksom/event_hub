
class Notification < ApplicationRecord
  # Person receiving the notification
  belongs_to :user

  # Event related to the notification
  belongs_to :event

  # Person who triggered the notification
  belongs_to :actor, class_name: "User"

  validates :action, presence: true
end
