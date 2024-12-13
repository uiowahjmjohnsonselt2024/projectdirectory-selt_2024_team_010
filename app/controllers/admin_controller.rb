class AdminController < ApplicationController
  before_action :require_admin

  def index
    @users = User.all
    @games = Game.all
  end

  def edit_user
    @user = User.find(params[:id])
  end

  def edit_user_form
    @user = User.find(params[:id])

    if @user.update(params.require(:user).permit(:username, :email, :shard_amount, :money_usd, :isAdmin))
      flash[:notice] = "User updated successfully"
      redirect_to admin_path
    else
      flash.now[:alert] = "Failed to update user: #{@user.errors.full_messages.to_sentence}"
      render :edit_user
    end
  end

  def delete_user_form
    @user = User.find_by(id: params[:id])

    if @user
      if @user.destroy
        flash[:notice] = "User deleted successfully."
        redirect_to admin_path
      else
        flash[:alert] = "Failed to delete user: #{@user.errors.full_messages.to_sentence}"
        redirect_to admin_path
      end
    else
      flash[:alert] = "User not found."
      redirect_to admin_path
    end
  end

  def add_user
    @user = User.new
  end

  def add_user_form
    @user = User.new(params.require(:user).permit(:username, :email, :password, :shard_amount, :money_usd, :isAdmin))

    if @user.save
      flash[:notice] = "User created successfully"
      redirect_to admin_path
    else
      flash.now[:alert] = "Failed to create user: #{@user.errors.full_messages.to_sentence}"
      render :add_user
    end
  end
end
