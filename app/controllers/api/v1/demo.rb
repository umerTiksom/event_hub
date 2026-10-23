class Api::V1::RegistrationsController < ApplicationController
  before_action :authenticate_user
  before_action :set_event, only: :create

  def create
    registration = @event.registrations.build(registration_params)
    registration.user = @current_user

    if registration.save
      render json: {
        status: "success",
        message: "You have successfully registered for this event!",
        data: {
          registration: registration.as_json(
            only: [
              :id,
              :user_id,
              :event_id,
              :name,
              :email,
              :phone_number
            ]
          )
        }
      }, status: :created
    else
      render json: {
        status: "error",
        message: "Registration failed",
        errors: registration.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def authenticate_user
    token = request.headers["Authorization"]&.split(" ")&.last

    if token.blank?
      return render json: {
        status: "error",
        message: "Authentication token is required"
      }, status: :unauthorized
    end

    begin
      decoded_token = JWT.decode(
        token,
        Rails.application.secret_key_base,
        true,
        algorithm: "HS256"
      )

      user_id = decoded_token.first["user_id"]
      @current_user = User.find_by(id: user_id)

      unless @current_user
        render json: {
          status: "error",
          message: "User not found"
        }, status: :unauthorized
      end
    rescue JWT::DecodeError, JWT::ExpiredSignature
      render json: {
        status: "error",
        message: "Invalid or expired token"
      }, status: :unauthorized
    end
  end

  def set_event
    @event = Event.find_by(id: params[:event_id])

    unless @event
      render json: {
        status: "error",
        message: "Event not found"
      }, status: :not_found
    end
  end

  def registration_params
    params.require(:registration).permit(
      :name,
      :email,
      :phone_number
    )
  end
end