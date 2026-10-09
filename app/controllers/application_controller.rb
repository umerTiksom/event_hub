
class ApplicationController < ActionController::Base
  private

  def authenticate_user!
    header = request.headers["Authorization"]
    token = header&.match(/\ABearer\s+(.+)\z/i)&.captures&.first

    unless token.present?
      render json: {
        status: :error,
        message: "Authentication token required"
      }, status: :unauthorized
      return
    end

    begin
      payload, = JWT.decode(
        token,
        Rails.application.secret_key_base,
        true,
        algorithm: "HS256"
      )

      @current_user = User.find_by(id: payload["user_id"])

      unless @current_user
        render json: {
          status: :error,
          message: "User not found"
        }, status: :unauthorized
      end

    rescue JWT::DecodeError
      render json: {
        status: :error,
        message: "Invalid or expired token"
      }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
