class Api::V1::RegistrationController < ApplicationController
  def index
    @registrations = Current.user.registrations

    render json: @registrations
  end
    def create
      @event = Event.find(params[:event_id])

      @registration = @event.registrations.new(
        user_id: params[:user_id]
      )

      if @registration.save
        render json: @registration, status: :created
      else
        render json: {
          errors: @registration.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    def destroy
      @registration = Registration.find(params[:id])
      @registration.destroy

      render json: {
        message: "Registration cancelled successfully"
      }
    end

  end

