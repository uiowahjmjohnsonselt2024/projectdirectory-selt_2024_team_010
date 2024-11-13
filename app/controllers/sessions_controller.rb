class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(username: params[:username])
    if user == nil then print("MISSING USER") end

    if user&.authenticate(params[:password])
      session[:user_id] = user.id

      redirect_to dashboard_path
    else
      flash.now[:alert] = "Invalid username or password"
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Logged out successfully"
    redirect_to welcome_path
  end
end