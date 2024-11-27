class AdminController < ApplicationController
  before_action :require_admin

  def index
    @users = User.all
  end

  def edit_user
    @user = User.find(params[:id])
  end

  def edit_user_form
    @user = User.find(params[:id])

    if @user.update(user_params)
      flash[:notice] = "User updated successfully"
    else
      flash[:alert] = "Failed to update user: #{@user.errors.full_messages.to_sentence}"
    end

    redirect_to admin_path
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :shard_amount, :money_usd, :isAdmin)
  end
end
