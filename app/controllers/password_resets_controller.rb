class PasswordResetsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:email])
    if @user
      @user.generate_password_reset_token!
      PasswordResetMailer.reset_email(@user).deliver_now
      flash[:notice] = "Check your email for reset instructions."
      redirect_to root_path
    else
      flash[:alert] = "Email address not found."
      render :new
    end
  end

  def edit
    @user = User.find_by(password_reset_token: params[:id])
    if @user.nil? || !@user.password_reset_valid?
      flash[:alert] = "Reset link is invalid or expired."
      redirect_to new_password_reset_path
    end
  end

  def update
    @user = User.find_by(password_reset_token: params[:id])
    if @user.nil?
      flash[:alert] = "Invalid reset link."
      redirect_to new_password_reset_path
    elsif @user.update(password_params)
      @user.clear_password_reset_token!
      flash[:notice] = "Password successfully reset. Please log in."
      redirect_to login_path
    else
      render :edit
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
