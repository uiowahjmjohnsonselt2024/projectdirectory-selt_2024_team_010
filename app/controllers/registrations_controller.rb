class RegistrationsController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:notice] = "Registration successful"
      redirect_to login_path(username:user_params[:username], password:user_params[:password])
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