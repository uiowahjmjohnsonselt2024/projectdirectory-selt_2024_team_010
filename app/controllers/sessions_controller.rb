class SessionsController < ApplicationController
  before_action :current_user, only: [:destroy]
  def new
  end

  def create
    user = User.find_by(username: params[:username])
    if user != nil and user.authenticate(params[:password])
      create_session_token user
      flash[:notice] = "Logged in successfully"
      redirect_to dashboard_path
    else
      flash.now[:alert] = "Invalid username or password"
      render :new
    end
  end

  def destroy
    session[:session_token] = nil
    @current_user&.session&.destroy
    @current_user = nil
    flash[:notice] = "Logged out successfully"
    redirect_to welcome_path
  end
end