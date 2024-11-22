class RegistrationsController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.update(money_usd: 0, shard_amount: 0)

    if @user.save
      flash[:notice] = "Registration successful"
      create_session_token @user
      redirect_to dashboard_path
    else
      flash.now[:alert] = "Error creating account: " + @user.errors.full_messages.join(", ")
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end