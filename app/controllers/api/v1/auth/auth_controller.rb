class Api::V1::Auth::AuthController < ApplicationController

  def register
    user = User.new(user_params)

    if user.save
      token = generate_token(user)
      render json: {
        status: :success,
        token: token,
        message: 'User registered successfully',
        data:
          {
            user: {
              name: user.name,
              email: user.email,
              role: user.role
            }
          }
      }, status: :created
    else
      render json: {
        status: :error,
        message: 'user registration failed',
        errors: user.errors.full_messages
      },status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:user][:email])

    if user && user.authenticate(params[:user][:password])
      render json: {
        status: :success,
        token: generate_token(user),
        message: "Logged in successfully",
        data: {
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role
          }
        }
      }, status: :ok
    else
      render json: {
        status: :error,
        message: "Invalid email or password"
      }, status: :unauthorized
    end
  end

  private

  def generate_token(user)
    payload = {
      user_id: user.id,
      exp: 24.hours.from_now.to_i
    }

    JWT.encode(
      payload,
      Rails.application.secret_key_base,
      "HS256"
    )
  end
  def user_params
    params.require(:user).permit(
    :name,
    :phone_number,
    :email,
    :password,
    :role
    )
  end
end
