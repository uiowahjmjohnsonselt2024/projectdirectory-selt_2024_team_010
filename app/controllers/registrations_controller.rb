class RegistrationsController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id  # Log the user in immediately after registration
      flash[:notice] = "Registration successful"
      redirect_to dashboard_path
    else
      flash.now[:alert] = "Error creating account"
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end