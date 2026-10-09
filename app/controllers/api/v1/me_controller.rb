class Api::V1::MeController < ApplicationController
  before_action :authenticate_user!

  def show

    render json: {
      status: :success,
      data: {
        id: current_user.id,
        name: current_user.name,
        email: current_user.email,
        role: current_user.role
      }
    }, status: :ok
  end
end