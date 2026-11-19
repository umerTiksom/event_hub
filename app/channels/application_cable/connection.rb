
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      authenticate_user
    end

    private

    def authenticate_user
      token = request.params[:token]

      reject_unauthorized_connection unless token.present?

      begin
        payload, = JWT.decode(
          token,
          Rails.application.secret_key_base,
          true,
          algorithm: "HS256"
        )

        self.current_user = User.find_by(id: payload["user_id"])

        reject_unauthorized_connection unless current_user

      rescue JWT::DecodeError
        reject_unauthorized_connection
      end
    end
  end
end
