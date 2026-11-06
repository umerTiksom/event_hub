
class PasswordResetMailer < ApplicationMailer

  def reset_email(user, token)
    @user = user

    frontend_url = ENV.fetch(
      "FRONTEND_URL",
      "http://localhost:5173"
    )

    @reset_url = "#{frontend_url}/reset-password?token=#{CGI.escape(token)}&email=#{CGI.escape(user.email)}"

    mail(
      to: @user.email,
      subject: "Reset Your EventHub Password"
    )
  end

end
