
class Api::V1::NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [:read, :destroy]

  def index
    notifications = @current_user.notifications
                                 .includes(:actor, :event)
                                 .order(created_at: :desc)

    render json: {
      status: "success",
      unread_count: notifications.where(read_at: nil).count,
      notifications: notifications.map do |notification|
        notification_json(notification)
      end
    }, status: :ok
  end

  def read
    @notification.update!(read_at: Time.current)

    render json: {
      status: "success",
      message: "Notification marked as read",
      notification: notification_json(@notification)
    }, status: :ok
  end

  def destroy
    @notification.destroy!

    render json: {
      status: "success",
      message: "Notification deleted successfully"
    }, status: :ok
  end

  private

  def set_notification
    @notification = @current_user.notifications.find_by(id: params[:id])

    return if @notification

    render json: {
      status: "error",
      message: "Notification not found"
    }, status: :not_found
  end

  def notification_json(notification)
    {
      id: notification.id,
      action: notification.action,
      read_at: notification.read_at,
      created_at: notification.created_at,
      actor: {
        id: notification.actor.id,
        name: notification.actor.name
      },
      event: {
        id: notification.event.id,
        title: notification.event.name
      }
    }
  end
end
