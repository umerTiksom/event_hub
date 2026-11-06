
class Api::V1::Auth::PasswordResetsController < ApplicationController

  # POST /api/v1/auth/forgot_password
  def create
    user = User.find_by(email: params[:email] || params.dig(:user, :email))

    if user
      token = user.generate_password_reset_token

      PasswordResetMailer.reset_email(user, token).deliver_now
    end

    render json: {
      status: "success",
      message: "If your email exists, a password reset link has been sent."
    }, status: :ok

  rescue StandardError => e
    Rails.logger.error("Password reset email error: #{e.message}")

    render json: {
      status: "error",
      message: "Unable to process your request. Please try again."
    }, status: :internal_server_error
  end

  # POST /api/v1/auth/reset_password
  def update
    user = User.find_by(email: params[:email])

    unless user&.valid_password_reset_token?(params[:token])
      return render json: {
        status: "error",
        message: "Invalid or expired password reset link."
      }, status: :unprocessable_entity
    end

    if user.update(
      password: params[:password],
      password_confirmation: params[:password_confirmation],
      reset_password_token: nil,
      reset_password_sent_at: nil
    )
      render json: {
        status: "success",
        message: "Password has been reset successfully."
      }, status: :ok
    else
      render json: {
        status: "error",
        message: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

end
