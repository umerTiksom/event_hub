class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.info "NotificationsChannel subscribed"

    unless current_user
      Rails.logger.info "No current user found"
      reject
      return
    end

    Rails.logger.info "Current user ID: #{current_user.id}"

    stream_from "notifications_user_#{current_user.id}"

    Rails.logger.info "Streaming from notifications_user_#{current_user.id}"
  end

  def unsubscribed
    Rails.logger.info "NotificationsChannel unsubscribed"
    stop_all_streams
  end
end