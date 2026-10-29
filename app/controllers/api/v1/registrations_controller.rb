
class Api::V1::RegistrationsController < ApplicationController
  before_action :authenticate_user
  before_action :set_event, only: [:create]

  def index
    registrations = @current_user.registrations

    render json: registrations, status: :ok
  end


  def create
    registration = Registration.new
    registration.user = @current_user
    registration.event = @event

    if registration.save
      render json: {
        status: "success",
        message: "You have successfully registered for this event!",
        registration: {
          id: registration.id,
          user_id: registration.user_id,
          event_id: registration.event_id,
          name: registration.user.name,
          email: registration.user.email,
          phone_number: registration.user.phone_number
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


  def destroy
    registration = @current_user.registrations.find_by(id: params[:id])

    unless registration
      return render json: {
        status: "error",
        message: "Registration not found"
      }, status: :not_found
    end

    registration.destroy!

    render json: {
      status: "success",
      message: "Registration cancelled successfully"
    }, status: :ok
  end

  private

  def authenticate_user
    token = request.headers["Authorization"]&.split(" ")&.last

    if token.blank?
      return render json: {
        status: "error",
        message: "Authorization token is required"
      }, status: :unauthorized
    end

    begin
      decoded_token = JWT.decode(
        token,
        Rails.application.secret_key_base,
        true,
        { algorithm: "HS256" }
      )

      user_id = decoded_token.first["user_id"]
      @current_user = User.find_by(id: user_id)

      unless @current_user
        return render json: {
          status: "error",
          message: "User not found"
        }, status: :unauthorized
      end

    rescue JWT::ExpiredSignature
      return render json: {
        status: "error",
        message: "Authorization token has expired"
      }, status: :unauthorized

    rescue JWT::DecodeError
      return render json: {
        status: "error",
        message: "Invalid authorization token"
      }, status: :unauthorized
    end
  end

  def set_event
    @event = Event.find_by(id: params[:event_id])

    unless @event
      return render json: {
        status: "error",
        message: "Event not found"
      }, status: :not_found
    end
  end


  def registration_params
    params.require(:registration).permit
  end

end
