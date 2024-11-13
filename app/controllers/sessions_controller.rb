class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(username: params[:username])
    if user == nil then print("MISSING USER") end

    if user&.authenticate(params[:password])
      user.create_session!(session_token: Session.create_session_token)
      session[:session_token] = user.session.session_token

      session[:user_id] = user.id
      flash[:notice] = "Logged in successfully"
      redirect_to dashboard_path
    else
      flash.now[:alert] = "Invalid username or password"
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    session[:session_token] = nil
    @current_user.session.destroy
    @current_user = nil
    flash[:notice] = "Logged out successfully"
    redirect_to welcome_path
  end
end