class PasswordResetMailer < ApplicationMailer
  def reset_email(user)
    @user = user
    @url = edit_password_reset_url(@user.password_reset_token)
    mail(to: @user.email, subject: "Password Reset Instructions")
  end
end
