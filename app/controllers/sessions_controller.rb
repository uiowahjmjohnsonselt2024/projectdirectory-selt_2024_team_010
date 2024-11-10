class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(username: params[:username])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = "Logged in successfully"
      redirect_to dashboard_path
    else
      flash[:alert] = "Invalid username or password"
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Logged out successfully"
    redirect_to welcome_path
  end
end