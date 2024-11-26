class SettingsController < ApplicationController
  before_action :require_login
  def index
    @current_user = current_user
  end

  def update_username
    user = User.find(current_user.id)

    if user.update(username: params[:new_username])
      flash[:notice] = "Username successfully updated!"
    else
      flash[:alert] = "Failed to update username. #{user.errors.full_messages.join(', ')}"
    end

    redirect_to settings_path
  end

  def update_password
    user = User.find(current_user.id)

    unless user.authenticate(params[:current_password])
      flash[:alert] = "Current password is incorrect."
      redirect_to settings_path and return
    end

    if params[:new_password] != params[:confirm_password]
      flash[:alert] = "New password and confirmation do not match."
      redirect_to settings_path and return
    end

    if user.update(password: params[:new_password])
      flash[:notice] = "Password successfully updated!"
    else
      flash[:alert] = "Failed to update password. #{user.errors.full_messages.join(', ')}"
    end

    redirect_to settings_path
  end
end